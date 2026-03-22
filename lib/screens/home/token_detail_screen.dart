import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/token_image.dart';
import '../../services/api_service.dart';
import '../common/loading_screen.dart';

/// Displays detailed information for a single token (symbol, price, balance, tabs, actions).
class TokenDetailScreen extends StatefulWidget {
  final Map<String, dynamic> asset;

  const TokenDetailScreen({super.key, required this.asset});

  @override
  State<TokenDetailScreen> createState() => _TokenDetailScreenState();
}

class _TokenDetailScreenState extends State<TokenDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  int _selectedTimeRangeIndex = 1; // 1D default
  List<double> _priceHistory = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchPriceHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _symbol => widget.asset['symbol'] as String? ?? '';
  String get _chain => widget.asset['chain'] as String? ?? '';
  String get _chainName => widget.asset['chainName'] as String? ?? _chain;
  double get _balance => (widget.asset['balance'] as num?)?.toDouble() ?? 0.0;
  double get _balanceUsd => (widget.asset['balanceUsd'] as num?)?.toDouble() ?? 0.0;
  double get _priceUsd => (widget.asset['priceUsd'] as num?)?.toDouble() ?? 0.0;
  double get _change24hPct => (widget.asset['change24hPct'] as num?)?.toDouble() ?? 0.0;
  String? get _contractAddress => widget.asset['address'] as String?;

  String get _displayContractAddress {
    final addr = _contractAddress;
    if (addr != null && addr.length > 12) {
      return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
    }
    if (addr != null && addr.isNotEmpty) return addr;
    // Placeholder per chain to match design
    final name = _chainName.toLowerCase();
    if (name.contains('tron')) return 'TR7NHq...Lj6t';
    if (name.contains('ethereum') || name.contains('eth')) return '0x1234...abcd';
    return '—';
  }

  bool get _isTron =>
      _chain.toUpperCase().contains('TRON') || _chain.toUpperCase() == 'TRX';

  static String _getChainKey(String chain) {
    final u = chain.toUpperCase();
    if (u.contains('BITCOIN') || u == 'BTC') return 'bitcoin';
    if (u.contains('ETHEREUM') || u == 'ETH') return 'ethereum';
    if (u.contains('SOLANA') || u == 'SOL') return 'solana';
    if (u.contains('BSC') || u.contains('BNB')) return 'bsc';
    if (u.contains('TRON') || u == 'TRX') return 'tron';
    if (u.contains('AVALANCHE') || u == 'AVAX') return 'avalanche';
    return chain.toLowerCase();
  }

  static bool _isStablecoin(String symbol) =>
      symbol.toUpperCase() == 'USDT' || symbol.toUpperCase() == 'USDC';

  static String? _getTokenIconAsset(String symbol) {
    final s = symbol.toUpperCase();
    if (s == 'USDT') return 'usdt.png';
    if (s == 'USDC') return 'usdc.png';
    return null;
  }

  String _formatPrice(double v) {
    if (v == 0) return '0.00';
    if (v >= 1) return v.toStringAsFixed(2);
    if (v >= 0.01) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }

  /// Precise format for stats: comma-separated thousands, 2 decimal places (e.g. 184,060,864,836.57).
  static final NumberFormat _preciseFormat = NumberFormat('#,##0.00');

  static String _formatPreciseNumber(double v) {
    if (v.isInfinite || v.isNaN) return '0.00';
    return _preciseFormat.format(v);
  }

  /// Exact value from design image for Market cap / Circulating supply / Total supply.
  static const double _imageValue = 184_060_864_836.57;

  /// Plausible fake stats using the design image value (no round zeros).
  static ({double marketCapUsd, double circulatingSupply, double? totalSupply}) _fakeStatsForSymbol(
    String symbol,
    double priceUsd,
  ) {
    final s = symbol.toUpperCase();
    // Use image value for stablecoins; scaled for others so magnitude is plausible
    switch (s) {
      case 'USDT':
      case 'USDC':
      case 'DAI':
        return (marketCapUsd: _imageValue, circulatingSupply: _imageValue, totalSupply: _imageValue);
      case 'BTC':
        return (marketCapUsd: _imageValue * 6.5, circulatingSupply: 19_512_468.57, totalSupply: 21_000_000.00);
      case 'ETH':
        return (marketCapUsd: _imageValue * 2.1, circulatingSupply: 120_456_789.12, totalSupply: null);
      case 'BNB':
        return (marketCapUsd: _imageValue * 0.48, circulatingSupply: 153_298_765.43, totalSupply: 153_298_765.43);
      case 'TRX':
        return (marketCapUsd: _imageValue * 0.052, circulatingSupply: _imageValue * 0.478, totalSupply: _imageValue * 0.543);
      case 'SOL':
        return (marketCapUsd: _imageValue * 0.41, circulatingSupply: 420_876_543.21, totalSupply: null);
      case 'XRP':
        return (marketCapUsd: _imageValue * 0.30, circulatingSupply: _imageValue * 0.282, totalSupply: _imageValue * 0.543);
      case 'DOGE':
        return (marketCapUsd: _imageValue * 0.12, circulatingSupply: _imageValue * 0.77, totalSupply: null);
      case 'ADA':
        return (marketCapUsd: _imageValue * 0.19, circulatingSupply: _imageValue * 0.19, totalSupply: _imageValue * 0.245);
      case 'AVAX':
      case 'MATIC':
      case 'DOT':
      case 'LINK':
        return (marketCapUsd: _imageValue * 0.065, circulatingSupply: 350_123_456.78, totalSupply: null);
      default:
        return (marketCapUsd: _imageValue, circulatingSupply: _imageValue, totalSupply: _imageValue);
    }
  }

  void _generateMockHistory() {
    // Simple mocked price history based on current price and selected range.
    final basePrice = _priceUsd <= 0 ? 1.0 : _priceUsd;
    const pointsCount = 60;

    // Volatility factor by range index (0 = 1H, 1 = 1D, ...)
    final volatility = switch (_selectedTimeRangeIndex) {
      0 => 0.01, // 1H
      1 => 0.02, // 1D
      2 => 0.04, // 1W
      3 => 0.06, // 1M
      4 => 0.08, // 1Y
      _ => 0.03, // All
    };

    final rnd = math.Random(_selectedTimeRangeIndex + 7);
    final List<double> points = [];
    double current = basePrice;

    for (int i = 0; i < pointsCount; i++) {
      final noise = (rnd.nextDouble() - 0.5) * 2 * volatility * basePrice;
      final trend = (i / pointsCount - 0.5) * volatility * basePrice;
      current = (current + noise + trend).clamp(basePrice * 0.3, basePrice * 3.0);
      points.add(current);
    }

    setState(() {
      _priceHistory = points;
      _isLoadingHistory = false;
    });
  }

  Future<void> _fetchPriceHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    final rangeKey = switch (_selectedTimeRangeIndex) {
      0 => '1H',
      1 => '1D',
      2 => '1W',
      3 => '1M',
      4 => '1Y',
      _ => 'ALL',
    };

    final prices = await ApiService.getTokenPriceHistory(
      symbol: _symbol,
      range: rangeKey,
    );

    if (prices.isNotEmpty) {
      setState(() {
        _priceHistory = prices;
        _isLoadingHistory = false;
      });
    } else {
      // Fallback to local mock data so UI still shows a graph.
      _generateMockHistory();
    }
  }

  Widget _buildTopBar(Color textColor, bool isDarkMode) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: isDarkMode ? AppColors.darkBackground : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
            Expanded(
              child: Text(
                _symbol,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.info_outline, color: textColor, size: 22),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final bgColor = ThemeHelper.getBackgroundColor(context);

    final chainKey = _getChainKey(_chain);
    final isStablecoin = _isStablecoin(_symbol);
    final tokenIconAsset = _getTokenIconAsset(_symbol);

    final isPositive = _change24hPct >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;

    final isDarkMode = ThemeHelper.isDarkMode(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopBar(textColor, isDarkMode),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_symbol.toUpperCase() == 'TRX')
                    _buildTronBanner(l10n, primaryColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$${_formatPrice(_priceUsd)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: changeColor,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '\$${(_change24hPct / 100 * _priceUsd).toStringAsFixed(2)} (${isPositive ? '+' : ''}${_change24hPct.toStringAsFixed(2)}%)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: changeColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGraphPlaceholder(l10n, grayColor, textColor),
                  const SizedBox(height: 12),
                  _buildTimeRangeChips(
                      l10n, grayColor, primaryColor, textColor),
                  const SizedBox(height: 20),
                  _buildTabs(l10n, textColor, primaryColor, grayColor),
                  const SizedBox(height: 16),
                  _buildActiveTabContent(
                    l10n,
                    chainKey,
                    isStablecoin,
                    tokenIconAsset,
                    textColor,
                    secondaryColor,
                    grayColor,
                    primaryColor,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionButtons(l10n, primaryColor, textColor),
    );
  }

  Widget _buildActiveTabContent(
    AppLocalizations l10n,
    String chainKey,
    bool isStablecoin,
    String? tokenIconAsset,
    Color textColor,
    Color secondaryColor,
    Color grayColor,
    Color primaryColor,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildHoldingsTab(
          l10n,
          chainKey,
          isStablecoin,
          tokenIconAsset,
          textColor,
          secondaryColor,
          grayColor,
        );
      case 1:
        return _buildHistoryTab(
          l10n,
          primaryColor,
          textColor,
          secondaryColor,
          grayColor,
        );
      case 2:
        return _buildAboutTab(
          l10n,
          primaryColor,
          textColor,
          secondaryColor,
          grayColor,
        );
      case 3:
        return _buildInsightsTab(
          l10n,
          textColor,
          secondaryColor,
          grayColor,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHoldingsTab(
    AppLocalizations l10n,
    String chainKey,
    bool isStablecoin,
    String? tokenIconAsset,
    Color textColor,
    Color secondaryColor,
    Color grayColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.myBalance,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: secondaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildBalanceCard(
          chainKey,
          isStablecoin,
          tokenIconAsset,
          textColor,
          secondaryColor,
          grayColor,
        ),
        if (_isTron) _buildTronResources(l10n, grayColor, textColor),
      ],
    );
  }

  Widget _buildHistoryTab(
    AppLocalizations l10n,
    Color primaryColor,
    Color textColor,
    Color secondaryColor,
    Color grayColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: grayColor.withOpacity(0.5),
                side: BorderSide(color: grayColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.tokenHistoryFilter,
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: textColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                'assets/images/token_history.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.tokenHistoryEmptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: secondaryColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.tokenHistoryCantFindViewBrowser,
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryColor,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  l10n.tokenHistoryViewBrowser,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    decoration: TextDecoration.underline,
                    decorationColor: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: Text(l10n.tokenHistoryBuyUsdt),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(
    AppLocalizations l10n,
    Color primaryColor,
    Color textColor,
    Color secondaryColor,
    Color grayColor,
  ) {
    final warningBg = Colors.red.withOpacity(0.06);
    final warningBorder = Colors.red.withOpacity(0.2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            '${l10n.about} $_symbol',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.tokenDetailStablecoinDescription(_symbol),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: secondaryColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {},
            child: Text(
              l10n.learnMore,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: warningBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: warningBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[600],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.tokenDetailDyorWarning(_symbol),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tokenDetailStats,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final fake = _fakeStatsForSymbol(_symbol, _priceUsd > 0 ? _priceUsd : 1.0);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: grayColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildStatusRow(
                      l10n.tokenDetailMarketCap,
                      '\$${_formatPreciseNumber(fake.marketCapUsd)}',
                      textColor,
                      secondaryColor,
                    ),
                    const SizedBox(height: 6),
                    _buildStatusRow(
                      l10n.tokenDetailCirculatingSupply,
                      '\$${_formatPreciseNumber(fake.circulatingSupply)} $_symbol',
                      textColor,
                      secondaryColor,
                    ),
                    const SizedBox(height: 6),
                    _buildStatusRow(
                      l10n.tokenDetailTotalSupply,
                      fake.totalSupply != null
                          ? '\$${_formatPreciseNumber(fake.totalSupply!)} $_symbol'
                          : '— $_symbol',
                      textColor,
                      secondaryColor,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tokenDetailContractAddress,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: grayColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.diamond,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _chainName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    _displayContractAddress,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tokenDetailLinks,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLinkChip(l10n.tokenDetailLinkWebsite, primaryColor, textColor),
              _buildLinkChip(l10n.tokenDetailLinkBrowser, primaryColor, textColor),
              _buildLinkChip(l10n.tokenDetailLinkWhitepaper, primaryColor, textColor),
              _buildLinkChip(l10n.tokenDetailLinkX, primaryColor, textColor),
              _buildLinkChip(l10n.tokenDetailLinkReddit, primaryColor, textColor),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(
    AppLocalizations l10n,
    Color textColor,
    Color secondaryColor,
    Color grayColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Overview (left) | Refreshes in 3h 26m + icon (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l10n.tokenInsightsOverview,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      l10n.tokenInsightsRefreshesIn('3h 26m'),
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SvgPicture.asset(
                    'assets/icons/refresh_progress.svg',
                    width: 17,
                    height: 17,
                    colorFilter: ColorFilter.mode(
                      secondaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Insights card: gradient border around light background (matches design)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF22C1C3), // teal
                  Color(0xFF4CAF50), // green
                  Color(0xFFF5A962), // orange
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tokenInsightsHeadlineSample,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            height: 1.35,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.tokenInsightsSummarySample,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryColor,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Text(
                      l10n.tokenInsightsDisclaimer,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryColor.withOpacity(0.9),
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    String label,
    String value,
    Color textColor,
    Color secondaryColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: secondaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkChip(
    String label,
    Color primaryColor,
    Color textColor,
  ) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        backgroundColor: Colors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
      ).copyWith(
        foregroundColor: MaterialStatePropertyAll<Color>(primaryColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildTronBanner(AppLocalizations l10n, Color primaryColor) {
    final dynamicBannerText = l10n.tokenDetailTronBanner
        .replaceAll('TRON', _chainName)
        .replaceAll('TRX', _symbol);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dynamicBannerText,
            style: TextStyle(
              fontSize: 13,
              color: ThemeHelper.getTextColor(context),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Text(
              l10n.learnMore,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphPlaceholder(AppLocalizations l10n, Color grayColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: _isLoadingHistory
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : (_priceHistory.isEmpty
              ? Center(
                  child: Text(
                    l10n.tokenDetailNoData,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: CustomPaint(
                    painter: _PriceHistoryPainter(
                      prices: _priceHistory,
                      lineColor: Colors.green,
                    ),
                  ),
                )),
    );
  }

  Widget _buildTimeRangeChips(
    AppLocalizations l10n,
    Color grayColor,
    Color primaryColor,
    Color textColor,
  ) {
    final labels = [
      l10n.timeRange1H,
      l10n.timeRange1D,
      l10n.timeRange1W,
      l10n.timeRange1M,
      l10n.timeRange1Y,
      l10n.all,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          labels.length,
          (i) => Material(
            color: _selectedTimeRangeIndex == i
                ? grayColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTimeRangeIndex = i;
                });
                _fetchPriceHistory();
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(
    AppLocalizations l10n,
    Color textColor,
    Color primaryColor,
    Color grayColor,
  ) {
    final tabs = [
      l10n.tokenDetailHoldings,
      l10n.tokenDetailHistory,
      l10n.tokenDetailAbout,
      l10n.tokenDetailInsights,
    ];
    return SizedBox(
      height: 48,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        isScrollable: true,
        indicatorColor: primaryColor,
        indicatorWeight: 3,
        labelColor: primaryColor,
        unselectedLabelColor: ThemeHelper.getSecondaryTextColor(context),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildBalanceCard(
    String chainKey,
    bool isStablecoin,
    String? tokenIconAsset,
    Color textColor,
    Color secondaryColor,
    Color grayColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grayColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          TokenImage(
            isNativeToken: !isStablecoin,
            chain: isStablecoin ? chainKey : null,
            tokenName: !isStablecoin ? chainKey : null,
            tokenAssetName: tokenIconAsset,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chainName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  '${_balance.toStringAsFixed(2)} $_symbol',
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_formatPrice(_balanceUsd)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Text(
                '-',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTronResources(AppLocalizations l10n, Color grayColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildResourceChip(
              l10n.energy,
              '0',
              'assets/icons/rocket.svg',
              grayColor,
              textColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildResourceChip(
              l10n.bandwidth,
              '0',
              'assets/icons/car.svg',
              grayColor,
              textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceChip(
    String label,
    String value,
    String iconAsset,
    Color grayColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: grayColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: textColor.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconAsset,
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      textColor.withOpacity(0.8),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n, Color primaryColor, Color textColor) {
    final isDark = ThemeHelper.isDarkMode(context);
    final bgColor = ThemeHelper.getBackgroundColor(context);

    final actions = [
      (l10n.send, 'send'),
      (l10n.receive, 'receive'),
      (l10n.swap, 'swap'),
      (l10n.buy, 'buy'),
      (l10n.sell, 'sell'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: ThemeHelper.getBorderColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) {
          final label = a.$1;
          final key = a.$2;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (key == 'send') {
                  _pushTokenLoading(context, l10n.send);
                } else if (key == 'receive') {
                  _pushTokenLoading(context, l10n.receive);
                } else if (key == 'swap') {
                  _pushTokenLoading(context, l10n.swap);
                } else if (key == 'buy') {
                  _pushTokenLoading(context, l10n.buy);
                } else if (key == 'sell') {
                  _pushTokenLoading(context, l10n.sell);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: key == 'receive'
                          ? ThemeHelper.getPrimaryColor(context)
                          : (isDark
                              ? ThemeHelper.getGrayColor(context).withOpacity(0.4)
                              : ThemeHelper.getGrayColor(context)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        key == 'send'
                            ? 'assets/icons/send.svg'
                            : key == 'receive'
                                ? 'assets/icons/receive.svg'
                                : key == 'swap'
                                    ? 'assets/icons/swap.svg'
                                    : key == 'buy'
                                        ? 'assets/icons/buy.svg'
                                        : 'assets/icons/sell.svg',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          key == 'receive' ? Colors.white : textColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _pushTokenLoading(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          topBarBuilder: (ctx) {
            final textColor = ThemeHelper.getTextColor(ctx);
            final isDark = ThemeHelper.isDarkMode(ctx);
            return SafeArea(
              bottom: false,
              child: Container(
                color: isDark ? AppColors.darkBackground : AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44), // balance back button space
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PriceHistoryPainter extends CustomPainter {
  final List<double> prices;
  final Color lineColor;

  _PriceHistoryPainter({
    required this.prices,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final minPrice = prices.reduce(math.min);
    final maxPrice = prices.reduce(math.max);
    final range = (maxPrice - minPrice).abs() < 1e-8 ? 1.0 : (maxPrice - minPrice);

    final path = Path();
    final double dx = size.width / (prices.length - 1);

    // Build a smooth cubic Bézier path instead of sharp segments.
    // Approximation technique: each segment uses midpoints as control points.
    double _yForIndex(int i) {
      final normalized = (prices[i] - minPrice) / range;
      return size.height - normalized * size.height;
    }

    // First point
    double x0 = 0;
    double y0 = _yForIndex(0);
    path.moveTo(x0, y0);

    for (int i = 1; i < prices.length; i++) {
      final x1 = i * dx;
      final y1 = _yForIndex(i);

      final xc = (x0 + x1) / 2;
      final yc = (y0 + y1) / 2;

      path.quadraticBezierTo(x0, y0, xc, yc);

      x0 = x1;
      y0 = y1;
    }

    // Final segment to the last point
    path.lineTo(x0, y0);

    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _PriceHistoryPainter oldDelegate) {
    return oldDelegate.prices != prices || oldDelegate.lineColor != lineColor;
  }
}
