import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/token_image.dart';
import '../../widgets/prediction_card.dart';
import '../../widgets/token_list_item.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';
import '../../services/earn_storage.dart';
import '../home/home_screen.dart';
import '../home/trending_tokens_screen.dart';
import '../earn/earn_screen.dart';
import '../discover/discover_screen.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  int _selectedTabIndex = 0; // 0 = Swap, 1 = Predictions, 2 = Perps, 3 = Meme Rush
  Map<String, dynamic>? _fromAsset; // Largest holding asset
  final TextEditingController _fromAmountController = TextEditingController();
  double _fromAmountUsd = 0.0;
  double? _fromTokenPrice; // Price in USD for the from token
  double _toAmount = 0.0; // Calculated amount for TWT
  double _toAmountUsd = 0.0; // USD value of TWT amount
  bool _isCalculating = false; // Loading state for exchange rate calculation
  double? _toTokenPrice; // TWT price in USD
  int _selectedCategoryIndex = 0; // 0 = Trending, 1 = All, 2 = Ending, etc.
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _perpsMarkets = []; // Markets data for Perps tab
  bool _isLoadingPerpsMarkets = false;
  int _selectedMemeRushFilter = 0; // 0 = X Mode, 1 = New, 2 = Finalizing
  bool _showMemeRushWarning = true; // Show warning banner at bottom
  bool _showEarnBadge = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultFromAsset();
    _fromAmountController.addListener(_onFromAmountChanged);
    _loadPerpsMarkets();
    _checkEarnVisited();
  }

  Future<void> _checkEarnVisited() async {
    final hasVisited = await EarnStorage.hasVisitedEarn();
    setState(() {
      _showEarnBadge = !hasVisited;
    });
  }

  @override
  void dispose() {
    _fromAmountController.removeListener(_onFromAmountChanged);
    _fromAmountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onFromAmountChanged() async {
    final text = _fromAmountController.text.trim();
    
    if (text.isEmpty) {
      setState(() {
        _fromAmountUsd = 0.0;
        _toAmount = 0.0;
        _toAmountUsd = 0.0;
        _isCalculating = false;
      });
      return;
    }

    final amount = double.tryParse(text) ?? 0.0;
    if (amount <= 0) {
      setState(() {
        _fromAmountUsd = 0.0;
        _toAmount = 0.0;
        _toAmountUsd = 0.0;
        _isCalculating = false;
      });
      return;
    }

    // Calculate USD value for from token
    if (_fromTokenPrice != null && _fromTokenPrice! > 0) {
      setState(() {
        _fromAmountUsd = amount * _fromTokenPrice!;
        _isCalculating = true;
        _toAmount = 0.0;
        _toAmountUsd = 0.0;
      });
    } else {
      setState(() {
        _fromAmountUsd = 0.0;
        _isCalculating = true;
        _toAmount = 0.0;
        _toAmountUsd = 0.0;
      });
    }

    // Fetch TWT price and calculate exchange rate
    try {
      // Fetch TWT price if not already cached
      if (_toTokenPrice == null) {
        final twtPriceData = await ApiService.getTokenPriceWithChange('TWT');
        if (twtPriceData != null && mounted) {
          _toTokenPrice = twtPriceData['priceUsd'] as double?;
        }
      }

      // Calculate exchange rate and to amount
      if (_fromTokenPrice != null && 
          _fromTokenPrice! > 0 && 
          _toTokenPrice != null && 
          _toTokenPrice! > 0 && 
          mounted) {
        // Exchange rate = fromTokenPrice / toTokenPrice
        final exchangeRate = _fromTokenPrice! / _toTokenPrice!;
        final calculatedToAmount = amount * exchangeRate;
        final calculatedToAmountUsd = calculatedToAmount * _toTokenPrice!;

        if (mounted) {
          setState(() {
            _toAmount = calculatedToAmount;
            _toAmountUsd = calculatedToAmountUsd;
            _isCalculating = false;
          });
        }
      } else if (mounted) {
        setState(() {
          _toAmount = 0.0;
          _toAmountUsd = 0.0;
          _isCalculating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _toAmount = 0.0;
          _toAmountUsd = 0.0;
          _isCalculating = false;
        });
      }
    }
  }

  Future<void> _loadDefaultFromAsset() async {
    try {
      final walletId = await WalletStorage.getWalletId();
      if (walletId == null || walletId.isEmpty) return;

      final response = await ApiService.getWalletBalances(walletId);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final balances = data['balances'] as List<dynamic>? ?? [];

        Map<String, dynamic>? best;
        double bestBalance = 0.0;

        for (final raw in balances) {
          if (raw is! Map<String, dynamic>) continue;
          final balanceStr = raw['balance']?.toString() ?? '0';
          final balance = double.tryParse(balanceStr) ?? 0.0;
          if (balance > bestBalance) {
            bestBalance = balance;
            best = raw;
          }
        }

        if (!mounted || best == null) return;

        final symbol = (best['symbol']?.toString() ?? '').toUpperCase();
        final chain = best['chain']?.toString() ?? '';

        // Fetch token price for USD calculation
        double? tokenPrice;
        try {
          final priceData = await ApiService.getTokenPriceWithChange(symbol);
          tokenPrice = priceData?['priceUsd'] as double?;
        } catch (_) {
          // Silent fail, price will remain null
        }

        setState(() {
          _fromAsset = {
            'symbol': symbol,
            'chain': chain,
            'balance': bestBalance,
          };
          _fromTokenPrice = tokenPrice;
        });
      }
    } catch (_) {
      // Silent fail; From card will use default placeholder
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom top bar
          SafeArea(
            bottom: false,
            child: _buildTopBar(textColor, secondaryTextColor),
          ),
          _buildTabBar(textColor, secondaryTextColor),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: _selectedTabIndex == 1 || _selectedTabIndex == 3 ? 20 : 16),
              child: _buildTabContent(textColor, secondaryTextColor),
            ),
          ),
          // Bottom section with border and Continue button (only for Swap tab)
          if (_selectedTabIndex == 0)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: secondaryTextColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: _buildContinueButton(textColor, secondaryTextColor),
            ),
          // Warning banner at bottom (only for Meme Rush tab)
          if (_selectedTabIndex == 3 && _showMemeRushWarning)
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E7), // Light yellow/beige
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  top: BorderSide(
                    color: secondaryTextColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meme tokens can be fun but also volatile. Always do your own research and trade carefully.',
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            // TODO: Handle continue
                          },
                          child: Text(
                            AppLocalizations.of(context)!.continueButton,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showMemeRushWarning = false;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 2,
        showEarnBadge: _showEarnBadge,
        onItemTapped: (index) {
          if (index == 2) {
            // Already on Trade
            return;
          } else if (index == 0) {
            // Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          } else if (index == 1) {
            // Trending
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TrendingTokensScreen(),
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

  Widget _buildTabBar(Color textColor, Color secondaryTextColor) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      l10n.swap,
      l10n.predictionsNew,
      l10n.perps,
      l10n.memeRush,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          // Active tab: dark black and bold, inactive: secondary text color
          final tabColor = isSelected ? Colors.black : secondaryTextColor;
          final fontWeight = isSelected ? FontWeight.w700 : FontWeight.w500;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              tabs[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: fontWeight,
                                color: tabColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (index == 1) ...[
                            // Predictions tab - add New badge
                            const SizedBox(width: 4),
                            _buildNewBadge(secondaryTextColor),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Measure text width
                      final textSpan = TextSpan(
                        text: tabs[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: fontWeight,
                        ),
                      );
                      final textPainter = TextPainter(
                        text: textSpan,
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout();
                      double totalWidth = textPainter.size.width;
                      
                      // If Predictions tab, add badge width and spacing
                      if (index == 1) {
                        // Badge width: icon (10) + spacing (3) + "New" text + padding (6*2 = 12)
                        final badgeTextSpan = TextSpan(
                          text: 'New',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                        final badgeTextPainter = TextPainter(
                          text: badgeTextSpan,
                          textDirection: TextDirection.ltr,
                        );
                        badgeTextPainter.layout();
                        final badgeWidth = 10 + 3 + badgeTextPainter.size.width + 12; // icon + spacing + text + padding
                        totalWidth += 4 + badgeWidth; // spacing (4) + badge width
                      }
                      
                      return Container(
                        height: 2,
                        width: totalWidth,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopBar(Color textColor, Color secondaryTextColor) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: _buildTopBarContent(textColor, secondaryTextColor),
    );
  }

  Widget _buildTopBarContent(Color textColor, Color secondaryTextColor) {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedTabIndex == 1) {
      // Predictions tab: Person icon, Trade text, Info icon
      return Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.person,
              color: secondaryTextColor,
            ),
            onPressed: () {
              // TODO: open profile
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
          Text(
            'Trade',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: secondaryTextColor,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  'i',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            onPressed: () {
              // TODO: show info
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      );
    } else if (_selectedTabIndex == 3) {
      // Meme Rush tab: BNB button, Swap text, Info icon
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: GestureDetector(
              onTap: () {
                // TODO: Handle BNB button
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/blue_lightning.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.bolt_outlined,
                        size: 20,
                        color: AppColors.primaryBlue,
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '0.005BNB',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            l10n.swap,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: secondaryTextColor,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  'i',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            onPressed: () {
              // TODO: show info
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      );
    } else if (_selectedTabIndex == 2) {
      // Perps tab: Person icon, Swap text, Info icon, Settings icon
      return Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.person_outline,
              color: secondaryTextColor,
            ),
            onPressed: () {
              // TODO: open profile
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
          Text(
            l10n.swap,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: secondaryTextColor,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  'i',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            onPressed: () {
              // TODO: show info
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: secondaryTextColor,
            ),
            onPressed: () {
              // TODO: open settings
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      );
    } else {
      // Swap tab: History icon, Swap text, Settings icon
      return Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: secondaryTextColor,
            ),
            onPressed: () {
              // TODO: open swap history
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
          Text(
            l10n.swap,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                // TODO: slippage/settings
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune,
                      size: 14,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '2%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildNewBadge(Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.rocket_launch,
            size: 10,
            color: secondaryTextColor,
          ),
          const SizedBox(width: 3),
          Text(
            AppLocalizations.of(context)!.newLabel,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(Color textColor, Color secondaryTextColor) {
    if (_selectedTabIndex == 0) {
      return _buildSwapContent(textColor, secondaryTextColor);
    } else if (_selectedTabIndex == 1) {
      return _buildPredictionsContent(textColor, secondaryTextColor);
    } else if (_selectedTabIndex == 2) {
      return _buildPerpsContent(textColor, secondaryTextColor);
    } else {
      return _buildMemeRushContent(textColor, secondaryTextColor);
    }
  }

  Future<void> _loadPerpsMarkets() async {
    if (_isLoadingPerpsMarkets) return;
    
    setState(() {
      _isLoadingPerpsMarkets = true;
    });

    try {
      // Fetch top tokens - we'll filter for specific coins
      final tokens = await ApiService.getTopTokens(limit: 50);
      
      // Filter for specific coins: BTC, ETH, BNB, SOL
      final targetSymbols = ['BTC', 'ETH', 'BNB', 'SOL'];
      final filteredTokens = <dynamic>[];
      
      // Build a map by symbol for easier lookup
      final Map<String, dynamic> bySymbol = {};
      for (final t in tokens) {
        if (t is Map<String, dynamic>) {
          final sym = (t['symbol'] as String? ?? '').toUpperCase();
          if (sym.isNotEmpty) {
            bySymbol[sym] = t;
          }
        }
      }
      
      // Add tokens in the desired order
      for (final symbol in targetSymbols) {
        final token = bySymbol[symbol];
        if (token != null) {
          filteredTokens.add(token);
        }
      }

      if (mounted) {
        setState(() {
          _perpsMarkets = filteredTokens;
          _isLoadingPerpsMarkets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPerpsMarkets = false;
        });
      }
    }
  }

  Widget _buildPerpsContent(Color textColor, Color secondaryTextColor) {
    final cardColor = const Color(0xFFF4F4F6);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        // Trade Perps card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Infinity icon (using perps.png image) - 136x84
              Image.asset(
                'assets/images/perps.png',
                width: 136,
                height: 84,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.all_inclusive,
                    size: 84,
                    color: AppColors.primaryBlue,
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.tradePerps,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.tradePerpsDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Handle deposit
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.deposit,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Markets section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.markets,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: secondaryTextColor,
              ),
              onPressed: () {
                // TODO: View all markets
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Markets list - using TokenListItem similar to Popular tokens
        if (_isLoadingPerpsMarkets)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_perpsMarkets.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No markets available',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ..._perpsMarkets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final token = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < _perpsMarkets.length - 1 ? 12 : 0,
                    ),
                    child: _buildMarketItemAsTokenListItem(token, index + 1),
                  );
                }).toList(),
                const SizedBox(height: 16),
                // Separator above "View all"
                Container(
                  height: 1,
                  color: ThemeHelper.getBorderColor(context),
                ),
                const SizedBox(height: 12),
                // View all link - centered
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: View all markets
                    },
                    child: Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMemeRushContent(Color textColor, Color secondaryTextColor) {
    final cardColor = const Color(0xFFF4F4F6);
    
    // Sample meme tokens from token_icons folder
    final memeTokens = [
      {'name': 'NZOS', 'icon': 'war_token.png', 'chain': 'solana', 'age': '3m', 'holders': '0', 'score': '1/5', 'mcap': 'N/A', 'change': '0%'},
      {'name': 'Manyu', 'icon': 'Manyu_token.png', 'chain': 'ethereum', 'age': '5m', 'holders': '12', 'score': '2/5', 'mcap': '\$10.11M', 'change': '+14.87%'},
      {'name': 'Jelly', 'icon': 'jelly-my-jelly_token.png', 'chain': 'solana', 'age': '8m', 'holders': '45', 'score': '3/5', 'mcap': '\$57.1M', 'change': '+12.34%'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        // Horizontal scrollable bar with all options
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMemeRushFilterChip(
                'X Mode',
                null,
                'assets/icons/blue_lightning.png',
                0,
                textColor,
                secondaryTextColor,
              ),
              const SizedBox(width: 8),
              _buildMemeRushFilterChip(
                AppLocalizations.of(context)!.newLabel,
                Icons.settings_outlined,
                null,
                1,
                textColor,
                secondaryTextColor,
              ),
              const SizedBox(width: 8),
              _buildMemeRushFilterChip(
                'Finalizing',
                Icons.local_fire_department,
                null,
                2,
                textColor,
                secondaryTextColor,
              ),
              const SizedBox(width: 8),
              _buildMemeRushFilterChip(
                'Migrated',
                Icons.school_outlined,
                null,
                3,
                textColor,
                secondaryTextColor,
              ),
              const SizedBox(width: 8),
              _buildMemeRushFilterChip(
                'X Mode Leaderboard',
                null,
                'assets/icons/blue_medal.png',
                4,
                textColor,
                secondaryTextColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Table headers
        Row(
          children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Text(
                      'Age',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_downward,
                      size: 12,
                      color: secondaryTextColor,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  'Holders',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Score',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'MCap',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Token list
        ...memeTokens.map((token) => _buildMemeRushTokenItem(
          token,
          textColor,
          secondaryTextColor,
          cardColor,
        )),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMemeRushFilterChip(
    String label,
    IconData? icon,
    String? iconPath,
    int index,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final isSelected = _selectedMemeRushFilter == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMemeRushFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconPath != null)
              iconPath.contains('medal')
                  ? ClipOval(
                      child: Image.asset(
                        iconPath,
                        width: 16,
                        height: 16,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            icon ?? Icons.help_outline,
                            size: 16,
                            color: isSelected ? textColor : secondaryTextColor,
                          );
                        },
                      ),
                    )
                  : Image.asset(
                      iconPath,
                      width: 16,
                      height: 16,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          icon ?? Icons.help_outline,
                          size: 16,
                          color: isSelected ? textColor : secondaryTextColor,
                        );
                      },
                    )
            else if (icon != null)
              Icon(
                icon,
                size: 16,
                color: isSelected ? textColor : secondaryTextColor,
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? textColor : secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemeRushOptionButton(
    String label,
    IconData icon,
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // TODO: Handle button tap
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: secondaryTextColor,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemeRushTokenItem(
    Map<String, String> token,
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Left side: token icon only
          TokenImage(
            isNativeToken: false,
            chain: token['chain'],
            tokenAssetName: token['icon'],
          ),
          const SizedBox(width: 12),
          // Middle: Token name and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      token['name'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 10,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            token['score'] ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${token['mcap']} ${token['change']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      token['age'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      token['holders'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right side: Lightning icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD4D3F3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/blue_lightning.png',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.bolt,
                    size: 20,
                    color: AppColors.primaryBlue,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketItemAsTokenListItem(dynamic token, int rank) {
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    
    final symbol = (token['symbol'] as String? ?? '').toUpperCase();
    final name = token['name'] as String? ?? '';
    final priceUsd = token['priceUsd'] as num? ?? 0.0;
    final change24hPct = token['changePercent24Hr'] as num? ?? 0.0;
    final volumeUsd24Hr = token['volumeUsd24Hr'] as num? ?? 0.0;
    
    // Determine leverage (x200 for BTC, ETH, BNB; x100 for SOL)
    final leverage = symbol == 'SOL' ? 'x100' : 'x200';
    
    // Format volume
    String volumeStr = _formatVolume(volumeUsd24Hr.toDouble());
    
    // Format price with commas
    String priceStr = _formatPrice(priceUsd.toDouble());
    
    // Format percentage change
    final changeStr = change24hPct >= 0 
        ? '+${change24hPct.toStringAsFixed(2)}%'
        : '${change24hPct.toStringAsFixed(2)}%';
    final isPositive = change24hPct >= 0;

    // Get token name for icon (matching chain_icons folder)
    String tokenNameForIcon = _getTokenNameForIcon(symbol);

    return Row(
      children: [
        // Token image (no rank number)
        TokenImage(
          isNativeToken: true,
          tokenName: tokenNameForIcon,
        ),
        const SizedBox(width: 12),
        // Main content area
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Token name with badge (left) and Token price (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          '${symbol}USDT',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E5E5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            leverage,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$$priceStr',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Bottom row: Volume (left) and Price change rate (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Vol: $volumeStr',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    changeStr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? AppColors.successGreen : AppColors.errorRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTokenNameForIcon(String symbol) {
    // Map symbols to token names for TokenImage widget
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return 'bitcoin';
      case 'ETH':
        return 'eth';
      case 'BNB':
        return 'bnb';
      case 'SOL':
        return 'solana';
      default:
        return 'bitcoin'; // fallback
    }
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(1)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return price.toStringAsFixed(4);
  }

  Widget _buildPredictionsContent(Color textColor, Color secondaryTextColor) {
    final cardColor = const Color(0xFFF4F4F6);
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
            // Positions value card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Positions value (USD)',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '0.00',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+\$0 (+0.00%)',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Handle view positions
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4D3F3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View my positions',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search and network filter
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 20,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search markets',
                              hintStyle: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'All Networks',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: secondaryTextColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Category filter buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip(
                    'Trending',
                    Icons.local_fire_department,
                    0,
                    textColor,
                    secondaryTextColor,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    'All',
                    Icons.star_outline,
                    1,
                    textColor,
                    secondaryTextColor,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    'Ending',
                    Icons.access_time,
                    2,
                    textColor,
                    secondaryTextColor,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    'Economy',
                    Icons.attach_money,
                    3,
                    textColor,
                    secondaryTextColor,
                  ),
                ],
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
                // TODO: Handle Yes button press
              },
              onNoPressed: () {
                // TODO: Handle No button press
              },
            ),
            const SizedBox(height: 24),
          ],
    );
  }

  Widget _buildCategoryChip(
    String label,
    IconData icon,
    int index,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final isSelected = _selectedCategoryIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapContent(Color textColor, Color secondaryTextColor) {
    final cardColor = const Color(0xFFF4F4F6);

    final fromSymbol = _fromAsset != null && (_fromAsset!['symbol'] as String).isNotEmpty
        ? _fromAsset!['symbol'] as String
        : 'TRX';
    final fromChain = _fromAsset != null && (_fromAsset!['chain'] as String).isNotEmpty
        ? _fromAsset!['chain'] as String
        : 'Tron';
    final fromBalance = _fromAsset != null
        ? (_fromAsset!['balance'] as double)
        : 0.0;
    final fromBalanceStr = fromBalance.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSwapCard(
                  label: AppLocalizations.of(context)!.from,
                  tokenSymbol: fromSymbol,
                  tokenName: fromChain,
                  amountController: _fromAmountController,
                  amountFiat: _fromAmountUsd,
                  walletBalance: fromBalance,
                  walletBalanceText: fromBalanceStr,
                  cardColor: cardColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  showAmountChips: true,
                  isNativeToken: true,
                  chain: fromChain,
                  tokenAssetName: null,
                  onPercentageTap: (percentage) {
                    double amount = 0.0;
                    if (percentage == 0.25) {
                      amount = fromBalance * 0.25;
                    } else if (percentage == 0.5) {
                      amount = fromBalance * 0.5;
                    } else if (percentage == 1.0) {
                      amount = fromBalance;
                    }
                    _fromAmountController.text = amount.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
                  },
                ),
                const SizedBox(height: 12), // 12px gap between cards
                _buildSwapCard(
                  label: AppLocalizations.of(context)!.to,
                  tokenSymbol: 'TWT',
                  tokenName: 'BNB Smart Chain',
                  amount: _isCalculating ? '...' : (_toAmount > 0 ? _toAmount.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : '0'),
                  amountFiat: _toAmountUsd,
                  walletBalanceText: '0',
                  cardColor: cardColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  showAmountChips: false,
                  isNativeToken: false,
                  chain: 'BNB',
                  tokenAssetName: 'twt.png',
                ),
              ],
            ),
            // Absolutely positioned swap icon - centered between the two cards
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.swap_vert,
                    size: 24,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSwapCard({
    required String label,
    required String tokenSymbol,
    required String tokenName,
    TextEditingController? amountController,
    String? amount, // For "To" card (read-only)
    required double amountFiat, // USD value
    double? walletBalance, // For percentage calculations
    required String walletBalanceText,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required bool showAmountChips,
    required bool isNativeToken,
    required String chain,
    String? tokenAssetName,
    Function(double)? onPercentageTap, // Callback for percentage buttons
  }) {
    final isEditable = amountController != null;
    final amountFiatStr = amountFiat > 0 
        ? '\$${amountFiat.toStringAsFixed(2)}'
        : '\$0';
    return Container(
      height: 140, // Fixed height to ensure both cards are the same height
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    walletBalanceText,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                  if (showAmountChips && walletBalance != null && onPercentageTap != null) ...[
                    const SizedBox(width: 12),
                    _buildAmountChip('25%', () => onPercentageTap(0.25)),
                    const SizedBox(width: 6),
                    _buildAmountChip('50%', () => onPercentageTap(0.5)),
                    const SizedBox(width: 6),
                    _buildAmountChip('Max', () => onPercentageTap(1.0)),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TokenImage(
                isNativeToken: isNativeToken,
                tokenName: isNativeToken ? tokenName.toLowerCase() : null,
                chain: isNativeToken ? null : chain,
                tokenAssetName: tokenAssetName,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tokenSymbol,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tokenName,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isEditable)
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: secondaryTextColor.withOpacity(0.5),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    )
                  else
                    Text(
                      amount ?? '0',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    amountFiatStr,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE3E3FF),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(Color textColor, Color secondaryTextColor) {
    final text = _fromAmountController.text.trim();
    final parsedAmount = double.tryParse(text);
    final hasValidAmount = text.isNotEmpty && 
                          parsedAmount != null &&
                          parsedAmount > 0;
    
    // Button is active only when calculation is complete and toAmount is calculated
    final isActive = !_isCalculating && hasValidAmount && _toAmount > 0;
    final l10n = AppLocalizations.of(context)!;
    final buttonText = _isCalculating ? 'Loading...' : l10n.continueButton;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isActive ? () {
          // TODO: implement swap preview
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive 
              ? AppColors.primaryBlue 
              : const Color(0xFFDEDAFD), // Light purple when inactive/loading
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: const Color(0xFFDEDAFD),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

