import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../services/wallet_storage.dart';

class GoogleAccountSelectionModal extends StatefulWidget {
  const GoogleAccountSelectionModal({super.key});

  @override
  State<GoogleAccountSelectionModal> createState() => _GoogleAccountSelectionModalState();
}

class _GoogleAccountSelectionModalState extends State<GoogleAccountSelectionModal> {
  String? _currentUserEmail;
  String? _currentUserName;
  String? _currentUserInitial;

  @override
  void initState() {
    super.initState();
    _loadCurrentGoogleAccount();
  }

  Future<void> _loadCurrentGoogleAccount() async {
    // TODO: Integrate with Google Sign-In to get current account
    // For now, using placeholder data
    // In production, use: google_sign_in package to get current account
    setState(() {
      _currentUserEmail = 'doudou24677@gmail.com';
      _currentUserName = 'User';
      _currentUserInitial = 'U';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserEmail == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            // Trust Wallet logo (shield icon)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.primaryGreen,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'Select Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              'To continue using \'Trust Wallet\'',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 24),
            // Account list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Current logged-in account
                  if (_currentUserEmail != null) ...[
                    _buildAccountOption(
                      context,
                      icon: null,
                      iconText: _currentUserInitial ?? _currentUserName?.substring(0, 1) ?? 'U',
                      iconColor: Colors.purple,
                      name: _currentUserName ?? 'User',
                      email: _currentUserEmail,
                      onTap: () async {
                        // Mark Google Drive backup as completed
                        await WalletStorage.saveGoogleDriveBackup(true);
                        if (context.mounted) {
                          // Close modal first, then close processing screen
                          Navigator.pop(context, true);
                          // Use Future.microtask to ensure second pop happens after first completes
                          Future.microtask(() {
                            if (context.mounted) {
                              Navigator.pop(context, true);
                            }
                          });
                        }
                      },
                      textColor: textColor,
                      grayColor: grayColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Add another account option
                  _buildAccountOption(
                    context,
                    icon: Icons.person_add_outlined,
                    iconText: null,
                    iconColor: secondaryTextColor,
                    name: 'Add another account',
                    email: null,
                    onTap: () {
                      // TODO: Handle add another account
                    },
                    textColor: textColor,
                    grayColor: grayColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Divider
            Divider(
              height: 1,
              color: grayColor,
            ),
            const SizedBox(height: 16),
            // Disclaimer text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'To continue, Google will provide your name, email address, and profile picture to TrustWallet. Please review the Privacy Policy and Terms of Service before using this application.',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption(
    BuildContext context, {
    IconData? icon,
    String? iconText,
    required Color iconColor,
    required String name,
    String? email,
    required VoidCallback onTap,
    required Color textColor,
    required Color grayColor,
    required Color secondaryTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: grayColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Account icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: iconText != null
                  ? Center(
                      child: Text(
                        iconText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Icon(
                      icon ?? Icons.account_circle,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),
            // Name and email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
