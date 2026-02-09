import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/theme_helper.dart';
import 'token_image.dart';

class AlphaTokenCard extends StatelessWidget {
  final String name;
  final String price;
  final String marketCap;
  final String change;
  final bool isPositive;
  final bool isNativeToken;
  final String? chain;
  final String? tokenName;
  final String? tokenIcon; // explicit token icon asset name (e.g., 'WMTX.png')

  const AlphaTokenCard({
    super.key,
    required this.name,
    required this.price,
    required this.marketCap,
    required this.change,
    required this.isPositive,
    required this.isNativeToken,
    this.chain,
    this.tokenName,
    this.tokenIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final cardBackgroundColor = isDarkMode 
        ? AppColors.secondaryGray.withOpacity(0.3) 
        : const Color(0xFFF4F4F6);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    
    return Container(
      width: 240,
      height: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Token image on left
          TokenImage(
            isNativeToken: isNativeToken,
            chain: chain,
            tokenName: tokenName,
            tokenAssetName: tokenIcon,
          ),
          const SizedBox(width: 12),
          // Middle section: Token name and market cap
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  marketCap,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right section: Price and change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.successGreen : AppColors.errorRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
