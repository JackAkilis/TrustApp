import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_helper.dart';
import '../receive/select_crypto_screen.dart';
import 'top_up_wallet_screen.dart';
import 'gpay_select_crypto_screen.dart';
import 'p2p_screen.dart';
import 'all_payment_methods_screen.dart';

class FundWalletScreen extends StatelessWidget {
  const FundWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final cardBackground = ThemeHelper.isDarkMode(context)
        ? ThemeHelper.getGrayColor(context)
        : const Color(0xFFF4F4F6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.fundYourWallet,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.recommendedForYou,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            // Recommended (Google Pay style) card - fixed height 80, with card background
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GPaySelectCryptoScreen(),
                  ),
                );
              },
              child: SizedBox(
              height: 80,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  // No border for the card, just background + radius
                ),
                child: Row(
                  children: [
                    // Google Pay icon (no background, just the icon itself)
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: Image.asset(
                          'assets/icons/gpay.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Google Pay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: secondaryTextColor,
                    ),
                  ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.allOptions,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            // All options card: fixed height 320, no dividers
            SizedBox(
              height: 320,
              child: Container(
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildOptionRow(
                        context,
                        icon: Icons.credit_card,
                        label: AppLocalizations.of(context)!.allPaymentMethods,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllPaymentMethodsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildOptionRow(
                        context,
                        icon: Icons.group,
                        label: AppLocalizations.of(context)!.p2p,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const P2PScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildOptionRow(
                        context,
                        icon: Icons.swap_horiz,
                        label: AppLocalizations.of(context)!.exchange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TopUpWalletScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildOptionRow(
                        context,
                        icon: Icons.qr_code_2,
                        label: AppLocalizations.of(context)!.cryptoWallet,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SelectCryptoScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);

    return InkWell(
      onTap: onTap ?? () {
        // TODO: Wire to specific funding flows.
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : AppColors.primaryBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDarkMode ? AppColors.primaryGreen : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

}

