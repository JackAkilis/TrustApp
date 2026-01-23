import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TokenListItem extends StatelessWidget {
  final int rank;
  final String name;
  final String price;
  final String marketCap;
  final String change;
  final bool isPositive;
  final String? icon;

  const TokenListItem({
    super.key,
    required this.rank,
    required this.name,
    required this.price,
    required this.marketCap,
    required this.change,
    required this.isPositive,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$rank',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.mainBlack,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.mainGray,
            shape: BoxShape.circle,
          ),
          child: icon != null
              ? Image.asset(
                  icon!,
                  width: 40,
                  height: 40,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mainBlack,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryGray,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'MCap: $marketCap Vol:...',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryGray,
              ),
            ),
            const SizedBox(height: 4),
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
    );
  }
}
