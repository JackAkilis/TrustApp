import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PasscodeDots extends StatelessWidget {
  final int passcodeLength;
  final bool isConfirming;
  final bool isMatched;
  final bool isError;

  const PasscodeDots({
    super.key,
    required this.passcodeLength,
    this.isConfirming = false,
    this.isMatched = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFilled = index < passcodeLength;
        // Determine colors based on state: error > matched > default
        Color circleColor;
        Color borderColor;
        
        if (isError) {
          circleColor = AppColors.errorRed;
          borderColor = AppColors.errorRed;
        } else if (isMatched) {
          // Matched state (works for both confirm and enter screens)
          circleColor = AppColors.primaryBlue;
          borderColor = AppColors.primaryBlue;
        } else {
          circleColor = AppColors.mainBlack;
          borderColor = AppColors.borderGrayLight;
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 36,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Center(
            child: isFilled
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: circleColor,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        );
      }),
    );
  }
}
