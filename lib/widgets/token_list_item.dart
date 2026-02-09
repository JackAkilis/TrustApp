import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/theme_helper.dart';
import 'token_image.dart';

class TokenListItem extends StatelessWidget {
  final int rank;
  final String name;
  final String price;
  final String marketCap;
  final String change;
  final bool isPositive;
  final bool isNativeToken;
  final String? chain;
  final String? tokenName; // Token name for native tokens (e.g., 'bitcoin', 'bnb', 'solana')
  final String? tokenIcon; // Explicit token icon asset name (e.g., 'war_token.png')

  const TokenListItem({
    super.key,
    required this.rank,
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
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    
    return Row(
      children: [
        // Rank number with fixed width so avatars align for 1–2 digit indices
        if (rank > 0) ...[
          SizedBox(
            width: 24,
            child: Text(
            '$rank',
              textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        // Token image
        TokenImage(
          isNativeToken: isNativeToken,
          chain: chain,
          tokenName: tokenName,
          tokenAssetName: tokenIcon,
        ),
        const SizedBox(width: 12),
        // Main content area
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Token name (left) and Token price (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Bottom row: MCap/Vol (left) and Price change rate (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      marketCap,
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    change,
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
}
