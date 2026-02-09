import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';

class WalletConnectScreen extends StatelessWidget {
  const WalletConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
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
          'WalletConnect',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: textColor,
            ),
            onPressed: () {
              // Handle add new connection
            },
          ),
        ],
      ),
      body: _buildContent(context, textColor, secondaryTextColor, primaryColor, isDarkMode),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
    bool isDarkMode,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Central illustration
            Image.asset(
              'assets/images/wallet_connect.png',
              width: 130,
              height: 96,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            // Descriptive text
            Text(
              'Connect your wallet to interact with dApps and\nmake transactions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            // Add new connection button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle add new connection
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? AppColors.primaryGreen
                      : const Color(0xFF0302FD), // Blue
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999), // Fully rounded
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Add new connection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppColors.darkBackground : AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // What is WalletConnect link
            GestureDetector(
              onTap: () {
                // Handle what is WalletConnect
              },
              child: Text(
                'What is WalletConnect?',
                style: TextStyle(
                  fontSize: 14,
                  color: primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
