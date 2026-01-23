import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/token_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  bool _showBackupBanner = true;
  int _currentBannerPage = 0;
  final PageController _bannerPageController = PageController();
  Timer? _bannerTimer;
  
  @override
  void initState() {
    super.initState();
    _startBannerTimer();
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
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
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
              
              // Empty State Content
              _buildEmptyState(),
              
              const SizedBox(height: 32),
              
              // Top Movers Section
              _buildTopMoversSection(),
              
              const SizedBox(height: 32),
              
              // Popular Tokens Section
              _buildPopularTokensSection(),
              
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Left Icons - Gear
          IconButton(
            icon: Image.asset(
              'assets/icons/setting_gear_icon_20.png',
              width: 20,
              height: 20,
            ),
            onPressed: () {},
          ),
          // Scan Icon
          IconButton(
            icon: Image.asset(
              'assets/icons/scan_icon_20.png',
              width: 20,
              height: 20,
            ),
            onPressed: () {},
          ),
          
          // Center - Wallet Name
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Main Wallet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainBlack,
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
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.mainBlack,
                  size: 20,
                ),
              ],
            ),
          ),
          
          // Right Icons - Copy
          IconButton(
            icon: Image.asset(
              'assets/icons/copy_icon_20.png',
              width: 20,
              height: 20,
            ),
            onPressed: () {},
          ),
          // Search Icon
          IconButton(
            icon: Image.asset(
              'assets/icons/search_icon_20.png',
              width: 20,
              height: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      children: [
        const Text(
          '\$0.00',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: AppColors.mainBlack,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '\$0.00(0%)',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.secondaryGray,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton('Send', 'assets/icons/send_icon.png', false),
          _buildActionButton('Fund', null, true), // Fund uses Material icon (add)
          _buildActionButton('Swap', 'assets/icons/swap_icon.png', false),
          _buildActionButton('Sell', 'assets/icons/sell_icon.png', false),
          _buildActionButton('Earn', 'assets/icons/earn_icon.png', false),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, String? iconPath, bool isPrimary) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primaryBlue : AppColors.mainGray,
            borderRadius: BorderRadius.circular(16),
          ),
          child: iconPath != null
              ? Center(
                  child: Image.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    color: isPrimary ? AppColors.white : null,
                    colorBlendMode: isPrimary ? BlendMode.srcIn : null,
                  ),
                )
              : Icon(
                  Icons.add,
                  color: isPrimary ? AppColors.white : AppColors.mainBlack,
                  size: 28,
                ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.mainBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.mainGray,
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
                  'assets/images/lock1.png',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Back up to secure your assets',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Back up wallet →',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryBlue,
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
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: AppColors.secondaryGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentBannerPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentBannerPage
                ? AppColors.mainBlack
                : AppColors.borderGray,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Crypto', 'Prediction', 'Watchlist', 'NFTs', 'Approvals'];
    
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
                                AppColors.white.withOpacity(0),
                                AppColors.white,
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
                icon: Image.asset(
                  'assets/icons/history_icon.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Image.asset(
                  'assets/icons/control_icon_24.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
        // Gray border - full width, ignoring padding
        Container(
          height: 1,
          color: AppColors.borderGray,
        ),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
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
                  color: isSelected ? AppColors.mainBlack : AppColors.secondaryGray,
                ),
              ),
              const SizedBox(height: 12),
              // Spacer to push underline to bottom
              const SizedBox(height: 0),
            ],
          ),
          // Blue underline - positioned at bottom to overlap gray border
          Positioned(
            bottom: 0, // Position at bottom to align with gray border
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: label.length * 8.0,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
          const Text(
            'Add funds to get started',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.mainBlack,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999), // Fully rounded
                ),
              ),
              child: const Text(
                'Fund your wallet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Manage crypto',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMoversSection() {
    return TokenSection(
      title: 'Top movers',
      tabs: const ['Memes', 'x402', 'RWAs', 'AI'],
      selectedTabIndex: 0,
      subtitle: 'Top Meme coins and tokens (24h % price gain)',
      items: [
        TokenItemData(
          rank: 1,
          name: 'just buy \$1 wor...',
          price: '\$0.003017',
          marketCap: '\$133B',
          change: '+3.09%',
          isPositive: true,
        ),
        TokenItemData(
          rank: 2,
          name: 'just buy \$1 wor...',
          price: '\$0.003017',
          marketCap: '\$133B',
          change: '+3.09%',
          isPositive: true,
        ),
        TokenItemData(
          rank: 3,
          name: 'just buy \$1 wor...',
          price: '\$0.003017',
          marketCap: '\$133B',
          change: '+3.09%',
          isPositive: true,
        ),
      ],
      viewAllText: 'View all >',
      onTabChanged: (index) {
        // Handle tab change
      },
      onViewAll: () {
        // Handle view all
      },
    );
  }

  Widget _buildPopularTokensSection() {
    return TokenSection(
      title: 'Popular tokens',
      tabs: const ['Top', 'BNB', 'ETH'],
      selectedTabIndex: 0,
      subtitle: 'Top tokens by total market cap',
      items: [
        TokenItemData(
          rank: 1,
          name: 'just buy \$1 wor...',
          price: '\$0.003017',
          marketCap: '\$133B',
          change: '-3.09%',
          isPositive: false,
        ),
        TokenItemData(
          rank: 2,
          name: 'just buy \$1 wor...',
          price: '\$0.003017',
          marketCap: '\$133B',
          change: '-3.09%',
          isPositive: false,
        ),
        TokenItemData(
          rank: 3,
          name: 'just buy \$1 wor...',
          price: '\$0.003017',
          marketCap: '\$133B',
          change: '-3.09%',
          isPositive: false,
        ),
      ],
      viewAllText: '查看全部 >',
      onTabChanged: (index) {
        // Handle tab change
      },
      onViewAll: () {
        // Handle view all
      },
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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home, 'Home', 0, true),
              _buildBottomNavItem(Icons.trending_up, 'Trending', 1, false),
              _buildBottomNavItem(Icons.swap_horiz, 'Trade', 2, false),
              _buildBottomNavItem(Icons.eco, 'Earn', 3, false, showDot: true),
              _buildBottomNavItem(Icons.explore, 'Discover', 4, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index, bool isSelected, {bool showDot = false}) {
    return GestureDetector(
      onTap: () {
        // Handle navigation to different screens
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryBlue : AppColors.secondaryGray,
                size: 24,
              ),
              if (showDot && !isSelected)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.primaryBlue : AppColors.secondaryGray,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
