import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/theme_helper.dart';

class EarnCard extends StatelessWidget {
  final String yieldPercentage;
  final String productName;
  final String? iconPath; // Optional icon path

  const EarnCard({
    super.key,
    required this.yieldPercentage,
    required this.productName,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final cardBackgroundColor = isDarkMode 
        ? AppColors.secondaryGray.withOpacity(0.3) 
        : const Color(0xFFF4F4F6);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    
    return Container(
      width: 240,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top text
                Text(
                  'Earn up to',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                // Gradient percentage text
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: isDarkMode
                            ? [
                                AppColors.primaryGreen, // Green in dark mode
                                AppColors.primaryGreen.withOpacity(0.8),
                                AppColors.primaryGreen.withOpacity(0.6),
                                AppColors.primaryGreen.withOpacity(0.4),
                              ]
                            : [
                                const Color(0xFF0302FD), // Blue
                                const Color(0xFF9E99FF), // Purple
                                const Color(0xFFFF6B6B), // Pink/Red
                                const Color(0xFFFFA500), // Orange
                              ],
                        stops: [0.0, 0.33, 0.66, 1.0],
                      ).createShader(bounds),
                      child: Text(
                        yieldPercentage,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white, // Will be masked by gradient
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '/ year',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Product name
                Text(
                  'on $productName',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right side: Icon (vertically centered)
          if (iconPath != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkText.withOpacity(0.2) : Colors.black,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  iconPath!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            // Placeholder icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkText.withOpacity(0.2) : Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                color: isDarkMode ? primaryColor : Colors.blue,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
}
