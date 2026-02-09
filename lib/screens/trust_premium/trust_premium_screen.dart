import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_helper.dart';
import 'daily_exchange_swap_screen.dart';

class TrustPremiumScreen extends StatelessWidget {
  const TrustPremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final cardBackgroundColor = isDarkMode
        ? AppColors.secondaryGray.withOpacity(0.3)
        : const Color(0xFFF4F4F6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 100,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: textColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: Image.asset(
                'assets/icons/headset.png',
                width: 24,
                height: 24,
                color: isDarkMode ? textColor : null,
                colorBlendMode: isDarkMode ? BlendMode.srcIn : null,
              ),
              onPressed: () {
                // Handle headphone/support
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        title: Text(
          AppLocalizations.of(context)!.trustPremium,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/circle_star.png',
              width: 24,
              height: 24,
              color: isDarkMode ? textColor : null,
              colorBlendMode: isDarkMode ? BlendMode.srcIn : null,
            ),
            onPressed: () {
              // Handle star
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/icons/circle_info.png',
              width: 24,
              height: 24,
              color: isDarkMode ? textColor : null,
              colorBlendMode: isDarkMode ? BlendMode.srcIn : null,
            ),
            onPressed: () {
              // Handle info
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Bronze Tier Display
            _buildBronzeTierCard(
              context,
              textColor,
              secondaryTextColor,
              primaryColor,
              cardBackgroundColor,
            ),
            const SizedBox(height: 24),
            // My Progress Section
            _buildMyProgressSection(
              context,
              textColor,
              secondaryTextColor,
              primaryColor,
              cardBackgroundColor,
              isDarkMode,
            ),
            const SizedBox(height: 24),
            // Earn More XP Section
            _buildEarnMoreXPSection(
              context,
              textColor,
              secondaryTextColor,
              primaryColor,
              cardBackgroundColor,
              isDarkMode,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBronzeTierCard(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
    Color cardBackgroundColor,
  ) {
    final isDarkMode = ThemeHelper.isDarkMode(context);
    const borderColor = Color(0xFFE0E0E2);
    const bgColor = Color(0xFFF4F4F6);
    final grayColor = ThemeHelper.getGrayColor(context);
    
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDarkMode ? cardBackgroundColor : bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? AppColors.secondaryGray.withOpacity(0.5) : borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side image with gap from border - 50% width
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/crypto_winter.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              // Right side content - 50% width
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bronze',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.levelUp,
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          // Handle see all benefits
                        },
                        child: Text(
                          'See all benefits →',
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
              ),
            ],
          ),
          // "Not started" badge in top-right corner
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.secondaryGray.withOpacity(0.5) : borderColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              child: Text(
                'Not started',
                style: TextStyle(
                  fontSize: 10,
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

  Widget _buildMyProgressSection(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
    Color cardBackgroundColor,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            Icon(
              Icons.info_outline,
              size: 16,
              color: secondaryTextColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Meet 14-day goals to level up.',
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        // XP Progress Card
        _buildXPProgressCard(
          context,
          textColor,
          secondaryTextColor,
          primaryColor,
          cardBackgroundColor,
          isDarkMode,
        ),
        const SizedBox(height: 12),
        // TWT Locked Card
        _buildTWTLockedCard(
          context,
          textColor,
          secondaryTextColor,
          primaryColor,
          cardBackgroundColor,
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildXPProgressCard(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
    Color cardBackgroundColor,
    bool isDarkMode,
  ) {
    const borderColor = Color(0xFFE0E0E2);
    const bgColor = Color(0xFFF4F4F6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? cardBackgroundColor : bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? AppColors.secondaryGray.withOpacity(0.5) : borderColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  children: [
                    TextSpan(
                      text: '0',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const TextSpan(text: '/100 XP'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.secondaryGray.withOpacity(0.5)
                      : borderColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Jan 13 - Jan 27',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.secondaryGray.withOpacity(0.5)
                      : AppColors.secondaryGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '100 more XP to Bronze',
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTWTLockedCard(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
    Color cardBackgroundColor,
    bool isDarkMode,
  ) {
    const borderColor = Color(0xFFE0E0E2);
    const bgColor = Color(0xFFF4F4F6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? cardBackgroundColor : bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? AppColors.secondaryGray.withOpacity(0.5) : borderColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              children: [
                TextSpan(
                  text: '0',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const TextSpan(text: '/50 TWT locked'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.secondaryGray.withOpacity(0.5)
                      : AppColors.secondaryGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Reach Bronze to activate.',
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: isDarkMode
                ? AppColors.secondaryGray.withOpacity(0.5)
                : borderColor,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle more operations
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? AppColors.primaryGreen.withOpacity(0.1)
                        : AppColors.primaryBlue.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'More operations',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? AppColors.primaryGreen
                          : AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle lock TWT
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Lock TWT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppColors.darkBackground : AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarnMoreXPSection(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
    Color cardBackgroundColor,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earn more XP',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        // All-time XP Card
        _buildAllTimeXPCard(
          context,
          textColor,
          secondaryTextColor,
          primaryColor,
          cardBackgroundColor,
        ),
        const SizedBox(height: 12),
        // Daily Check-in Card
        _buildDailyCheckInCard(
          context,
          textColor,
          secondaryTextColor,
          primaryColor,
          cardBackgroundColor,
          isDarkMode,
        ),
        const SizedBox(height: 12),
        // Daily Exchange Card
        _buildDailyExchangeCard(
          context,
          textColor,
          secondaryTextColor,
          primaryColor,
          cardBackgroundColor,
          isDarkMode,
        ),
        const SizedBox(height: 12),
        // Binance Deposit Card
        _buildBinanceDepositCard(
          context,
          textColor,
          secondaryTextColor,
          primaryColor,
          cardBackgroundColor,
          isDarkMode,
        ),
        const SizedBox(height: 24),
        // Disclaimer Section
        _buildDisclaimerSection(
          context,
          textColor,
          secondaryTextColor,
          cardBackgroundColor,
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildAllTimeXPCard(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
    Color cardBackgroundColor,
  ) {
    final isDarkMode = ThemeHelper.isDarkMode(context);
    const borderColor = Color(0xFFE0E0E2);
    const bgColor = Color(0xFFF4F4F6);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? cardBackgroundColor : bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? AppColors.secondaryGray.withOpacity(0.5) : borderColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All-time XP',
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                    children: [
                      TextSpan(
                        text: '+0',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.successGreen,
                        ),
                      ),
                      const TextSpan(text: ' to claim'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle claim XP
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor.withOpacity(0.1), // semi blue/green (inactive)
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              elevation: 0,
            ),
            child: Text(
              'Claim XP',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white, // white text
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCheckInCard(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
    Color cardBackgroundColor,
    bool isDarkMode,
  ) {
    const borderColor = Color(0xFFE0E0E2);
    const bgColor = Color(0xFFF4F4F6);
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? cardBackgroundColor : bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? AppColors.secondaryGray.withOpacity(0.5) : borderColor,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                'Daily check-in',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                  children: [
                    TextSpan(
                      text: '0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: secondaryTextColor,
                      ),
                    ),
                    const TextSpan(text: '/7'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Progress line with 7 circles (days) and x1.5 markers
              SizedBox(
                height: 40,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final segmentWidth = totalWidth / 7;
                    final firstCircleSize = 15.0;
                    final lastCircleSize = 15.0; // Day 7 is not a bonus day
                    
                    // Calculate line start (left edge of first circle)
                    final lineStart = (segmentWidth / 2) - (firstCircleSize / 2);
                    // Calculate line end (right edge of last circle)
                    final lineEnd = totalWidth - (segmentWidth / 2) - (lastCircleSize / 2);
                    final lineWidth = lineEnd - lineStart;
                    
                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Background line - from left edge of first circle to right edge of last circle
                        Positioned(
                          left: lineStart,
                          top: 19, // Center vertically (40/2 - 2/2)
                          child: Container(
                            width: lineWidth,
                            height: 2,
                            color: isDarkMode
                                ? AppColors.secondaryGray.withOpacity(0.5)
                                : const Color(0xFFD9D9D9),
                          ),
                        ),
                        // Circles
                        Row(
                          children: List.generate(7, (index) {
                            final isFirst = index == 0;
                            final hasBonus = index == 2 || index == 5;

                            return Expanded(
                              child: Center(
                                child: Container(
                                  width: hasBonus ? 25 : 15,
                                  height: hasBonus ? 25 : 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isFirst
                                        ? (isDarkMode
                                            ? AppColors.primaryGreen.withOpacity(0.1)
                                            : AppColors.primaryBlue.withOpacity(0.1))
                                        : cardBackgroundColor,
                                    border: Border.all(
                                      color: isFirst
                                          ? (isDarkMode
                                              ? AppColors.primaryGreen.withOpacity(0.4)
                                              : AppColors.primaryBlue.withOpacity(0.4)) // semi blue/green
                                          : secondaryTextColor.withOpacity(0.6),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: hasBonus
                                        ? Text(
                                            'x1.5',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: secondaryTextColor,
                                            ),
                                          )
                                        : isFirst
                                            ? Container(
                                                width: 5,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  color: isDarkMode
                                                      ? AppColors.primaryGreen
                                                      : AppColors.primaryBlue,
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: isDarkMode
                    ? AppColors.secondaryGray.withOpacity(0.5)
                    : borderColor,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle begin
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.begin,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? AppColors.darkBackground : AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: isDarkMode ? AppColors.darkBackground : AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
              ],
            ),
          ),
          // "10 XP/day" badge in top-right corner (matching "Not started" style)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.secondaryGray.withOpacity(0.5) : borderColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 10,
                    color: textColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '10 XP/day',
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor,
                      fontWeight: FontWeight.w500,
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

  Widget _buildDailyExchangeCard(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
    Color cardBackgroundColor,
    bool isDarkMode,
  ) {
    const borderColor = Color(0xFFE0E0E2);
    const bgColor = Color(0xFFF4F4F6);
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? cardBackgroundColor : bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? AppColors.secondaryGray.withOpacity(0.5) : borderColor,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Exchange',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                    children: [
                      TextSpan(
                        text: '\$0.00',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: secondaryTextColor,
                        ),
                      ),
                      TextSpan(text: ' /\$1,000.00'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.secondaryGray.withOpacity(0.5)
                            : AppColors.secondaryGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Up to 500 XP for swapping \$100, \$300, \$500 or \$1000 across Ethereum, BNB Smart Chain, Solana and Base',
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DailyExchangeSwapScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.begin,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? AppColors.darkBackground : AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: isDarkMode ? AppColors.darkBackground : AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // "Up to 500 XP/day" badge in top-right corner
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.secondaryGray.withOpacity(0.5) : borderColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 10,
                    color: textColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Up to 500 XP/day',
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor,
                      fontWeight: FontWeight.w500,
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

  Widget _buildBinanceDepositCard(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
    Color cardBackgroundColor,
    bool isDarkMode,
  ) {
    const borderColor = Color(0xFFE0E0E2);
    const bgColor = Color(0xFFF4F4F6);
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? cardBackgroundColor : bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? AppColors.secondaryGray.withOpacity(0.5) : borderColor,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Binance deposit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                    children: [
                      TextSpan(
                        text: '0',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: secondaryTextColor,
                        ),
                      ),
                      const TextSpan(text: '/6'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Progress line with 6 circles
                SizedBox(
                  height: 40,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      final segmentWidth = totalWidth / 6;
                      final circleSize = 15.0;
                      
                      // Calculate line start (left edge of first circle)
                      final lineStart = (segmentWidth / 2) - (circleSize / 2);
                      // Calculate line end (right edge of last circle)
                      final lineEnd = totalWidth - (segmentWidth / 2) - (circleSize / 2);
                      final lineWidth = lineEnd - lineStart;
                      
                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // Background line - from left edge of first circle to right edge of last circle
                          Positioned(
                            left: lineStart,
                            top: 19, // Center vertically (40/2 - 2/2)
                            child: Container(
                              width: lineWidth,
                              height: 2,
                              color: isDarkMode
                                  ? AppColors.secondaryGray.withOpacity(0.5)
                                  : const Color(0xFFD9D9D9),
                            ),
                          ),
                          // Circles
                          Row(
                            children: List.generate(6, (index) {
                              final isCompleted = index == 0;

                              return Expanded(
                                child: Center(
                                  child: Container(
                                    width: circleSize,
                                    height: circleSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCompleted
                                          ? (isDarkMode
                                              ? AppColors.primaryGreen.withOpacity(0.1)
                                              : AppColors.primaryBlue.withOpacity(0.1))
                                          : cardBackgroundColor,
                                      border: Border.all(
                                        color: isCompleted
                                            ? (isDarkMode
                                                ? AppColors.primaryGreen.withOpacity(0.4)
                                                : AppColors.primaryBlue.withOpacity(0.4)) // semi blue/green
                                            : secondaryTextColor.withOpacity(0.6),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: isCompleted
                                          ? Container(
                                              width: 5,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: isDarkMode
                                                    ? AppColors.primaryGreen
                                                    : AppColors.primaryBlue,
                                                shape: BoxShape.circle,
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '50 XP for each deposit, per network, per week. There are 6 eligible networks.',
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle begin
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.begin,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? AppColors.darkBackground : AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: isDarkMode ? AppColors.darkBackground : AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // "10 XP/day" badge in top-right corner
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.secondaryGray.withOpacity(0.5) : borderColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 10,
                    color: textColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '10 XP/day',
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor,
                      fontWeight: FontWeight.w500,
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

  Widget _buildDisclaimerSection(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color cardBackgroundColor,
    bool isDarkMode,
  ) {
    const bgColor = Color(0xFFF4F4F6);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? cardBackgroundColor : bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/icons/info_black.png',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "If experience points are not claimed within 3 months, they'll be removed. ANY Claimed XP must be used within 12 months.",
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
