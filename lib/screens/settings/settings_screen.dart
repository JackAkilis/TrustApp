import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/trust_premium_card.dart';
import '../../providers/theme_provider.dart';
import '../address_book/address_book_screen.dart';
import '../trust_handles/trust_handles_screen.dart';
import '../wallet_connect/wallet_connect_screen.dart';
import '../preferences/preferences_screen.dart';
import '../security/security_screen.dart';
import '../notifications/notifications_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.white;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.mainBlack;
    final primaryColor = isDarkMode ? AppColors.primaryGreen : AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Sticky header
          SliverAppBar(
            pinned: true,
            backgroundColor: backgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: textColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            centerTitle: true,
          ),
          // Trust Premium Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trust Premium',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TrustPremiumCard(),
                ],
              ),
            ),
          ),
          // Dark Mode Toggle
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Dark_mode.png',
              title: 'Dark Mode',
              textColor: textColor,
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                activeColor: primaryColor,
              ),
            ),
          ),
          // Gap before divider: 30px
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
          // Divider
          SliverToBoxAdapter(
            child: Divider(
              height: 1,
              color: isDarkMode ? AppColors.secondaryGray : AppColors.borderGray,
            ),
          ),
          // Gap after divider: 30px
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
          // Address Book
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Address_book.png',
              title: 'Address Book',
              textColor: textColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressBookScreen(),
                  ),
                );
              },
            ),
          ),
          // Gap between menu items: 45px
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          // Sync to Extension
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Sync_to_extension.png',
              title: 'Sync to Extension',
              textColor: textColor,
              onTap: () {
                // Handle sync to extension
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          // Trust handles
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Trust_handles.png',
              title: 'Trust handles',
              textColor: textColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrustHandlesScreen(),
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          // Scan QR code
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/scan_icon_20.png',
              title: 'Scan QR code',
              textColor: textColor,
              onTap: () {
                // Handle QR code scan
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          // WalletConnect
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/WalletConnect.png',
              title: 'WalletConnect',
              textColor: textColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalletConnectScreen(),
                  ),
                );
              },
            ),
          ),
          // Gap before divider: 30px
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
          // Divider
          SliverToBoxAdapter(
            child: Divider(
              height: 1,
              color: isDarkMode ? AppColors.secondaryGray : AppColors.borderGray,
            ),
          ),
          // Gap after divider: 30px
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
          // Preferences
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Preferences.png',
              title: 'Preferences',
              textColor: textColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PreferencesScreen(),
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          // Security
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Security.png',
              title: 'Security',
              textColor: textColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecurityScreen(),
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          // Notifications
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Notification.png',
              title: 'Notifications',
              textColor: textColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
          ),
          // Gap before divider: 30px
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
          // Divider
          SliverToBoxAdapter(
            child: Divider(
              height: 1,
              color: isDarkMode ? AppColors.secondaryGray : AppColors.borderGray,
            ),
          ),
          // Gap after divider: 30px
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
          // Help Center
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Help.png',
              title: 'Help Center',
              textColor: textColor,
              onTap: () {
                // Handle help center
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          // Support
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Support.png',
              title: 'Support',
              textColor: textColor,
              onTap: () {
                // Handle support
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          // About
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/About.png',
              title: 'About',
              textColor: textColor,
              onTap: () {
                // Handle about
              },
            ),
          ),
          // Gap before divider: 30px
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
          // Divider
          SliverToBoxAdapter(
            child: Divider(
              height: 1,
              color: isDarkMode ? AppColors.secondaryGray : AppColors.borderGray,
            ),
          ),
          // Gap after divider: 30px
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
          // Social Media Links
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/X.png',
              title: 'X',
              textColor: textColor,
              onTap: () {
                // Handle X (Twitter)
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Telegram.png',
              title: 'Telegram',
              textColor: textColor,
              onTap: () {
                // Handle Telegram
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Facebook.png',
              title: 'Facebook',
              textColor: textColor,
              onTap: () {
                // Handle Facebook
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Reddit.png',
              title: 'Reddit',
              textColor: textColor,
              onTap: () {
                // Handle Reddit
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Youtube.png',
              title: 'Youtube',
              textColor: textColor,
              onTap: () {
                // Handle Youtube
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Instagram.png',
              title: 'Instagram',
              textColor: textColor,
              onTap: () {
                // Handle Instagram
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 45),
          ),
          SliverToBoxAdapter(
            child: _buildSettingItem(
              context: context,
              iconPath: 'assets/icons/Tiktok.png',
              title: 'Tiktok',
              textColor: textColor,
              onTap: () {
                // Handle Tiktok
              },
            ),
          ),
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    String? iconPath,
    IconData? icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final itemTextColor = textColor ?? (isDarkMode ? AppColors.darkText : AppColors.mainBlack);
    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.white;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            if (iconPath != null)
              Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color: isDarkMode ? AppColors.darkText : null,
                colorBlendMode: isDarkMode ? BlendMode.srcIn : null,
              )
            else if (icon != null)
              Icon(
                icon,
                size: 24,
                color: itemTextColor,
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: itemTextColor,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
