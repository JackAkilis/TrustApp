import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../home/home_screen.dart';
import '../home/trending_tokens_screen.dart';
import '../trade/trade_screen.dart';
import '../discover/discover_screen.dart';
import '../../services/earn_storage.dart';

class EarnScreen extends StatefulWidget {
  const EarnScreen({super.key});

  @override
  State<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen> {
  bool _showEarnBadge = true;

  @override
  void initState() {
    super.initState();
    _markAsVisited();
    _checkEarnVisited();
  }

  Future<void> _markAsVisited() async {
    await EarnStorage.setHasVisitedEarn();
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
    final cardColor = const Color(0xFFF4F4F6);

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
                    'Rewards',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          // Body content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            const SizedBox(height: 20),
            // Top illustration
            Center(
              child: Image.asset(
                'assets/animations/empty_wallet.gif',
                width: 200,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: cardColor,
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 80,
                      color: secondaryTextColor,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Level and XP Balance cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Level',
                    '100 XP to Bronze',
                    textColor,
                    secondaryTextColor,
                    cardColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'XP Balance',
                    '0 XP',
                    textColor,
                    secondaryTextColor,
                    cardColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Redeem XP section
            Row(
              children: [
                Text(
                  'Redeem XP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: secondaryTextColor,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B6914), // Brown/bronze color
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Bronze required',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Partner Benefits section
            Text(
              'Partner Benefits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            // Offer cards
            Row(
              children: [
                Expanded(
                  child: _buildOfferCard(
                    header: '\$50',
                    headerColor: const Color(0xFFE91E63), // Pink
                    description: '\$50 hotel coupon with Umy',
                    xpCost: '800XP',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    isEnded: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOfferCard(
                    header: '40% OFF',
                    headerColor: const Color(0xFF2196F3), // Blue
                    description: '40% off eSIM with TonMobile',
                    xpCost: '400XP',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    isEnded: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 3,
        showEarnBadge: _showEarnBadge,
        onItemTapped: (index) {
          if (index == 3) {
            // Already on Earn
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

  Widget _buildStatCard(
    String title,
    String value,
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard({
    required String header,
    required Color headerColor,
    required String description,
    required String xpCost,
    required Color textColor,
    required Color secondaryTextColor,
    required bool isEnded,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    header,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (isEnded)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 10,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'ENDED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  xpCost,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Handle view
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4D3F3),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'View',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
