import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/earn_storage.dart';
import '../../constants/app_colors.dart';
import 'home_screen.dart';
import '../trade/trade_screen.dart';
import '../earn/earn_screen.dart';
import '../discover/discover_screen.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/token_list_item.dart';
import '../../widgets/token_section.dart';

class TrendingTokensScreen extends StatefulWidget {
  const TrendingTokensScreen({super.key});

  @override
  State<TrendingTokensScreen> createState() => _TrendingTokensScreenState();
}

class _TrendingTokensScreenState extends State<TrendingTokensScreen> {
  // Tabs for embedded sections
  int _topMoversTabIndex = 0;
  int _popularTokensTabIndex = 0;
  bool _showEarnBadge = true;

  @override
  void initState() {
    super.initState();
    _checkEarnVisited();
  }

  Future<void> _checkEarnVisited() async {
    final hasVisited = await EarnStorage.hasVisitedEarn();
    setState(() {
      _showEarnBadge = !hasVisited;
    });
  }

  // Static list of non‑native tokens used on Home
  final List<_TrendingToken> _trendingTokens = const [
    // Memes
    _TrendingToken(
      name: 'war token',
      price: '\$0.01',
      marketCap: 'MCap: \$18.89M · Vol: \$9.26M',
      change: '+16.57%',
      isPositive: true,
      chain: 'solana',
      tokenIcon: 'war_token.png',
    ),
    _TrendingToken(
      name: 'Manyu (manyushiba.com)',
      price: '<\$0.01',
      marketCap: 'MCap: \$10.11M · Vol: \$6.86M',
      change: '+14.87%',
      isPositive: true,
      chain: 'ethereum',
      tokenIcon: 'Manyu_token.png',
    ),
    _TrendingToken(
      name: 'jelly-my-jelly',
      price: '\$0.05',
      marketCap: 'MCap: \$57.10M · Vol: \$9.45M',
      change: '+9.62%',
      isPositive: true,
      chain: 'solana',
      tokenIcon: 'jelly-my-jelly_token.png',
    ),
    // RWAs
    _TrendingToken(
      name: 'Alphabet Class A (Ondo Tokenized)',
      price: '\$328.21',
      marketCap: 'MCap: \$64.34M · Vol: \$19.06M',
      change: '-4.28%',
      isPositive: false,
      chain: 'bnb',
      tokenIcon: 'Alphabet_token.png',
    ),
    _TrendingToken(
      name: 'Alphabet Class A (Ondo Tokenized)',
      price: '\$328.21',
      marketCap: 'MCap: \$64.34M · Vol: \$19.06M',
      change: '-4.28%',
      isPositive: false,
      chain: 'ethereum',
      tokenIcon: 'Alphabet_token.png',
    ),
    _TrendingToken(
      name: 'iShares Silver Trust (Ondo Tokenized)',
      price: '\$72.26',
      marketCap: 'MCap: \$36.49M · Vol: \$31.96M',
      change: '-11.53%',
      isPositive: false,
      chain: 'bnb',
      tokenIcon: 'iShares_token.png',
    ),
    // AI
    _TrendingToken(
      name: 'Codatta',
      price: '<\$0.01',
      marketCap: 'MCap: \$10.70M · Vol: \$6.06M',
      change: '+15.58%',
      isPositive: true,
      chain: 'bnb',
      tokenIcon: 'codatta_token.png',
    ),
    _TrendingToken(
      name: 'ChainOpera AI',
      price: '\$0.32',
      marketCap: 'MCap: \$60.50M · Vol: \$19.06M',
      change: '+7.43%',
      isPositive: true,
      chain: 'bnb',
      tokenIcon: 'chainopera_token.png',
    ),
    _TrendingToken(
      name: 'iTagger',
      price: '<\$0.01',
      marketCap: 'MCap: \$42.70M · Vol: \$6.10M',
      change: '+6.75%',
      isPositive: true,
      chain: 'bnb',
      tokenIcon: 'tagger_token.png',
    ),
    // Popular section (non‑native)
    _TrendingToken(
      name: 'MemeCore',
      price: '\$1.51',
      marketCap: 'MCap: \$1.91B · Vol: \$16.00M',
      change: '+2.97%',
      isPositive: true,
      chain: 'bnb',
      tokenIcon: 'MemeCore.png',
    ),
    _TrendingToken(
      name: 'MYX Finance',
      price: '\$6.15',
      marketCap: 'MCap: \$1.54B · Vol: \$27.77M',
      change: '+4.47%',
      isPositive: true,
      chain: 'bnb',
      tokenIcon: 'MYX_Finance.png',
    ),
    _TrendingToken(
      name: 'stETH',
      price: '\$2,145.12',
      marketCap: 'MCap: \$20.24B · Vol: \$90.27M',
      change: '-7.07%',
      isPositive: false,
      chain: 'ethereum',
      tokenIcon: 'stETH.png',
    ),
    _TrendingToken(
      name: 'Wrapped liquid staked Ether 2.0',
      price: '\$2,582.55',
      marketCap: 'MCap: \$9.52B · Vol: \$26.09M',
      change: '-7.33%',
      isPositive: false,
      chain: 'ethereum',
      tokenIcon: 'wstEth.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Custom top bar
          SafeArea(
            bottom: false,
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Spacer(),
                  // Title
                  Text(
                    AppLocalizations.of(context)!.trendingTokens,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  // Search icon
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: secondaryTextColor,
                    ),
                    onPressed: () {
                      // TODO: search behavior
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          // Body content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            // Trending header + 5-token list + View all, with 20px horizontal padding
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.trending,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    _trendingTokens.length > 5 ? 5 : _trendingTokens.length,
                    (index) {
                      final token = _trendingTokens[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TokenListItem(
                          rank: index + 1,
                          name: token.name,
                          price: token.price,
                          marketCap: token.marketCap,
                          change: token.change,
                          isPositive: token.isPositive,
                          isNativeToken: false,
                          chain: token.chain,
                          tokenIcon: token.tokenIcon,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: full trending view if needed
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFF4F4F6),
                          foregroundColor: textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.viewAll,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Top movers & Popular tokens beneath Trending section,
            // each already has its own internal padding (20px)
            _buildTopMoversSection(),
            const SizedBox(height: 32),
            _buildPopularTokensSection(),
            const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 1,
        showEarnBadge: _showEarnBadge,
        onItemTapped: (index) {
          if (index == 1) {
            // Already on Trending
            return;
          } else if (index == 0) {
            // Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          } else if (index == 2) {
            // Trade
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TradeScreen(),
              ),
            );
          } else if (index == 3) {
            // Earn
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const EarnScreen(),
              ),
            );
          } else if (index == 4) {
            // Discover
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DiscoverScreen(),
              ),
            );
          }
        },
      ),
    );
  }

  // Helpers copied from HomeScreen so formatting is identical.
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

  String _formatPrice(num value) {
    final negative = value < 0;
    final v = value.abs();
    final fixed = v.toStringAsFixed(2);
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

  Widget _buildTopMoversSection() {
    String subtitle;
    List<TokenItemData> items;

    switch (_topMoversTabIndex) {
      case 0: // Memes
        subtitle = AppLocalizations.of(context)!.topMemeCoinsSubtitle;
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
          ),
        ];
        break;
      case 1: // RWAs
        subtitle = AppLocalizations.of(context)!.realWorldAssetsSubtitle;
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
        subtitle = AppLocalizations.of(context)!.aiPoweredTokensSubtitle;
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
      viewAllText: l10n.viewAll,
      onTabChanged: (index) {
        setState(() {
          _topMoversTabIndex = index;
        });
      },
      onViewAll: () {
        // TODO: full list
      },
    );
  }

  Widget _buildPopularTokensSection() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getTopTokens(limit: 50),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final tokens = snapshot.data ?? [];

        final Map<String, Map<String, dynamic>> bySymbol = {};
        for (final t in tokens) {
          if (t is Map<String, dynamic>) {
            final sym = (t['symbol']?.toString() ?? '').toUpperCase();
            if (sym.isNotEmpty) {
              bySymbol[sym] = t;
            }
          }
        }

        List<TokenItemData> items = [];

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

        if (_popularTokensTabIndex == 0) {
          addFromSymbol('ETH', 1, tokenNameForIcon: 'eth');
          addFromSymbol('BNB', 2, tokenNameForIcon: 'bnb');
          addFromSymbol('SOL', 3, tokenNameForIcon: 'solana');
        } else if (_popularTokensTabIndex == 1) {
          final List<TokenItemData> bnbItems = [];

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
                price: '\$${_formatPrice(price)}',
                marketCap: marketCapText,
                change:
                    '${isPositive ? '+' : ''}${changePct.toStringAsFixed(2)}%',
                isPositive: isPositive,
                isNativeToken: true,
                tokenName: 'bnb',
              ),
            );
          }

          Map<String, dynamic>? findTokenByName(String targetName) {
            for (final dynamic t in tokens) {
              if (t is! Map<String, dynamic>) continue;
              final name = (t['name']?.toString() ?? '').toLowerCase();
              if (name == targetName.toLowerCase()) return t;
            }
            return null;
          }

          final memeToken = findTokenByName('MemeCore');
          final memePrice =
              (memeToken?['priceUsd'] as num?)?.toDouble() ?? 1.51;
          final memeMarketCapValue =
              (memeToken?['marketCapUsd'] as num?)?.toDouble() ??
                  1.91e9;
          final memeVolumeValue =
              (memeToken?['volumeUsd24Hr'] as num?)?.toDouble() ??
                  16.0e6;
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

          final myxToken = findTokenByName('MYX Finance');
          final myxPrice =
              (myxToken?['priceUsd'] as num?)?.toDouble() ?? 6.15;
          final myxMarketCapValue =
              (myxToken?['marketCapUsd'] as num?)?.toDouble() ??
                  1.54e9;
          final myxVolumeValue =
              (myxToken?['volumeUsd24Hr'] as num?)?.toDouble() ??
                  27.77e6;
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
          final List<TokenItemData> ethItems = [];

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

          Map<String, dynamic>? findEthTokenByName(String targetName) {
            for (final dynamic t in tokens) {
              if (t is! Map<String, dynamic>) continue;
              final name = (t['name']?.toString() ?? '').toLowerCase();
              if (name == targetName.toLowerCase()) return t;
            }
            return null;
          }

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

          stEthMarketCapValue ??= 20.24e9;
          stEthVolumeValue ??= 90.27e6;

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

          wlsEthMarketCapValue ??= 9.52e9;
          wlsEthVolumeValue ??= 26.09e6;

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

        final l10n = AppLocalizations.of(context)!;
        return TokenSection(
          title: l10n.popularTokens,
          tabs: [l10n.top, l10n.bnb, l10n.eth],
          selectedTabIndex: _popularTokensTabIndex,
          subtitle: l10n.topTokensByMarketCap,
          items: items,
          viewAllText: l10n.viewAll,
          onTabChanged: (index) {
            setState(() {
              _popularTokensTabIndex = index;
            });
          },
          onViewAll: () {
            // TODO: full list
          },
        );
      },
    );
  }
}

class _TrendingToken {
  final String name;
  final String price;
  final String marketCap;
  final String change;
  final bool isPositive;
  final String chain;
  final String tokenIcon;

  const _TrendingToken({
    required this.name,
    required this.price,
    required this.marketCap,
    required this.change,
    required this.isPositive,
    required this.chain,
    required this.tokenIcon,
  });
}

