import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/token_section.dart';
import '../../widgets/token_list_item.dart';
import '../home/home_screen.dart';
import '../home/trending_tokens_screen.dart';
import '../trade/trade_screen.dart';
import '../earn/earn_screen.dart';
import '../earn/stablecoin_earn_screen.dart';
import '../trust_premium/trust_premium_screen.dart';
import '../../services/earn_storage.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _selectedCategoryIndex = 0; // 0 = Featured, 1 = BSC, 2 = DEX, 3 = Lend
  bool _showEarnBadge = true;
  final TextEditingController _searchController = TextEditingController();
  int _bannerPage = 0;
  final PageController _bannerPageController = PageController();

  @override
  void initState() {
    super.initState();
    _checkEarnVisited();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerPageController.dispose();
    super.dispose();
  }

  Future<void> _checkEarnVisited() async {
    final hasVisited = await EarnStorage.hasVisitedEarn();
    setState(() {
      _showEarnBadge = !hasVisited;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Custom top bar
          SafeArea(
            bottom: false,
            child: Container(
              color: isDarkMode ? AppColors.darkBackground : AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Premium button
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to Premium
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icons/premium.png',
                          width: 18,
                          height: 18,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.star,
                              size: 18,
                              color: primaryColor,
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Premium',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Upgrade Level',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: secondaryTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Title
                  Text(
                    AppLocalizations.of(context)!.discover,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  // Menu icon with popup menu
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    offset: const Offset(-16, 36), // Push menu a bit down so icon stays visible
                    icon: Icon(
                      Icons.more_vert,
                      color: textColor,
                    ),
                    onSelected: (value) {
                      // TODO: Handle menu actions
                      // e.g. if (value == 'history') { ... }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'history',
                        child: SizedBox(
                          width: 100, // Slightly wider menu
                          child: Row(
                            children: [
                              Icon(
                                Icons.history,
                                size: 18,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.swapHistory),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'favorites',
                        child: SizedBox(
                          width: 100, // Match width with first item
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 18,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.favorites),
                            ],
                          ),
                        ),
                      ),
                    ],
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
            const SizedBox(height: 16),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: grayColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: secondaryTextColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.searchOrEnterDappUrl,
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
            const SizedBox(height: 20),
            // Trust Premium Banner
            _buildPremiumBanner(textColor, primaryColor, backgroundColor),
            const SizedBox(height: 32),
            // Explore dApps section
            _buildExploreDAppsSection(textColor, secondaryTextColor),
            const SizedBox(height: 32),
            // Latest section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLatestCard(textColor, secondaryTextColor, grayColor),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 4,
        showEarnBadge: _showEarnBadge,
        onItemTapped: (index) {
          if (index == 4) {
            // Already on Discover
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
          }
        },
      ),
    );
  }

  Widget _buildPremiumBanner(Color textColor, Color primaryColor, Color backgroundColor) {
    return SizedBox(
      height: 160, // Increased height to prevent overflow
      child: Stack(
        children: [
          PageView(
            controller: _bannerPageController,
            onPageChanged: (index) {
              setState(() {
                _bannerPage = index;
              });
            },
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrustPremiumScreen(),
                    ),
                  );
                },
                child: _buildBannerSlide(
                  title: 'Trust Premium',
                  description: 'Earn XP and lock TWT for exclusive rewards & benefits',
                  buttonText: 'EARN NOW',
                  primaryColor: primaryColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StablecoinEarnScreen(),
                    ),
                  );
                },
                child: _buildBannerSlide(
                  title: 'Stablecoin Earn',
                  description: 'Grow your stablecoins in-app',
                  buttonText: 'START NOW',
                  primaryColor: primaryColor,
                ),
              ),
            ],
          ),
          // Carousel dots
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCarouselDot(0),
                const SizedBox(width: 4),
                _buildCarouselDot(1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlide({
    required String title,
    required String description,
    required String buttonText,
    required Color primaryColor,
  }) {
    final isDarkMode = ThemeHelper.isDarkMode(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 80,
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? primaryColor : const Color(0xFF84E2FC),
                    border: Border.all(
                      color: primaryColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.black : primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Gold illustration
          Image.asset(
            'assets/images/premium_gold.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                color: Colors.transparent,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselDot(int index) {
    final isActive = index == _bannerPage;
    return Container(
      width: isActive ? 20 : 6,
      height: 2,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildExploreDAppsSection(Color textColor, Color secondaryTextColor) {
    // Get dApp items based on selected tab
    List<TokenItemData> dAppItems;
    
    switch (_selectedCategoryIndex) {
      case 0: // Featured
        dAppItems = [
          TokenItemData(
            rank: 1,
            name: 'Four',
            price: '',
            marketCap: 'FOUR.meme is a go-to platform for easily launching meme tokens on the BSC Ecosy...',
            change: '',
            isPositive: true,
            isNativeToken: false,
            chain: null, // No chain badge for platform icons
            tokenIcon: 'platform_icons/four.meme.png',
          ),
          TokenItemData(
            rank: 2,
            name: 'Aster',
            price: '',
            marketCap: 'Decentralized perpetual contracts. Multi-chain, liquid, secure.',
            change: '',
            isPositive: true,
            isNativeToken: false,
            chain: null,
            tokenIcon: 'platform_icons/aster.dapp.png',
          ),
          TokenItemData(
            rank: 3,
            name: 'Aave',
            price: '',
            marketCap: 'Aave is an Open Source and Non-Custodial protocol to earn interest on deposits ...',
            change: '',
            isPositive: true,
            isNativeToken: false,
            chain: null,
            tokenIcon: 'platform_icons/app.aave.com.png',
          ),
        ];
        break;
      case 1: // BSC
        dAppItems = [
          TokenItemData(
            rank: 1,
            name: 'Four',
            price: '',
            marketCap: 'FOUR.meme is a go-to platform for easily launching meme tokens on the BSC Ecosy...',
            change: '',
            isPositive: true,
            isNativeToken: false,
            chain: null,
            tokenIcon: 'platform_icons/four.meme.png',
          ),
          TokenItemData(
            rank: 2,
            name: 'Aster',
            price: '',
            marketCap: 'Decentralized perpetual contracts. Multi-chain, liquid, secure.',
            change: '',
            isPositive: true,
            isNativeToken: false,
            chain: null,
            tokenIcon: 'platform_icons/aster.dapp.png',
          ),
          TokenItemData(
            rank: 3,
            name: 'Dapp Bay',
            price: '',
            marketCap: 'Discover top dApps on the best dApp store on BSC, opBNB and BNB Greenfield.',
            change: '',
            isPositive: true,
            isNativeToken: false,
            chain: null,
            tokenIcon: 'platform_icons/dappbay.bnbchain.org.png',
          ),
        ];
        break;
      case 2: // DEX
        dAppItems = [
          TokenItemData(
            rank: 1,
            name: 'PancakeSwap',
            price: '',
            marketCap: 'The flippening is coming. Stack \$CAKE on Binance Smart Chain.',
            change: '',
            isPositive: true,
            isNativeToken: false,
            chain: null,
            tokenIcon: 'platform_icons/pancakeswap.finance.png',
          ),
          TokenItemData(
            rank: 2,
            name: 'Uniswap',
            price: '',
            marketCap: 'Swap, earn, and build on the leading decentralized crypto trading protocol.',
            change: '',
            isPositive: true,
            isNativeToken: false,
            chain: null,
            tokenIcon: 'platform_icons/discover_uniswap.png',
          ),
          TokenItemData(
            rank: 3,
            name: 'Raydium AMM',
            price: '',
            marketCap: 'An on-chain order book AMM powering the evolution of DeFi.',
            change: '',
            isPositive: true,
            isNativeToken: false,
            chain: null,
            tokenIcon: 'platform_icons/raydium.io.png',
          ),
        ];
        break;
      case 3: // Lend
      default:
        dAppItems = [
          TokenItemData(
            rank: 1,
            name: 'Aave',
            price: '',
            marketCap: 'Aave is an Open Source and Non-Custodial protocol to earn interest on deposits ...',
            change: '',
            isPositive: true,
            isNativeToken: false,
            chain: null,
            tokenIcon: 'platform_icons/app.aave.com.png',
          ),
        ];
        break;
    }

    final l10n = AppLocalizations.of(context)!;
    return TokenSection(
      title: l10n.exploreDapps,
      tabs: const ['Featured', 'BSC', 'DEX', 'Lend'],
      selectedTabIndex: _selectedCategoryIndex,
      subtitle: '',
      items: dAppItems,
      viewAllText: l10n.seeAll,
      onTabChanged: (index) {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      onViewAll: () {
        // TODO: Navigate to all dApps
      },
    );
  }

  Widget _buildLatestCard(Color textColor, Color secondaryTextColor, Color grayColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grayColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Globe icon
              Image.asset(
                'assets/icons/premium_gem.png',
                width: 48,
                height: 48,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.public,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '🌕',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Introducing Trust Moon',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our accelerator is live! Grow any ...',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                // TODO: Navigate to all latest
              },
              child: Text(
                AppLocalizations.of(context)!.seeAll,
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
    );
  }
}
