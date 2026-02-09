import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../services/wallet_storage.dart';
import 'mnemonic_display_screen.dart';

class ManualBackupIntroBottomSheet extends StatefulWidget {
  const ManualBackupIntroBottomSheet({super.key});

  @override
  State<ManualBackupIntroBottomSheet> createState() =>
      _ManualBackupIntroBottomSheetState();
}

class _ManualBackupIntroBottomSheetState
    extends State<ManualBackupIntroBottomSheet> {
  bool _check1 = false;
  bool _check2 = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final isActive = _check1 && _check2;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row with drag handle and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: grayColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Close button
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: textColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Mnemonic image
              Image.asset(
                'assets/images/mnemonic.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.shield,
                      size: 80,
                      color: AppColors.primaryGreen,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Warning icon and text (same line)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'For my personal viewing only!',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Main heading
              Text(
                'This mnemonic phrase can unlock your wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 32),
              // Checklist item 1
              _buildChecklistItem(
                context,
                'Trust Wallet does not have access to this key.',
                _check1,
                () {
                  setState(() {
                    _check1 = !_check1;
                  });
                },
                textColor,
                grayColor,
                primaryColor,
              ),
              const SizedBox(height: 12),
              // Checklist item 2
              _buildChecklistItem(
                context,
                'Do not save this key in any digital format. Write the key down on paper and keep it secure.',
                _check2,
                () {
                  setState(() {
                    _check2 = !_check2;
                  });
                },
                textColor,
                grayColor,
                primaryColor,
              ),
              const SizedBox(height: 32),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isActive
                      ? () async {
                          // Get wallet name from storage
                          final walletName = await WalletStorage.getWalletName() ?? 'Main Wallet';
                          if (context.mounted) {
                            Navigator.pop(context);
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MnemonicDisplayScreen(
                                  walletName: walletName,
                                ),
                              ),
                            );
                            // Return result to parent (wallet details screen)
                            if (context.mounted && result == true) {
                              Navigator.pop(context, true);
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive
                        ? AppColors.primaryBlue
                        : AppColors.secondaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.secondaryBlue,
                    disabledForegroundColor: Colors.white.withOpacity(0.6),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(
    BuildContext context,
    String text,
    bool isChecked,
    VoidCallback onTap,
    Color textColor,
    Color grayColor,
    Color primaryColor,
  ) {
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: grayColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle,
              color: isChecked ? primaryColor : secondaryTextColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
