import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/token_section.dart';
import '../../widgets/token_list_item.dart';
import '../../widgets/prediction_card.dart';
import '../../widgets/alpha_token_card.dart';
import '../../widgets/trust_premium_card.dart';
import '../../widgets/earn_card.dart';
import '../../widgets/token_image.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';
import '../send/send_screen.dart';
import '../settings/settings_screen.dart';
import '../scan/scan_qr_screen.dart';
import '../fund/fund_wallet_screen.dart';
import '../receive/select_crypto_screen.dart';
import '../receive/receive_screen.dart';
import '../wallet/wallet_selection_screen.dart';
import '../trade/trade_screen.dart';
import '../earn/earn_screen.dart';
import '../earn/stablecoin_earn_screen.dart';
import '../discover/discover_screen.dart';
import '../trust_premium/daily_exchange_swap_screen.dart';
import 'trending_tokens_screen.dart';
import 'token_detail_screen.dart';
import '../../services/earn_storage.dart';
import '../common/loading_screen.dart';
import 'package:http/http.dart' as http;
import '../auth/enter_passcode_screen.dart';
import '../../services/passcode_storage.dart';
import '../../services/ip_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, RouteAware {
  String _totalBalance = '\$0.00';
  String _balanceChange = '\$0.00(0%)';
  bool _isLoadingBalance = true;
  bool _isBalanceHidden = false;
  String _currentWalletName = 'Main Wallet';
  String? _activeWalletId;
  bool _isSyncingWallet = false;
  Timer? _refreshTimer;
  int _selectedTabIndex = 0;
  int _topMoversTabIndex = 0;
  int _popularTokensTabIndex = 0;
  int _selectedBottomNavIndex = 0;
  bool _showBackupBanner = true;
  int _currentBannerPage = 0;
  bool _showEarnBadge = true;
  final PageController _bannerPageController = PageController();
  Timer? _bannerTimer;
  // Cache of latest price / 24h change per symbol so we can reuse a previous
  // non-null change value if the backend temporarily omits it.
  final Map<String, Map<String, double?>> _priceInfoCache = {};
  double _lastTotalUsd = 0.0;
  double _lastChangeUsd = 0.0;
  List<Map<String, dynamic>> _cryptoAssets = [];
  Future<List<dynamic>>? _perpsTokensFuture;
  
  // Static cache for balance data across screen rebuilds
  static String? _cachedWalletId;
  static String? _cachedTotalBalance;
  static String? _cachedBalanceChange;
  static List<Map<String, dynamic>>? _cachedCryptoAssets;
  static double? _cachedLastTotalUsd;
  static double? _cachedLastChangeUsd;
  static Map<String, Map<String, double?>>? _cachedPriceInfoCache;
  static String? _loggedPublicIp;

  /// Prevents showing passcode screen multiple times when multiple [resumed] events fire in quick succession.
  bool _isShowingLockScreen = false;

  /// After user unlocks, ignore [resumed]-triggered lock for this duration (OS often fires resumed multiple times).
  static const _lockScreenCooldown = Duration(seconds: 5);
  DateTime? _lastUnlockTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startBannerTimer();

    // Load wallet name first
    _loadWalletName();
    
    // Check if Earn has been visited
    _checkEarnVisited();
    
    // Restore cached data if available for current wallet
    _restoreCachedData();

    // Kick off Perps markets load once so Home Perps card
    // doesn't recreate the future on every rebuild.
    _perpsTokensFuture = ApiService.getTopTokens(limit: 20);

    // Load fresh balance data in background
    _loadWalletBalance();

    // Log public internet IP once when home screen is opened
    _logPublicIpOnce();

    // Periodically refresh balance every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadWalletBalance();
    });
  }
  
  Future<void> _restoreCachedData() async {
    final walletId = await WalletStorage.getWalletId();
    
    // Only restore if cache exists and is for the same wallet
    if (walletId != null && 
        walletId.isNotEmpty && 
        _cachedWalletId == walletId && 
        _cachedTotalBalance != null &&
        _cachedCryptoAssets != null) {
      setState(() {
        _totalBalance = _cachedTotalBalance!;
        _balanceChange = _cachedBalanceChange ?? '\$0.00(0%)';
        _cryptoAssets = List<Map<String, dynamic>>.from(_cachedCryptoAssets!);
        _lastTotalUsd = _cachedLastTotalUsd ?? 0.0;
        _lastChangeUsd = _cachedLastChangeUsd ?? 0.0;
        if (_cachedPriceInfoCache != null) {
          _priceInfoCache.clear();
          _priceInfoCache.addAll(_cachedPriceInfoCache!);
        }
        _isLoadingBalance = false; // Show cached data immediately
      });
    }
  }

  Future<void> _logPublicIpOnce() async {
    // Avoid repeated network calls if user revisits Home
    if (_loggedPublicIp != null) return;
    try {
      final uri = Uri.parse('https://api.ipify.org?format=json');
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));
      if (resp.statusCode != 200) {
        // ignore: avoid_print
        print('[TRUST_APP] Public IP request failed: ${resp.statusCode}');
        return;
      }
      final data = jsonDecode(resp.body);
      final ip = data is Map<String, dynamic> ? data['ip'] as String? : null;
      if (ip == null || ip.isEmpty) return;
      _loggedPublicIp = ip;
      // ignore: avoid_print
      print('[TRUST_APP] Public internet IP: $ip');
    } catch (e) {
      // ignore: avoid_print
      print('[TRUST_APP] Public IP error: $e');
    }
  }

  Future<void> _lockIfPasscodeEnabled() async {
    if (_isShowingLockScreen) return;
    // If user just unlocked, ignore repeated [resumed] events for a short cooldown (OS can fire them multiple times).
    if (_lastUnlockTime != null &&
        DateTime.now().difference(_lastUnlockTime!) < _lockScreenCooldown) {
      return;
    }
    _isShowingLockScreen = true;
    try {
      final hasPasscode = await PasscodeStorage.hasPasscode();
      if (!hasPasscode || !mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const EnterPasscodeScreen(
            unlockExistingSession: true,
          ),
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[TRUST_APP] Lock screen error: $e');
    } finally {
      if (mounted) {
        _isShowingLockScreen = false;
        _lastUnlockTime = DateTime.now();
      }
    }
  }

  Future<void> _loadWalletName() async {
    final walletName = await WalletStorage.getWalletName();
    if (!mounted) return;
    final nextName = walletName ?? AppLocalizations.of(context)!.mainWallet;
    if (nextName == _currentWalletName) return;
    setState(() {
      _currentWalletName = nextName;
    });
  }

  Future<void> _syncWalletIfChanged() async {
    if (_isSyncingWallet) return;
    _isSyncingWallet = true;
    try {
      final walletId = await WalletStorage.getWalletId();
      if (!mounted) return;

      if (walletId != _activeWalletId) {
        setState(() {
          _activeWalletId = walletId;
          // Show loading while fetching the newly selected wallet balances.
          _isLoadingBalance = true;
          _cryptoAssets = [];
          // Reset per-wallet computed caches so we don't show the previous wallet's totals.
          _lastTotalUsd = 0.0;
          _lastChangeUsd = 0.0;
          _priceInfoCache.clear();
          _totalBalance = '\$0.00';
          _balanceChange = '\$0.00(0%)';
        });
        await _loadWalletName();
        await _loadWalletBalance();
        return;
      }

      // Keep name in sync even if wallet id didn't change.
      await _loadWalletName();
    } finally {
      _isSyncingWallet = false;
    }
  }

  Future<void> _checkEarnVisited() async {
    final hasVisited = await EarnStorage.hasVisitedEarn();
    if (!mounted) return;
    setState(() {
      _showEarnBadge = !hasVisited;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _lockIfPasscodeEnabled();
      // Report device IP to backend for all wallets on this device (so IP is saved when returning from background)
      IpHelper.reportCurrentIpForDevice(
        forceReport: true,
        source: 'return to foreground from background',
      );
      _loadWalletName();
      _loadWalletBalance();
    }
  }
  
  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_bannerPageController.hasClients) {
        final nextPage = (_currentBannerPage + 1) % 5; // 5 is the itemCount
        _bannerPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerTimer?.cancel();
    _refreshTimer?.cancel();
    _bannerPageController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final walletId = await WalletStorage.getWalletId();

      if (walletId == null || walletId.isEmpty) {
        // Clear cache if no wallet
        _cachedWalletId = null;
        _cachedTotalBalance = null;
        _cachedBalanceChange = null;
        _cachedCryptoAssets = null;
        _cachedLastTotalUsd = null;
        _cachedLastChangeUsd = null;
        _cachedPriceInfoCache = null;
        
        setState(() {
          _totalBalance = '\$0.00';
          _balanceChange = '\$0.00(0%)';
          _cryptoAssets = [];
          _isLoadingBalance = false;
        });
        return;
      }
      
      // Clear cache if wallet changed
      if (_cachedWalletId != null && _cachedWalletId != walletId) {
        _cachedWalletId = null;
        _cachedTotalBalance = null;
        _cachedBalanceChange = null;
        _cachedCryptoAssets = null;
        _cachedLastTotalUsd = null;
        _cachedLastChangeUsd = null;
        _cachedPriceInfoCache = null;
        // Also reset in-memory per-wallet caches to avoid carrying totals across wallets.
        _lastTotalUsd = 0.0;
        _lastChangeUsd = 0.0;
        _priceInfoCache.clear();
      }

      final response = await ApiService.getWalletBalances(walletId);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final balances = data['balances'] as List<dynamic>? ?? [];

        // Calculate total balance in USD using live prices from backend.
        // Start from cached values so we can reuse previous non-null change data.
        final Map<String, Map<String, double?>?> priceCache = {
          ..._priceInfoCache,
        };
        double totalUsd = 0.0;
        double totalChangeUsd = 0.0;
        final List<Map<String, dynamic>> cryptoAssets = []; // Clear assets list

        for (var balanceData in balances) {
          try {
            final balanceStr = balanceData['balance']?.toString() ?? '0';
            // Backend already returns human‑readable balances for all chains
            final humanReadableBalance = double.tryParse(balanceStr) ?? 0.0;

            if (humanReadableBalance <= 0) {
              continue;
            }

            final symbol = (balanceData['symbol']?.toString() ?? '').toUpperCase();
            if (symbol.isEmpty) continue;

            // Get or fetch USD price for this symbol, merging with cache.
            Map<String, double?>? priceInfo = priceCache[symbol];
            final fetched = await ApiService.getTokenPriceWithChange(symbol);
            if (fetched != null) {
              if (priceInfo == null) {
                priceInfo = Map<String, double?>.from(fetched);
              } else {
                priceInfo = {
                  'priceUsd': fetched['priceUsd'] ?? priceInfo['priceUsd'],
                  'change24hPct':
                      fetched['change24hPct'] ?? priceInfo['change24hPct'],
                };
              }
              priceCache[symbol] = priceInfo;
            }

            if (priceInfo == null) {
              // No data at all for this symbol
              continue;
            }

            final priceUsd = priceInfo['priceUsd'];

            // Always have a numeric change percentage; default to 0 if missing.
            double changePct = 0.0;
            final num? rawChange = priceInfo['change24hPct'] as num?;
            if (rawChange != null) {
              changePct = rawChange.toDouble();
            }

            if (priceUsd != null && priceUsd > 0) {
              final contribution = humanReadableBalance * priceUsd;
              totalUsd += contribution;

              if (changePct != 0.0) {
                totalChangeUsd += contribution * (changePct / 100.0);
              }

              // Store asset for Crypto tab
              final chain = balanceData['chain']?.toString() ?? '';
              cryptoAssets.add({
                'symbol': symbol,
                'chain': chain,
                'balance': humanReadableBalance,
                'balanceUsd': contribution,
                'priceUsd': priceUsd,
                'change24hPct': changePct,
                'icon': _getChainIcon(chain),
              });
            }
          } catch (e) {
            continue;
          }
        }

        // Persist merged cache for next refresh
        _priceInfoCache
          ..clear()
          ..addAll(
            priceCache.map(
              (k, v) => MapEntry(k, v ?? <String, double?>{}),
            ),
          );

        // Decide what to display:
        // - If this refresh produced a zero total but we previously had a
        //   non-zero total, treat it as a transient pricing/balance glitch and
        //   keep the last known values instead of flashing to 0.
        double displayTotalUsd = totalUsd;
        double displayChangeUsd = totalChangeUsd;

        if (totalUsd <= 0 && _lastTotalUsd > 0) {
          displayTotalUsd = _lastTotalUsd;
          displayChangeUsd = _lastChangeUsd;
        }

        // Single debug log summarizing the balance calculation
        // ignore: avoid_print
        // print(
            // '[HomeScreen][BALANCE] rawTotalUsd=${totalUsd.toStringAsFixed(4)}, rawChangeUsd=${totalChangeUsd.toStringAsFixed(4)}, displayTotalUsd=${displayTotalUsd.toStringAsFixed(4)}, displayChangeUsd=${displayChangeUsd.toStringAsFixed(4)}');

        _lastTotalUsd = displayTotalUsd;
        _lastChangeUsd = displayChangeUsd;

        final totalBalanceStr = '\$${_formatPrice(displayTotalUsd)}';
        String balanceChangeStr;
        if (displayTotalUsd > 0 && displayChangeUsd != 0) {
          final pct = (displayChangeUsd / displayTotalUsd) * 100.0;
          final sign = displayChangeUsd >= 0 ? '+' : '-';
          final absChange = displayChangeUsd.abs().toStringAsFixed(2);
          final absPct = pct.abs().toStringAsFixed(2);
          balanceChangeStr = '$sign\$$absChange($sign$absPct%)';
        } else {
          balanceChangeStr = '\$0.00(0%)';
        }

        // Save to cache
        _cachedWalletId = walletId;
        _cachedTotalBalance = totalBalanceStr;
        _cachedBalanceChange = balanceChangeStr;
        _cachedCryptoAssets = List<Map<String, dynamic>>.from(cryptoAssets);
        _cachedLastTotalUsd = displayTotalUsd;
        _cachedLastChangeUsd = displayChangeUsd;
        _cachedPriceInfoCache = Map<String, Map<String, double?>>.from(_priceInfoCache);

        setState(() {
          _totalBalance = totalBalanceStr;
          _balanceChange = balanceChangeStr;
          _cryptoAssets = cryptoAssets;
          _isLoadingBalance = false;
        });
      } else {
        // API returned failure - clear cache for this wallet
        if (_cachedWalletId == walletId) {
          _cachedWalletId = null;
          _cachedTotalBalance = null;
          _cachedBalanceChange = null;
          _cachedCryptoAssets = null;
          _cachedLastTotalUsd = null;
          _cachedLastChangeUsd = null;
          _cachedPriceInfoCache = null;
        }
        
        setState(() {
          _totalBalance = '\$0.00';
          _balanceChange = '\$0.00(0%)';
          _cryptoAssets = [];
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      // On error, keep cached data if available, otherwise show error state.
      // We don't have access to the local walletId here, so just rely on cache presence.
      if (_cachedWalletId != null && _cachedTotalBalance != null) {
        // Keep showing cached data on transient errors
        setState(() {
          _isLoadingBalance = false;
        });
      } else {
        // No cache available, show error state
        setState(() {
          _totalBalance = '\$0.00';
          _balanceChange = '\$0.00(0%)';
          _cryptoAssets = [];
          _isLoadingBalance = false;
        });
      }
    }
  }

  String _getChainIcon(String chain) {
    final chainUpper = chain.toUpperCase();
    if (chainUpper.contains('BITCOIN') || chainUpper == 'BTC') {
      return 'bitcoin.png';
    } else if (chainUpper.contains('ETHEREUM') || chainUpper == 'ETH') {
      return 'eth.png';
    } else if (chainUpper.contains('SOLANA') || chainUpper == 'SOL') {
      return 'solana.png';
    } else if (chainUpper.contains('BSC') || chainUpper.contains('BNB')) {
      return 'BNB smart.png';
    } else if (chainUpper.contains('TRON') || chainUpper == 'TRX') {
      return 'tron.png';
    } else if (chainUpper.contains('AVALANCHE') || chainUpper == 'AVAX') {
      return 'avalanche.png';
    }
    return 'eth.png'; // Default
  }

  String _getChainName(String chain) {
    final chainUpper = chain.toUpperCase();
    if (chainUpper.contains('BITCOIN') || chainUpper == 'BTC') {
      return 'Bitcoin';
    } else if (chainUpper.contains('ETHEREUM') || chainUpper == 'ETH') {
      return 'Ethereum';
    } else if (chainUpper.contains('SOLANA') || chainUpper == 'SOL') {
      return 'Solana';
    } else if (chainUpper.contains('BSC') || chainUpper.contains('BNB')) {
      return 'BNB Smart Chain';
    } else if (chainUpper.contains('TRON') || chainUpper == 'TRX') {
      return 'Tron';
    } else if (chainUpper.contains('AVALANCHE') || chainUpper == 'AVAX') {
      return 'Avalanche';
    }
    return chain;
  }

  /// Chain key for TokenImage (USDT/USDC token icon + chain overlay).
  String _getChainKeyForTokenImage(String chain) {
    final chainUpper = chain.toUpperCase();
    if (chainUpper.contains('BITCOIN') || chainUpper == 'BTC') return 'bitcoin';
    if (chainUpper.contains('ETHEREUM') || chainUpper == 'ETH') return 'ethereum';
    if (chainUpper.contains('SOLANA') || chainUpper == 'SOL') return 'solana';
    if (chainUpper.contains('BSC') || chainUpper.contains('BNB')) return 'bsc';
    if (chainUpper.contains('TRON') || chainUpper == 'TRX') return 'tron';
    if (chainUpper.contains('AVALANCHE') || chainUpper == 'AVAX') return 'avalanche';
    return chain.toLowerCase();
  }

  bool _isStablecoinToken(String symbol) =>
      symbol.toUpperCase() == 'USDT' || symbol.toUpperCase() == 'USDC';

  String? _getTokenIconAsset(String symbol) {
    final s = symbol.toUpperCase();
    if (s == 'USDT') return 'usdt.png';
    if (s == 'USDC') return 'usdc.png';
    return null;
  }

  /// Format large numbers into human‑readable strings like 1.26T, 80.23B, 67.89M.
  String _formatMarketCap(num value) {
    final v = value.toDouble().abs();
    if (v >= 1e12) {
      return '${(v / 1e12).toStringAsFixed(2)}T';
    } else if (v >= 1e9) {
      return '${(v / 1e9).toStringAsFixed(2)}B';
    } else if (v >= 1e6) {
      return '${(v / 1e6).toStringAsFixed(2)}M';
    } else if (v >= 1e3) {
      return '${(v / 1e3).toStringAsFixed(2)}K';
    }
    return v.toStringAsFixed(2);
  }

  /// Format a price with 2 decimals and thousand separators, e.g. 71345.12 -> "71,345.12".
  String _formatPrice(num value) {
    final negative = value < 0;
    final v = value.abs();
    final fixed = v.toStringAsFixed(2); // e.g. "71345.12"
    final parts = fixed.split('.');
    final intPart = parts[0];
    final fracPart = parts.length > 1 ? parts[1] : '00';

    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final indexFromEnd = intPart.length - i;
      buffer.write(intPart[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    final result = '${buffer.toString()}.$fracPart';
    return negative ? '-$result' : result;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    
    // Keep active wallet + balance in sync when returning from other screens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWalletIfChanged();
    });
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadWalletBalance,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Custom Header
              _buildHeader(),
              
              const SizedBox(height: 20),
              
              // Balance Section
              _buildBalanceSection(),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              _buildActionButtons(),
              
              const SizedBox(height: 24),
              
              // Backup Banner Carousel
              if (_showBackupBanner) ...[
                _buildBackupBannerCarousel(),
                const SizedBox(height: 12),
                _buildBannerPagination(),
              ],
              
              const SizedBox(height: 24),
              
              // Tabs
              _buildTabs(),
              
              const SizedBox(height: 24),
              
              // Tab content based on selection
              if (_selectedTabIndex == 0)
                _buildCryptoTabContent()
              else if (_selectedTabIndex == 1)
                _buildPredictionTabContent()
              else if (_selectedTabIndex == 2)
                _buildWatchlistTabContent()
              else if (_selectedTabIndex == 3)
                _buildNftsTabContent()
              else if (_selectedTabIndex == 4)
                _buildApprovalsTabContent()
              else
              _buildEmptyState(),
              
              const SizedBox(height: 32),
              
              // Top Movers Section
              _buildTopMoversSection(),
              
              const SizedBox(height: 32),
              
              // Popular Tokens Section
              _buildPopularTokensSection(),
              
              const SizedBox(height: 32),
              
              // Perps Section
              _buildPerpsSection(),
              
              const SizedBox(height: 32),
              
              // Prediction Section
              _buildPredictionSection(),
              
              const SizedBox(height: 32),
              
              // Alpha Tokens Section
              _buildAlphaTokensSection(),
              
              const SizedBox(height: 32),
              
              // Trust Premium Section
              _buildTrustPremiumSection(),
              
              const SizedBox(height: 32),
              
              // Earn Section
              _buildEarnSection(),
              
              const SizedBox(height: 32),
              
              // Footer Disclaimer
              _buildFooterDisclaimer(),
              
              const SizedBox(height: 20), // Gap between text and bottom nav
            ],
          ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    final textColor = ThemeHelper.getTextColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Left Icons - Gear
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/setting_gear.svg',
              width: 20,
              height: 20,
              colorFilter: isDarkMode
                  ? ColorFilter.mode(textColor, BlendMode.srcIn)
                  : null,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          // Scan Icon
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/scan.svg',
              width: 20,
              height: 20,
              colorFilter: isDarkMode
                  ? ColorFilter.mode(textColor, BlendMode.srcIn)
                  : null,
            ),
            onPressed: () async {
              // Open QR scanner screen. When a code is detected, the screen
              // will pop and return to home.
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanQrScreen(),
                ),
              );
            },
          ),
          
          // Center - Wallet Name (tappable)
          Expanded(
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalletSelectionScreen(),
                  ),
                );
                // Ensure UI updates immediately for the newly selected wallet
                // (show loading + clear old assets while fetching).
                await _syncWalletIfChanged();
              },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    _currentWalletName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: textColor,
                  size: 20,
                ),
              ],
              ),
            ),
          ),
          
          // Right Icons - Copy
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/copy.svg',
              width: 20,
              height: 20,
              colorFilter: isDarkMode
                  ? ColorFilter.mode(textColor, BlendMode.srcIn)
                  : null,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReceiveScreen(),
                ),
              );
            },
          ),
          // Search Icon
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/search.svg',
              width: 20,
              height: 20,
              colorFilter: isDarkMode
                  ? ColorFilter.mode(textColor, BlendMode.srcIn)
                  : null,
            ),
            onPressed: () => _pushHomeLoading(context),
          ),
        ],
      ),
    );
  }

  void _pushHomeLoading(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          topBarBuilder: (context) => _buildHomeTitleOnlyTopBar(context),
        ),
      ),
    );
  }

  Widget _buildHomeTitleOnlyTopBar(BuildContext context) {
    final textColor = ThemeHelper.getTextColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);

    return SafeArea(
      bottom: false,
      child: Container(
        color: isDarkMode ? AppColors.darkBackground : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const Spacer(),
            Text(
              _currentWalletName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSection() {
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    
    // Parse percentage from _balanceChange to determine color and arrow
    Color? changeColor;
    IconData? changeIcon;
    String displayChange = _balanceChange;
    
    if (!_isBalanceHidden && _balanceChange.isNotEmpty) {
      // Extract percentage from string like "$0.00(+0.22%)" or "$0.00(-0.22%)"
      final percentageMatch = RegExp(r'\(([+-]?[\d.]+)%\)').firstMatch(_balanceChange);
      if (percentageMatch != null) {
        final percentageStr = percentageMatch.group(1);
        if (percentageStr != null) {
          final percentage = double.tryParse(percentageStr);
          if (percentage != null) {
            if (percentage > 0) {
              changeColor = Colors.green;
              changeIcon = Icons.arrow_upward;
            } else if (percentage < 0) {
              changeColor = Colors.red;
              changeIcon = Icons.arrow_downward;
            }
          }
        }
      }
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _isBalanceHidden = !_isBalanceHidden;
        });
      },
      child: Column(
      children: [
          if (_isLoadingBalance)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
        Text(
              _isBalanceHidden ? '••••••' : _totalBalance,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (changeIcon != null && !_isBalanceHidden)
              Icon(
                changeIcon,
                size: 16,
                color: changeColor,
              ),
            if (changeIcon != null && !_isBalanceHidden)
              const SizedBox(width: 4),
        Text(
              _isBalanceHidden ? '••••••' : displayChange,
          style: TextStyle(
            fontSize: 16,
                color: changeColor ?? secondaryTextColor,
          ),
        ),
      ],
        ),
      ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            l10n.send,
            'assets/icons/send.svg',
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SendScreen(),
                ),
              );
            },
          ),
          _buildActionButton(
            l10n.fund,
            'assets/icons/fund.svg',
            true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FundWalletScreen(),
                ),
              );
            },
          ),
          _buildActionButton(
            l10n.swap,
            'assets/icons/swap.svg',
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailyExchangeSwapScreen(),
                ),
              );
            },
          ),
          _buildActionButton(
            l10n.sell,
            'assets/icons/sell.svg',
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectCryptoScreen(),
                ),
              );
            },
          ),
          _buildActionButton(
            l10n.earn,
            'assets/icons/Earn.svg',
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StablecoinEarnScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, String? iconPath, bool isPrimary, {VoidCallback? onTap}) {
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);

    final Color? iconColor = isPrimary
        ? (isDarkMode ? AppColors.darkBackground : AppColors.white)
        : (isDarkMode ? AppColors.darkText.withOpacity(0.7) : null);
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isPrimary ? primaryColor : grayColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: iconPath != null
                ? Center(
                    child: iconPath.toLowerCase().endsWith('.svg')
                        ? SvgPicture.asset(
                            iconPath,
                            width: 24,
                            height: 24,
                            colorFilter: iconColor != null
                                ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                                : null,
                          )
                        : Image.asset(
                            iconPath,
                            width: 24,
                            height: 24,
                            color: iconColor,
                            colorBlendMode:
                                iconColor != null ? BlendMode.srcIn : null,
                          ),
                  )
                : Icon(
                    Icons.add,
                    color: isPrimary 
                        ? (isDarkMode ? AppColors.darkBackground : AppColors.white) 
                        : (isDarkMode ? AppColors.darkText.withOpacity(0.7) : textColor),
                    size: 28,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupBannerCarousel() {
    return SizedBox(
      height: 96,
      child: PageView.builder(
        controller: _bannerPageController,
        onPageChanged: (index) {
          setState(() {
            _currentBannerPage = index;
          });
          // Reset timer when user manually swipes
          _bannerTimer?.cancel();
          _startBannerTimer();
        },
        itemCount: 5, // For now, repeat 5 times
        itemBuilder: (context, index) {
          return _buildBackupBanner();
        },
      ),
    );
  }

  Widget _buildBackupBanner() {
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: grayColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFD2FF),
            width: 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Pink torch container at top-left (ignoring padding)
            Positioned(
              top: -16,
              left: -16,
              child: Container(
                width: 32,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD2FF),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/torch.png',
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                // Lock image
                Image.asset(
                  'assets/images/lock1_4x.png',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.backUpToSecureAssets,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pushHomeLoading(context),
                        child: Text(
                          AppLocalizations.of(context)!.backUpWallet,
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // X button positioned top: 4, right: 0
            Positioned(
              top: 4,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showBackupBanner = false;
                  });
                },
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: secondaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerPagination() {
    final textColor = ThemeHelper.getTextColor(context);
    final borderColor = ThemeHelper.getBorderColor(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentBannerPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentBannerPage ? textColor : borderColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildTabs() {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [l10n.crypto, l10n.prediction, l10n.watchlist, l10n.nfts, l10n.approvals];
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final borderColor = ThemeHelper.getBorderColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ...tabs.asMap().entries.map((entry) {
                            final index = entry.key;
                            final label = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < tabs.length - 1 ? 24 : 0,
                              ),
                              child: _buildTab(label, index),
                            );
                          }),
                          const SizedBox(width: 16), // Space before icons
                        ],
                      ),
                    ),
                    // Right side gradient opacity
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                backgroundColor.withOpacity(0),
                                backgroundColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/history.svg',
                  width: 24,
                  height: 24,
                  colorFilter: isDarkMode
                      ? ColorFilter.mode(textColor, BlendMode.srcIn)
                      : null,
                ),
                onPressed: () => _pushHomeLoading(context),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/control.svg',
                  width: 24,
                  height: 24,
                  colorFilter: isDarkMode
                      ? ColorFilter.mode(textColor, BlendMode.srcIn)
                      : null,
                ),
                onPressed: () => _pushHomeLoading(context),
              ),
            ],
          ),
        ),
        // Gray border - full width, ignoring padding
        Container(
          height: 1,
          color: borderColor,
        ),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? textColor : secondaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              // Spacer to push underline to bottom
              const SizedBox(height: 0),
            ],
          ),
          // Primary color underline - positioned at bottom to overlap gray border
          Positioned(
            bottom: 0, // Position at bottom to align with gray border
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: label.length * 8.0,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoTabContent() {
    if (_cryptoAssets.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCryptoAssetsList();
  }

  Widget _buildCryptoAssetsList() {
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cryptoAssets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final asset = _cryptoAssets[index];
              return _buildCryptoAssetItem(
                asset,
                textColor,
                secondaryTextColor,
                grayColor,
                primaryColor,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => _pushHomeLoading(context),
            child: Text(
              AppLocalizations.of(context)!.manageCrypto,
              style: TextStyle(
                fontSize: 14,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCryptoAssetItem(
    Map<String, dynamic> asset,
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
    Color primaryColor,
  ) {
    final symbol = asset['symbol'] as String;
    final chain = asset['chain'] as String;
    final balance = asset['balance'] as double;
    final balanceUsd = asset['balanceUsd'] as double;
    final priceUsd = asset['priceUsd'] as double;
    final change24hPct = asset['change24hPct'] as double;
    final chainName = _getChainName(chain);

    final isPositive = change24hPct >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    final chainKey = _getChainKeyForTokenImage(chain);
    final isStablecoin = _isStablecoinToken(symbol);
    final tokenIconAsset = _getTokenIconAsset(symbol);

    return InkWell(
      onTap: () {
        final assetWithChainName = Map<String, dynamic>.from(asset)
          ..['chainName'] = chainName;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => TokenDetailScreen(asset: assetWithChainName),
          ),
        );
      },
      child: Row(
        children: [
          // Icon: USDT/USDC show token icon + chain overlay; others show chain icon only
          TokenImage(
            isNativeToken: !isStablecoin,
            chain: isStablecoin ? chainKey : null,
            tokenName: !isStablecoin ? chainKey : null,
            tokenAssetName: tokenIconAsset,
          ),
          const SizedBox(width: 16),
          // Name and price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      symbol,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: grayColor,
                        borderRadius: BorderRadius.circular(999), // Fully rounded
                      ),
                      child: Text(
                        chainName,
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${_formatPrice(priceUsd)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          changeIcon,
                          size: 13,
                          color: changeColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${isPositive ? '+' : ''}${change24hPct.toStringAsFixed(2)}%',
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
              ],
            ),
          ),
          // Holdings
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balance.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${_formatPrice(balanceUsd)}',
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionTabContent() {
    final textColor = ThemeHelper.getTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            // TODO: Navigate to predictions screen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: grayColor,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999), // Fully rounded
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.browsePredictions,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: textColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistTabContent() {
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Illustration
          Image.asset(
            'assets/images/watchlist.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            AppLocalizations.of(context)!.watchlistWelcome,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          // Create list button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to create watchlist
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4D3F3), // light blue
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999), // Fully rounded
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.createList,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNftsTabContent() {
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          // Simple placeholder icon for NFTs (use asset if available)
          Center(
            child: Image.asset(
              'assets/images/nfts_placeholder.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.crop_square,
                  size: 64,
                  color: secondaryTextColor,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            AppLocalizations.of(context)!.noNftsYet,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Receive NFTs link
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to receive NFTs flow
              },
              child: Text(
                AppLocalizations.of(context)!.receiveNfts,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalsTabContent() {
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: grayColor,
          borderRadius: BorderRadius.circular(999), // Fully rounded pill
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.noActiveApprovals,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Illustration - Add funds image
          Image.asset(
            'assets/images/add_funds_get_started.png',
            width: 154,
            height: 116,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.addFundsToGetStarted,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _pushHomeLoading(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999), // Fully rounded
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.fundYourWallet,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppColors.darkBackground : AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _pushHomeLoading(context),
            child: Text(
              AppLocalizations.of(context)!.manageCrypto,
              style: TextStyle(
                fontSize: 14,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMoversSection() {
    String subtitle;
    List<TokenItemData> items;

    switch (_topMoversTabIndex) {
      case 0: // Memes
        subtitle = 'Top Meme coins and tokens (24h % price gain)';
        items = [
        TokenItemData(
          rank: 1,
            name: 'war token',
            price: '\$${_formatPrice(0.01)}',
            marketCap: 'MCap: \$18.89M · Vol: \$9.26M',
            change: '+16.57%',
          isPositive: true,
          isNativeToken: false,
            chain: 'solana',
            tokenIcon: 'war_token.png',
        ),
        TokenItemData(
          rank: 2,
            name: 'Manyu (manyushiba.com)',
            price: '<\$0.01',
            marketCap: 'MCap: \$10.11M · Vol: \$6.86M',
            change: '+14.87%',
          isPositive: true,
          isNativeToken: false,
            chain: 'ethereum',
            tokenIcon: 'Manyu_token.png',
        ),
        TokenItemData(
          rank: 3,
            name: 'jelly-my-jelly',
            price: '\$${_formatPrice(0.05)}',
            marketCap: 'MCap: \$57.10M · Vol: \$9.45M',
            change: '+9.62%',
          isPositive: true,
          isNativeToken: false,
          chain: 'solana',
            tokenIcon: 'jelly-my-jelly_token.png',
            // If you add a specific jelly icon, set tokenIcon: 'jelly_token.png',
        ),
        ];
        break;
      case 1: // RWAs
        subtitle = 'Real-world assets (tokenized securities)';
        items = [
          TokenItemData(
            rank: 1,
            name: 'Alphabet Class A (Ondo Tokenized)',
            price: '\$${_formatPrice(328.21)}',
            marketCap: 'MCap: \$64.34M · Vol: \$19.06M',
            change: '-4.28%',
            isPositive: false,
            isNativeToken: false,
            chain: 'bnb',
            tokenIcon: 'Alphabet_token.png',
          ),
          TokenItemData(
            rank: 2,
            name: 'Alphabet Class A (Ondo Tokenized)',
            price: '\$${_formatPrice(328.21)}',
            marketCap: 'MCap: \$64.34M · Vol: \$19.06M',
            change: '-4.28%',
            isPositive: false,
            isNativeToken: false,
            chain: 'ethereum',
            tokenIcon: 'Alphabet_token.png',
          ),
          TokenItemData(
            rank: 3,
            name: 'iShares Silver Trust (Ondo Tokenized)',
            price: '\$${_formatPrice(72.26)}',
            marketCap: 'MCap: \$36.49M · Vol: \$31.96M',
            change: '-11.53%',
            isPositive: false,
            isNativeToken: false,
            chain: 'bnb',
            tokenIcon: 'iShares_token.png',
          ),
        ];
        break;
      case 2: // AI
      default:
        subtitle = 'AI-powered tokens (24h % price gain)';
        items = [
          TokenItemData(
            rank: 1,
            name: 'Codatta',
            price: '<\$0.01',
            marketCap: 'MCap: \$10.70M · Vol: \$6.06M',
            change: '+15.58%',
            isPositive: true,
            isNativeToken: false,
            chain: 'bnb',
            tokenIcon: 'codatta_token.png',
          ),
          TokenItemData(
            rank: 2,
            name: 'ChainOpera AI',
            price: '\$${_formatPrice(0.32)}',
            marketCap: 'MCap: \$60.50M · Vol: \$19.06M',
            change: '+7.43%',
            isPositive: true,
            isNativeToken: false,
            chain: 'bnb',
            tokenIcon: 'chainopera_token.png',
          ),
          TokenItemData(
            rank: 3,
            name: 'iTagger',
            price: '<\$0.01',
            marketCap: 'MCap: \$42.70M · Vol: \$6.10M',
            change: '+6.75%',
            isPositive: true,
            isNativeToken: false,
            chain: 'bnb',
            tokenIcon: 'tagger_token.png',
          ),
        ];
        break;
    }

    final l10n = AppLocalizations.of(context)!;
    return TokenSection(
      title: l10n.topMovers,
      tabs: [l10n.memes, l10n.rwas, l10n.ai],
      selectedTabIndex: _topMoversTabIndex,
      subtitle: subtitle,
      items: items,
      viewAllText: AppLocalizations.of(context)!.viewAll,
      onTabChanged: (index) {
        setState(() {
          _topMoversTabIndex = index;
        });
      },
      onViewAll: () {
        _pushHomeLoading(context);
      },
    );
  }

  Widget _buildPopularTokensSection() {
    return FutureBuilder<List<dynamic>>(
      // Fetch a larger set so we can reliably find ETH, BNB, SOL from real data.
      future: ApiService.getTopTokens(limit: 50),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final tokens = snapshot.data ?? [];

        // Build lookup by symbol so we can pick specific tokens for the Top tab.
        final Map<String, Map<String, dynamic>> bySymbol = {};
        for (final t in tokens) {
          if (t is Map<String, dynamic>) {
            final sym = (t['symbol']?.toString() ?? '').toUpperCase();
            if (sym.isNotEmpty) {
              // Debug log raw token data once per symbol
              // ignore: avoid_print
              // print(
              //     '[PopularTokens][RAW] symbol=$sym priceUsd=${t['priceUsd']} changePercent24Hr=${t['changePercent24Hr']} marketCapUsd=${t['marketCapUsd']}');
              bySymbol[sym] = t;
            }
          }
        }

        List<TokenItemData> items = [];

        // Helper to add a token by symbol if present.
        void addFromSymbol(
          String symbol,
          int rank, {
          required String tokenNameForIcon,
        }) {
          final token = bySymbol[symbol];
          if (token == null) return;

          final name = token['name']?.toString() ?? symbol;
          final price = (token['priceUsd'] as num?)?.toDouble() ?? 0.0;
          final marketCapValue = token['marketCapUsd'] as num?;
          final changePct =
              (token['changePercent24Hr'] as num?)?.toDouble() ?? 0.0;
          final isPositive = changePct >= 0;

          final volumeValue = token['volumeUsd24Hr'] as num?;
          final marketCapText = 'MCap: '
              '${marketCapValue != null ? '\$${_formatMarketCap(marketCapValue)}' : '--'}'
              ' · Vol: '
              '${volumeValue != null ? '\$${_formatMarketCap(volumeValue)}' : '--'}';

          items.add(
        TokenItemData(
              rank: rank,
              name: name,
              price: '\$${_formatPrice(price)}',
              marketCap: marketCapText,
              change:
                  '${isPositive ? '+' : ''}${changePct.toStringAsFixed(2)}%',
              isPositive: isPositive,
          isNativeToken: true,
              tokenName: tokenNameForIcon,
            ),
          );
        }

        // Build items based on selected tab
        if (_popularTokensTabIndex == 0) {
          // Top tab: ETH, BNB, SOL
          addFromSymbol('ETH', 1, tokenNameForIcon: 'eth');
          addFromSymbol('BNB', 2, tokenNameForIcon: 'bnb');
          addFromSymbol('SOL', 3, tokenNameForIcon: 'solana');
        } else if (_popularTokensTabIndex == 1) {
          // BNB tab: BNB + MemeCore + MYX Finance.
          final List<TokenItemData> bnbItems = [];

          // 1) BNB Smart Chain – use real data when available.
          final Map<String, dynamic>? bnbToken = bySymbol['BNB'];
          if (bnbToken != null) {
            final name =
                bnbToken['name']?.toString() ?? 'BNB Smart Chain';
            final price =
                (bnbToken['priceUsd'] as num?)?.toDouble() ?? 0.0;
            final marketCapValue = bnbToken['marketCapUsd'] as num?;
            final changePct =
                (bnbToken['changePercent24Hr'] as num?)?.toDouble() ??
                    0.0;
            final isPositive = changePct >= 0;

            final volumeValue = bnbToken['volumeUsd24Hr'] as num?;
            final marketCapText = 'MCap: '
                '${marketCapValue != null ? '\$${_formatMarketCap(marketCapValue)}' : '--'}'
                ' · Vol: '
                '${volumeValue != null ? '\$${_formatMarketCap(volumeValue)}' : '--'}';

            bnbItems.add(
        TokenItemData(
                rank: 1,
                name: name,
                price: '\$${price.toStringAsFixed(2)}',
                marketCap: marketCapText,
                change:
                    '${isPositive ? '+' : ''}${changePct.toStringAsFixed(2)}%',
                isPositive: isPositive,
          isNativeToken: true,
                tokenName: 'bnb',
              ),
            );
          }

          // Helper to find a token by exact name (case-insensitive).
          Map<String, dynamic>? findTokenByName(String targetName) {
            for (final dynamic t in tokens) {
              if (t is! Map<String, dynamic>) continue;
              final name = (t['name']?.toString() ?? '').toLowerCase();
              if (name == targetName.toLowerCase()) return t;
            }
            return null;
          }

          // 2) MemeCore – prefer real data, fall back to provided numbers.
          final memeToken = findTokenByName('MemeCore');
          final memePrice =
              (memeToken?['priceUsd'] as num?)?.toDouble() ?? 1.51;
          final memeMarketCapValue =
              (memeToken?['marketCapUsd'] as num?)?.toDouble() ??
                  1.91e9; // $1.91B
          final memeVolumeValue =
              (memeToken?['volumeUsd24Hr'] as num?)?.toDouble() ??
                  16.0e6; // $16.00M
          final memeChangePct =
              (memeToken?['changePercent24Hr'] as num?)?.toDouble() ??
                  2.97;
          final memeIsPositive = memeChangePct >= 0;

          final memeMarketCapText = 'MCap: '
              '\$${_formatMarketCap(memeMarketCapValue)}'
              ' · Vol: '
              '\$${_formatMarketCap(memeVolumeValue)}';

          bnbItems.add(
        TokenItemData(
              rank: bnbItems.length + 1,
              name: 'MemeCore',
              price: '\$${_formatPrice(memePrice)}',
              marketCap: memeMarketCapText,
              change:
                  '${memeIsPositive ? '+' : ''}${memeChangePct.toStringAsFixed(2)}%',
              isPositive: memeIsPositive,
              isNativeToken: false,
              chain: 'bnb',
              tokenIcon: 'MemeCore.png',
            ),
          );

          // 3) MYX Finance – prefer real data, fall back to provided numbers.
          final myxToken = findTokenByName('MYX Finance');
          final myxPrice =
              (myxToken?['priceUsd'] as num?)?.toDouble() ?? 6.15;
          final myxMarketCapValue =
              (myxToken?['marketCapUsd'] as num?)?.toDouble() ??
                  1.54e9; // $1.54B
          final myxVolumeValue =
              (myxToken?['volumeUsd24Hr'] as num?)?.toDouble() ??
                  27.77e6; // $27.77M
          final myxChangePct =
              (myxToken?['changePercent24Hr'] as num?)?.toDouble() ??
                  4.47;
          final myxIsPositive = myxChangePct >= 0;

          final myxMarketCapText = 'MCap: '
              '\$${_formatMarketCap(myxMarketCapValue)}'
              ' · Vol: '
              '\$${_formatMarketCap(myxVolumeValue)}';

          bnbItems.add(
            TokenItemData(
              rank: bnbItems.length + 1,
              name: 'MYX Finance',
              price: '\$${_formatPrice(myxPrice)}',
              marketCap: myxMarketCapText,
              change:
                  '${myxIsPositive ? '+' : ''}${myxChangePct.toStringAsFixed(2)}%',
              isPositive: myxIsPositive,
              isNativeToken: false,
              chain: 'bnb',
              tokenIcon: 'MYX_Finance.png',
            ),
          );

          items = bnbItems;
        } else if (_popularTokensTabIndex == 2) {
          // ETH tab: Ethereum + stETH + Wrapped liquid staked Ether 2.0.
          final List<TokenItemData> ethItems = [];

          // 1) Ethereum – use real data when available.
          final Map<String, dynamic>? ethToken = bySymbol['ETH'];
          double ethPrice = 0.0;
          if (ethToken != null) {
            final name =
                ethToken['name']?.toString() ?? 'Ethereum';
            ethPrice =
                (ethToken['priceUsd'] as num?)?.toDouble() ?? 0.0;
            final marketCapValue = ethToken['marketCapUsd'] as num?;
            final changePct =
                (ethToken['changePercent24Hr'] as num?)?.toDouble() ??
                    0.0;
            final isPositive = changePct >= 0;

            final volumeValue = ethToken['volumeUsd24Hr'] as num?;
            final marketCapText = 'MCap: '
                '${marketCapValue != null ? '\$${_formatMarketCap(marketCapValue)}' : '--'}'
                ' · Vol: '
                '${volumeValue != null ? '\$${_formatMarketCap(volumeValue)}' : '--'}';

            ethItems.add(
              TokenItemData(
                rank: 1,
                name: name,
                price: '\$${_formatPrice(ethPrice)}',
                marketCap: marketCapText,
                change:
                    '${isPositive ? '+' : ''}${changePct.toStringAsFixed(2)}%',
                isPositive: isPositive,
          isNativeToken: true,
                tokenName: 'eth',
              ),
            );
          }

          // Helper to find a token by exact name (case-insensitive).
          Map<String, dynamic>? findEthTokenByName(String targetName) {
            for (final dynamic t in tokens) {
              if (t is! Map<String, dynamic>) continue;
              final name = (t['name']?.toString() ?? '').toLowerCase();
              if (name == targetName.toLowerCase()) return t;
            }
            return null;
          }

          // 2) stETH – prefer real data, fall back to provided numbers.
          final stEthToken = findEthTokenByName('stETH');
          double stEthPrice =
              (stEthToken?['priceUsd'] as num?)?.toDouble() ?? 2145.12;
          double? stEthMarketCapValue =
              (stEthToken?['marketCapUsd'] as num?)?.toDouble();
          double? stEthVolumeValue =
              (stEthToken?['volumeUsd24Hr'] as num?)?.toDouble();
          double stEthChangePct =
              (stEthToken?['changePercent24Hr'] as num?)?.toDouble() ??
                  -7.07;

          // Fallbacks if API doesn't have this token.
          stEthMarketCapValue ??= 20.24e9; // $20.24B
          stEthVolumeValue ??= 90.27e6; // $90.27M

          final stEthIsPositive = stEthChangePct >= 0;

          final stEthMarketCapText = 'MCap: '
              '${stEthMarketCapValue != null ? '\$${_formatMarketCap(stEthMarketCapValue)}' : '--'}'
              ' · Vol: '
              '${stEthVolumeValue != null ? '\$${_formatMarketCap(stEthVolumeValue)}' : '--'}';

          ethItems.add(
            TokenItemData(
              rank: ethItems.length + 1,
              name: 'stETH',
              price: '\$${_formatPrice(stEthPrice)}',
              marketCap: stEthMarketCapText,
              change:
                  '${stEthIsPositive ? '+' : ''}${stEthChangePct.toStringAsFixed(2)}%',
              isPositive: stEthIsPositive,
              isNativeToken: false,
              chain: 'ethereum',
              tokenIcon: 'stETH.png',
            ),
          );

          // 3) Wrapped liquid staked Ether 2.0 – prefer real data, fall back to provided numbers.
          final wlsEthToken =
              findEthTokenByName('Wrapped liquid staked Ether 2.0');
          double wlsEthPrice =
              (wlsEthToken?['priceUsd'] as num?)?.toDouble() ??
                  2582.55;
          double? wlsEthMarketCapValue =
              (wlsEthToken?['marketCapUsd'] as num?)?.toDouble();
          double? wlsEthVolumeValue =
              (wlsEthToken?['volumeUsd24Hr'] as num?)?.toDouble();
          double wlsEthChangePct =
              (wlsEthToken?['changePercent24Hr'] as num?)?.toDouble() ??
                  -7.33;

          wlsEthMarketCapValue ??= 9.52e9; // $9.52B
          wlsEthVolumeValue ??= 26.09e6; // $26.09M

          final wlsEthIsPositive = wlsEthChangePct >= 0;

          final wlsEthMarketCapText = 'MCap: '
              '${wlsEthMarketCapValue != null ? '\$${_formatMarketCap(wlsEthMarketCapValue)}' : '--'}'
              ' · Vol: '
              '${wlsEthVolumeValue != null ? '\$${_formatMarketCap(wlsEthVolumeValue)}' : '--'}';

          ethItems.add(
            TokenItemData(
              rank: ethItems.length + 1,
              name: 'Wrapped liquid staked Ether 2.0',
              price: '\$${_formatPrice(wlsEthPrice)}',
              marketCap: wlsEthMarketCapText,
              change:
                  '${wlsEthIsPositive ? '+' : ''}${wlsEthChangePct.toStringAsFixed(2)}%',
              isPositive: wlsEthIsPositive,
              isNativeToken: false,
              chain: 'ethereum',
              tokenIcon: 'wstEth.png',
            ),
          );

          items = ethItems;
        }

        // Fallback: if none of the desired symbols are present, use the first 3 tokens.
        if (items.isEmpty && tokens.isNotEmpty) {
          items = tokens.take(3).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final token = entry.value as Map<String, dynamic>;
            final name = token['name']?.toString() ?? '';
            final symbol = (token['symbol']?.toString() ?? '').toUpperCase();
            final price = (token['priceUsd'] as num?)?.toDouble() ?? 0.0;
            final marketCapValue = token['marketCapUsd'] as num?;
            final changePct =
                (token['changePercent24Hr'] as num?)?.toDouble() ?? 0.0;
            final isPositive = changePct >= 0;

            final volumeValue = token['volumeUsd24Hr'] as num?;
            final marketCapText = 'MCap: '
                '${marketCapValue != null ? '\$${_formatMarketCap(marketCapValue)}' : '--'}'
                ' · Vol: '
                '${volumeValue != null ? '\$${_formatMarketCap(volumeValue)}' : '--'}';

            return TokenItemData(
              rank: index + 1,
              name: name,
              price: '\$${_formatPrice(price)}',
              marketCap: marketCapText,
              change:
                  '${isPositive ? '+' : ''}${changePct.toStringAsFixed(2)}%',
              isPositive: isPositive,
              isNativeToken: true,
              tokenName: symbol.toLowerCase(),
            );
          }).toList();
        }

        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        final l10n = AppLocalizations.of(context)!;
        return TokenSection(
          title: l10n.popularTokens,
          tabs: [l10n.top, l10n.bnb, l10n.eth],
          selectedTabIndex: _popularTokensTabIndex,
          subtitle: l10n.topTokensByMarketCap,
          items: items,
      viewAllText: AppLocalizations.of(context)!.viewAll,
      onTabChanged: (index) {
            setState(() {
              _popularTokensTabIndex = index;
            });
      },
      onViewAll: () {
            _pushHomeLoading(context);
          },
        );
      },
    );
  }

  Widget _buildNewTag() {
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final backgroundColor = isDarkMode 
        ? primaryColor.withOpacity(0.2) 
        : const Color(0xFFE8E5FB);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.rocket_launch,
            size: 12,
            color: primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context)!.newLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerpsSection() {
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final cardBackgroundColor = isDarkMode 
        ? AppColors.secondaryGray.withOpacity(0.3) 
        : const Color(0xFFF4F4F6);
    final separatorColor = isDarkMode 
        ? AppColors.secondaryGray.withOpacity(0.5) 
        : const Color(0xFFE1E1E1);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with New tag
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.perps,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              _buildNewTag(),
            ],
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            AppLocalizations.of(context)!.tradeMarketMoves100Pairs,
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          // Combined card with token list and How perps work
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                // Token list using real data
                FutureBuilder<List<dynamic>>(
                  future: _perpsTokensFuture ??
                      (_perpsTokensFuture = ApiService.getTopTokens(limit: 20)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final tokens = snapshot.data ?? [];
                    final Map<String, Map<String, dynamic>> bySymbol = {};
                    for (final t in tokens) {
                      if (t is Map<String, dynamic>) {
                        final sym =
                            (t['symbol']?.toString() ?? '').toUpperCase();
                        if (sym.isNotEmpty) {
                          bySymbol[sym] = t;
                        }
                      }
                    }

                    Widget buildPerpRow({
                      required int rank,
                      required String symbol,
                      required String pairName,
                      required String tokenNameForIcon,
                    }) {
                      final token = bySymbol[symbol];
                      // Be defensive about backend field types (num or String).
                      final dynamic rawPrice = token?['priceUsd'];
                      final double price = rawPrice is num
                          ? rawPrice.toDouble()
                          : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0;

                      final dynamic rawChange = token?['changePercent24Hr'];
                      final double changePct = rawChange is num
                          ? rawChange.toDouble()
                          : double.tryParse(rawChange?.toString() ?? '') ?? 0.0;
                      final isPositive = changePct >= 0;

                      return TokenListItem(
                        rank: rank,
                        name: '$pairName-USD',
                        price: '\$${_formatPrice(price)}',
                        marketCap: 'Up to 100x leverage',
                        change:
                            '${isPositive ? '+' : ''}${changePct.toStringAsFixed(2)}%',
                        isPositive: isPositive,
                  isNativeToken: true,
                        tokenName: tokenNameForIcon,
                      );
                    }

                    return Column(
                      children: [
                        buildPerpRow(
                          rank: 1,
                          symbol: 'BTC',
                          pairName: 'BTC',
                          tokenNameForIcon: 'bitcoin',
                ),
                const SizedBox(height: 16),
                        buildPerpRow(
                  rank: 2,
                          symbol: 'ETH',
                          pairName: 'ETH',
                          tokenNameForIcon: 'eth',
                ),
                const SizedBox(height: 16),
                        buildPerpRow(
                  rank: 3,
                          symbol: 'BNB',
                          pairName: 'BNB',
                          tokenNameForIcon: 'bnb',
                        ),
                      ],
                    );
                  },
                ),
                // Separator line
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: separatorColor,
                ),
                const SizedBox(height: 16),
                // How perps work section
                Row(
                  children: [
                    Image.asset(
                      'assets/images/how_perps_work.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.howPerpsWork,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.learnPerpsLongShort,
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionSection() {
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with New tag and navigation arrow
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.prediction,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              _buildNewTag(),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: secondaryTextColor,
                ),
                onPressed: () {
                  // Handle navigation
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            AppLocalizations.of(context)!.tradeOnYourKnowledge,
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          // Prediction market card
          PredictionCard(
            imagePath: 'assets/images/crypto_winter.png',
            question: 'Crypto Winter is coming?',
            yesOutcome: '\$100.11',
            noOutcome: '\$12,331',
            currentValue: '\$100.11',
            status: 'In Progress',
            provider: 'Myriad',
            onYesPressed: () {
              // Handle Yes button press
            },
            onNoPressed: () {
              // Handle No button press
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCoinShape(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildAlphaTokensSection() {
    final textColor = ThemeHelper.getTextColor(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.alphaTokens,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                AlphaTokenCard(
                  name: 'WMTX',
                  price: '\$${_formatPrice(0.09)}',
                  marketCap: '\$${_formatMarketCap(1.74e9)}',
                  change: '+13.06%',
                  isPositive: true,
                  isNativeToken: false,
                  chain: 'ethereum',
                  tokenName: 'eth',
                  tokenIcon: 'WMTX.png',
                ),
                AlphaTokenCard(
                  name: 'B2',
                  price: '\$${_formatPrice(0.81)}',
                  marketCap: '\$${_formatMarketCap(408.59e6)}',
                  change: '+1.92%',
                  isPositive: true,
                  isNativeToken: false,
                  chain: 'bnb',
                  tokenName: 'bnb',
                  tokenIcon: 'B2.png',
                ),
                AlphaTokenCard(
                  name: 'TRIA',
                  price: '\$${_formatPrice(0.02)}',
                  marketCap: '\$${_formatMarketCap(343.01e6)}',
                  change: '-8.51%',
                  isPositive: false,
                  isNativeToken: false,
                  chain: 'ethereum',
                  tokenName: 'eth',
                  tokenIcon: 'TRIA.png',
                ),
                AlphaTokenCard(
                  name: 'MGO',
                  price: '\$${_formatPrice(0.02)}',
                  marketCap: '\$${_formatMarketCap(273.18e6)}',
                  change: '-1.81%',
                  isPositive: false,
                  isNativeToken: false,
                  chain: 'bnb',
                  tokenName: 'bnb',
                  tokenIcon: 'MGO.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustPremiumSection() {
    final textColor = ThemeHelper.getTextColor(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.trustPremium,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          const TrustPremiumCard(),
        ],
      ),
    );
  }

  Widget _buildEarnSection() {
    final textColor = ThemeHelper.getTextColor(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.earnSection,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                EarnCard(
                  yieldPercentage: '26.87%',
                  productName: 'Stargaze',
                  iconPath: 'assets/chain_icons/stargaze.png',
                ),
                EarnCard(
                  yieldPercentage: '23.53%',
                  productName: 'Juno',
                  iconPath: 'assets/chain_icons/juno.png',
                ),
                EarnCard(
                  yieldPercentage: '15.90%',
                  productName: 'Cosmos',
                  iconPath: 'assets/chain_icons/cosmos hub.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFooterDisclaimer() {
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)!.pastPerformanceDisclaimer,
                ),
                TextSpan(
                  text: AppLocalizations.of(context)!.subjectToTerms,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Handle terms tap
                    },
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    // Home is index 0
    return CustomBottomNavigationBar(
      selectedIndex: 0,
      showEarnBadge: _showEarnBadge,
      onItemTapped: (index) {
        // Handle navigation to different screens based on index
        if (index == 0) {
          // Already on Home
          return;
        } else if (index == 1) {
          // Trending
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TrendingTokensScreen(),
            ),
          );
        } else if (index == 2) {
          // Trade
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TradeScreen(),
            ),
          );
        } else if (index == 3) {
          // Earn screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EarnScreen(),
            ),
          );
        } else if (index == 4) {
          // Discover screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DiscoverScreen(),
            ),
          );
        }
      },
    );
  }
}
