import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';

class ThemeHelper {
  static bool isDarkMode(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
  }

  static Color getBackgroundColor(BuildContext context) {
    return isDarkMode(context) ? AppColors.darkBackground : AppColors.white;
  }

  static Color getTextColor(BuildContext context) {
    return isDarkMode(context) ? AppColors.darkText : AppColors.mainBlack;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return isDarkMode(context) 
        ? AppColors.darkText.withOpacity(0.7) 
        : AppColors.secondaryGray;
  }

  static Color getPrimaryColor(BuildContext context) {
    return isDarkMode(context) ? AppColors.primaryGreen : AppColors.primaryBlue;
  }

  static Color getGrayColor(BuildContext context) {
    return isDarkMode(context) 
        ? AppColors.secondaryGray.withOpacity(0.3) 
        : AppColors.mainGray;
  }

  static Color getBorderColor(BuildContext context) {
    return isDarkMode(context) 
        ? AppColors.secondaryGray.withOpacity(0.5) 
        : AppColors.borderGray;
  }
}
