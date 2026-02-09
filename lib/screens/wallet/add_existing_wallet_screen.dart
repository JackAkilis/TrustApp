import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import 'secret_phrase_import_intro_bottom_sheet.dart';

class AddExistingWalletScreen extends StatelessWidget {
  const AddExistingWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Add existing wallet',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Most popular section
            Text(
              'Most popular',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context,
              icon: Icons.edit_outlined,
              iconColor: AppColors.primaryBlue,
              title: 'Secret phrase',
              subtitle: null,
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
              ),
              textColor: textColor,
              grayColor: grayColor,
              secondaryTextColor: secondaryTextColor,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const SecretPhraseImportIntroBottomSheet(),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context,
              icon: Icons.vpn_key_outlined,
              iconColor: AppColors.primaryBlue,
              title: 'Private key',
              subtitle: null,
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
              ),
              textColor: textColor,
              grayColor: grayColor,
              secondaryTextColor: secondaryTextColor,
              onTap: () {
                // TODO: Implement import via private key
              },
            ),
            const SizedBox(height: 24),
            // Other options section
            Text(
              'Other options',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context,
              icon: Icons.cloud_outlined,
              iconColor: AppColors.primaryBlue,
              title: 'Google Drive backup',
              subtitle: null,
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
              ),
              textColor: textColor,
              grayColor: grayColor,
              secondaryTextColor: secondaryTextColor,
              onTap: () {
                // TODO: Implement restore from Google Drive
              },
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context,
              icon: Icons.remove_red_eye_outlined,
              iconColor: AppColors.primaryBlue,
              title: 'View-only wallet',
              subtitle: null,
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
              ),
              textColor: textColor,
              grayColor: grayColor,
              secondaryTextColor: secondaryTextColor,
              onTap: () {
                // TODO: Implement view-only wallet import
              },
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context,
              icon: Icons.lock_outline,
              iconColor: AppColors.primaryBlue,
              title: 'Keystore',
              subtitle: null,
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
              ),
              textColor: textColor,
              grayColor: grayColor,
              secondaryTextColor: secondaryTextColor,
              onTap: () {
                // TODO: Implement keystore import
              },
            ),
            const SizedBox(height: 12),
            _buildSwiftCard(
              context,
              textColor: textColor,
              grayColor: grayColor,
              secondaryTextColor: secondaryTextColor,
              onTap: () {
                // TODO: Implement Swift import flow
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Widget trailing,
    required Color textColor,
    required Color grayColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: grayColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFD4D3F3), // light blue icon background
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSwiftCard(
    BuildContext context, {
    required Color textColor,
    required Color grayColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: grayColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFD4D3F3), // light purple/blue icon background
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                Icons.settings_outlined,
                color: AppColors.primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Swift',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Beta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

