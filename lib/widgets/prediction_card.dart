import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/theme_helper.dart';

class PredictionCard extends StatelessWidget {
  final String? imagePath; // Optional image path
  final String question;
  final String yesOutcome;
  final String noOutcome;
  final String currentValue;
  final String status; // e.g., "In Progress"
  final String provider;
  final VoidCallback? onYesPressed;
  final VoidCallback? onNoPressed;

  const PredictionCard({
    super.key,
    this.imagePath,
    required this.question,
    required this.yesOutcome,
    required this.noOutcome,
    required this.currentValue,
    required this.status,
    required this.provider,
    this.onYesPressed,
    this.onNoPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final cardBackgroundColor = isDarkMode 
        ? AppColors.secondaryGray.withOpacity(0.3) 
        : const Color(0xFFF4F4F6);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question with image
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: grayColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          imagePath!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.image,
                        size: 30,
                        color: secondaryTextColor,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Yes/No buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onYesPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode 
                        ? const Color(0xFF253931) // Dark green for dark mode
                        : const Color(0xFFC6F6D5), // Light green for light mode
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0, // No shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999), // Fully rounded
                    ),
                  ),
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppColors.white : textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNoPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode 
                        ? const Color(0xFF472d2d) // Dark red/brown for dark mode
                        : const Color(0xFFFED7D7), // Light red for light mode
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0, // No shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999), // Fully rounded
                    ),
                  ),
                  child: Text(
                    'No',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppColors.white : textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Outcome details - center aligned with buttons
          Row(
            children: [
              Expanded(
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                      children: [
                        TextSpan(text: '\$100 → '),
                        TextSpan(
                          text: yesOutcome,
                          style: const TextStyle(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                      children: [
                        TextSpan(text: '\$100 → '),
                        TextSpan(
                          text: noOutcome,
                          style: const TextStyle(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status and provider info
          Row(
            children: [
              Text(
                currentValue,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
              Text(' • ', style: TextStyle(color: secondaryTextColor)),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.errorRed,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                ' $status',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              ),
              Text(' • ', style: TextStyle(color: secondaryTextColor)),
              Text(
                'Provider: $provider',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
