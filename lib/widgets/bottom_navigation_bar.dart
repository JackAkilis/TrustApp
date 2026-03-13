import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme_helper.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool showEarnBadge;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.showEarnBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBottomNavItem(
                context: context,
                activeIconPath: 'assets/icons/home_blue.svg',
                inactiveIconPath: 'assets/icons/home_gray.svg',
                label: AppLocalizations.of(context)!.home,
                index: 0,
                isSelected: selectedIndex == 0,
                primaryColor: primaryColor,
                secondaryTextColor: secondaryTextColor,
              ),
              _buildBottomNavItem(
                context: context,
                activeIconPath: 'assets/icons/trending_blue.svg',
                inactiveIconPath: 'assets/icons/trending_gray.svg',
                label: AppLocalizations.of(context)!.trending,
                index: 1,
                isSelected: selectedIndex == 1,
                primaryColor: primaryColor,
                secondaryTextColor: secondaryTextColor,
              ),
              _buildBottomNavItem(
                context: context,
                activeIconPath: 'assets/icons/trade_blue.svg',
                inactiveIconPath: 'assets/icons/trade_gray.svg',
                label: AppLocalizations.of(context)!.trade,
                index: 2,
                isSelected: selectedIndex == 2,
                primaryColor: primaryColor,
                secondaryTextColor: secondaryTextColor,
              ),
              _buildBottomNavItem(
                context: context,
                activeIconPath: 'assets/icons/rewards_blue.svg',
                inactiveIconPath: 'assets/icons/rewards_gray.svg',
                label: AppLocalizations.of(context)!.rewards,
                index: 3,
                isSelected: selectedIndex == 3,
                showDot: showEarnBadge,
                primaryColor: primaryColor,
                secondaryTextColor: secondaryTextColor,
              ),
              _buildBottomNavItem(
                context: context,
                activeIconPath: 'assets/icons/discover_blue.svg',
                inactiveIconPath: 'assets/icons/discover_gray.svg',
                label: AppLocalizations.of(context)!.discover,
                index: 4,
                isSelected: selectedIndex == 4,
                primaryColor: primaryColor,
                secondaryTextColor: secondaryTextColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required BuildContext context,
    required String activeIconPath,
    required String inactiveIconPath,
    required String label,
    required int index,
    required bool isSelected,
    required Color primaryColor,
    required Color secondaryTextColor,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(
                isSelected ? activeIconPath : inactiveIconPath,
                width: 24,
                height: 24,
              ),
              if (showDot && !isSelected)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? primaryColor : secondaryTextColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
