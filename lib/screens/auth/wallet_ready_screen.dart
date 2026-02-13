import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_screen.dart';

class WalletReadyScreen extends StatefulWidget {
  const WalletReadyScreen({super.key});

  @override
  State<WalletReadyScreen> createState() => _WalletReadyScreenState();
}

class _WalletReadyScreenState extends State<WalletReadyScreen> {
  bool _showGif = true;
  Timer? _gifTimer;

  @override
  void initState() {
    super.initState();
    // Show the congratulations GIF once for a short duration, then hide it.
    _gifTimer = Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      setState(() {
        _showGif = false;
      });
    });
  }

  @override
  void dispose() {
    _gifTimer?.cancel();
    super.dispose();
  }

  void _goToHome(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Foreground content: skip button, texts, and button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Skip button top-right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _goToHome(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          backgroundColor: AppColors.mainGray,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.skip,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mainBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Center area: empty_wallet GIF + Brilliant text block vertically centered
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Empty wallet GIF above the text
                          SizedBox(
                            height: 160,
                            child: Image(
                              image: AssetImage(
                                'assets/animations/empty_wallet.gif',
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            AppLocalizations.of(context)!.brilliantWalletReady,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mainBlack,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.addFundsToGetStarted,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Primary CTA at bottom
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _goToHome(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.fundYourWallet,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Full-screen GIF drawn above other content, only while _showGif is true.
            if (_showGif)
              Positioned.fill(
                child: Center(
                  child: Image.asset(
                    'assets/animations/congratulations.gif',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

