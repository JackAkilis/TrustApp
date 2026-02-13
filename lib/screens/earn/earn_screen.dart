import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_screen.dart';
import '../home/trending_tokens_screen.dart';
import '../trade/trade_screen.dart';
import '../discover/discover_screen.dart';
import '../../services/earn_storage.dart';
import '../common/loading_screen.dart';

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
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final cardColor = isDarkMode
        ? AppColors.secondaryGray.withOpacity(0.3)
        : const Color(0xFFF4F4F6);
    final cardSurfaceColor = isDarkMode
        ? AppColors.black
        : Colors.white;
    final borderColor = ThemeHelper.getBorderColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Custom top bar
          _buildRewardsTopBar(
            context: context,
            textColor: textColor,
            isDarkMode: isDarkMode,
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
                'assets/images/rewards_main.png',
                width: 160,
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 160,
                    height: 160,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Level',
                    '100 XP to Bronze',
                    textColor,
                    secondaryTextColor,
                    cardSurfaceColor,
                    borderColor,
                    onTap: () {
                      _pushRewardsLoading(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'XP Balance',
                    '0 XP',
                    textColor,
                    secondaryTextColor,
                    cardSurfaceColor,
                    borderColor,
                    onTap: () {
                      _pushRewardsLoading(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Redeem XP section
            Row(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEADDD4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icons/brown_guard.png',
                        width: 14,
                        height: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Bronze required',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
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
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            // Offer cards
            Row(
              children: [
                Expanded(
                  child: _buildOfferCard(
                    context: context,
                    imagePath: 'assets/images/rewards_benefits_1.png',
                    headerColor: const Color(0xFF1FA4FF),
                    title: '40%',
                    subtitle: 'OFF',
                    imageWidth: 53,
                    imageHeight: 53,
                    description: '40% off eSIM with TonMobile',
                    xpCost: '400XP',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    isEnded: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOfferCard(
                    context: context,
                    imagePath: 'assets/images/rewards_benefits_2.png',
                    headerColor: const Color(0xFF00553B),
                    title: '3GB',
                    imageWidth: 101,
                    imageHeight: 40,
                    description: 'Free 3GB Global eSIM (7 days) with Tunz',
                    xpCost: '1000XP',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    isEnded: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Trust Alpha reward section (title above gray card)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _pushRewardsLoading(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            'Trust Alpha',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEADDD4),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/icons/brown_guard.png',
                                  width: 14,
                                  height: 14,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Bronze required',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: secondaryTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Earn ATWO with TWT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF500),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/token_icons/atwo.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            size: 16,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '5M ATWO',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 1,
                            height: 14,
                            color: secondaryTextColor.withOpacity(0.3),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ENDED',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: secondaryTextColor,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: ThemeHelper.getPrimaryColor(context).withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: ThemeHelper.getPrimaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // More benefits card
            Container(
              decoration: BoxDecoration(
                color: cardSurfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              // Remove left and bottom padding so image sits at (0, 0) from left/bottom
              padding: const EdgeInsets.only(top: 16, right: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/more_benefits.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'More benefits coming',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Check back soon',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
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
        selectedIndex: 3,
        showEarnBadge: _showEarnBadge,
        onItemTapped: (index) {
          if (index == 3) {
            // Already on Earn
            return;
          } else if (index == 0) {
            // Home
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
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
          } else if (index == 4) {
            // Discover
            Navigator.push(
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

  Widget _buildRewardsTopBar({
    required BuildContext context,
    required Color textColor,
    required bool isDarkMode,
  }) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: isDarkMode ? AppColors.darkBackground : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Spacer(),
            Text(
              AppLocalizations.of(context)!.rewards,
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
    );
  }

  void _pushRewardsLoading(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          topBarBuilder: (context) => _buildRewardsTopBar(
            context: context,
            textColor: ThemeHelper.getTextColor(context),
            isDarkMode: ThemeHelper.isDarkMode(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color textColor,
    Color secondaryTextColor,
    Color cardSurfaceColor,
    Color borderColor,
    {VoidCallback? onTap}
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardSurfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
            ),
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
        ),
      ),
    );
  }

  Widget _buildOfferCard({
    required BuildContext context,
    required String imagePath,
    required Color headerColor,
    required String title,
    String? subtitle,
    required double imageWidth,
    required double imageHeight,
    required String description,
    required String xpCost,
    required Color textColor,
    required Color secondaryTextColor,
    required bool isEnded,
  }) {
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final cardSurfaceColor = isDarkMode
        ? AppColors.black
        : Colors.white;
    final primaryColor = ThemeHelper.getPrimaryColor(context);

    return Container(
      decoration: BoxDecoration(
        color: cardSurfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Colored header box with logo, text, and ENDED badge
          SizedBox(
            height: 112,
            child: Container(
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (subtitle == null)
                          const SizedBox(height: 12),
                        SizedBox(
                          width: imageWidth,
                          height: imageHeight,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (subtitle != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64CDFF),
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isEnded)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: SizedBox(
                        width: 80,
                        height: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.black : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ENDED',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Content section (no horizontal padding)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
                    onPressed: () => _pushRewardsLoading(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor.withOpacity(0.25),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'View',
                      style: TextStyle(
                        color: primaryColor,
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
