import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';

class LoadingScreen extends StatelessWidget {
  final PreferredSizeWidget Function(BuildContext context)? appBarBuilder;
  final Widget Function(BuildContext context)? topBarBuilder;

  const LoadingScreen({
    super.key,
    this.appBarBuilder,
    this.topBarBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final rectangleColor = isDarkMode
        ? AppColors.secondaryGray.withOpacity(0.25)
        : const Color(0xFFE6E6E8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBarBuilder?.call(context),
      body: Column(
        children: [
          if (appBarBuilder == null && topBarBuilder != null)
            topBarBuilder!(context),
          Expanded(
            child: Center(
              child: Transform.rotate(
                angle: math.pi / 4, // 45 degrees
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: rectangleColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    // Keep the GIF upright while the rectangle is rotated.
                    child: Transform.rotate(
                      angle: -math.pi / 4,
                      child: Image.asset(
                        'assets/animations/loading.gif',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          );
                        },
                      ),
                    ),
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

