import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import 'enter_passcode_screen.dart';

const String _kHasSeenWelcomeKey = 'has_seen_welcome';

/// Returns true if the user has already seen the welcome screen (not first install).
Future<bool> hasSeenWelcome() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kHasSeenWelcomeKey) ?? false;
}

/// Mark that the user has seen the welcome screen (call when they tap any CTA).
Future<void> setHasSeenWelcome() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kHasSeenWelcomeKey, true);
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final List<String> _messages = const [
    'Unlock opportunities across 100+ chains',
    'Earn rewards, buy crypto, swap tokens',
    'Explore a limitless world of dApps',
    'Your one-stop Web3 wallet',
    'Own, control, and leverage the power of your digital assets',
  ];

  int _currentIndex = 0;
  bool _isVisible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTextLoop();
  }

  void _startTextLoop() {
    // Show each message for ~3 seconds, hide for ~1 second, then switch.
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _isVisible = false;
      });
      // After 1 second of being hidden, change text and fade back in.
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _currentIndex = (_currentIndex + 1) % _messages.length;
          _isVisible = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _openExternalLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _onCreateNewWallet(BuildContext context) async {
    await setHasSeenWelcome();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const EnterPasscodeScreen(),
      ),
    );
  }

  Future<void> _onAlreadyHaveWallet(BuildContext context) async {
    await setHasSeenWelcome();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const EnterPasscodeScreen(
          isImportingWallet: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Image area: takes all remaining space; only image uses fit:cover, text overlay separate
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image only: fill this area with cover (text is not part of cover)
                    ClipRect(
                      child: Image.asset(
                        'assets/images/crypto_winter.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 120,
                            color: AppColors.secondaryGray,
                          ),
                        ),
                      ),
                    ),
                    // Text overlay: left 0, bottom 0, full width so it wraps (no overflow)
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: SizedBox(
                          width: 240,
                          child: AnimatedOpacity(
                            opacity: _isVisible ? 1 : 0,
                            duration: const Duration(milliseconds: 350),
                            child: Text(
                              _messages[_currentIndex],
                              textAlign: TextAlign.left,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.mainBlack,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Button area (fixed at bottom, same 20 padding from parent)
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Column(
                  children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onCreateNewWallet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Create new wallet'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onAlreadyHaveWallet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGray,
                        foregroundColor: AppColors.mainBlack,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('I already have a wallet'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryGray,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              'By tapping any button you agree and consent to our\n',
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryBlue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _openExternalLink(
                                'https://trustwallet.com/terms-of-service',
                              );
                            },
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryBlue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _openExternalLink(
                                'https://trustwallet.com/privacy-notice',
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
