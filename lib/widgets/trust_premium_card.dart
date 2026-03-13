import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../screens/trust_premium/trust_premium_onboarding_screen.dart';
import '../screens/trust_premium/trust_premium_screen.dart';
import '../services/trust_premium_storage.dart';

class TrustPremiumCard extends StatelessWidget {
  final VoidCallback? onBeginPressed;

  const TrustPremiumCard({
    super.key,
    this.onBeginPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode 
        ? AppColors.secondaryGray.withOpacity(0.3) 
        : const Color(0xFFF4F4F6);
    final textColor = isDarkMode ? AppColors.darkText : AppColors.mainBlack;
    final secondaryTextColor = isDarkMode ? AppColors.darkText.withOpacity(0.7) : AppColors.secondaryGray;
    final buttonColor = isDarkMode ? AppColors.primaryGreen : AppColors.primaryBlue;

    return Container(
      height: 108,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image on left
          Image.asset(
            'assets/images/crypto_winter.png',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16),
          // Text content in middle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.levelUp,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.unlockExclusiveRewards,
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Begin button on right (vertically centered)
          GestureDetector(
            onTap: onBeginPressed ?? () async {
              // DEV: always show onboarding for development; set to true to skip
              const bool devAlwaysShowOnboarding = true;
              if (!devAlwaysShowOnboarding) {
                final completed = await TrustPremiumStorage.hasCompletedOnboarding();
                if (!context.mounted) return;
                if (completed) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrustPremiumScreen(),
                    ),
                  );
                  return;
                }
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrustPremiumOnboardingScreen(),
                ),
              );
            },
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(999), // Fully rounded
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.begin,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppColors.darkBackground : AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
