import 'package:flutter/material.dart';

import 'enter_passcode_screen.dart';
import 'welcome_screen.dart';

/// Decides whether to show [WelcomeScreen] (first install) or [EnterPasscodeScreen].
class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  bool? _hasSeenWelcome;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final seen = await hasSeenWelcome();
    if (mounted) {
      setState(() {
        _hasSeenWelcome = seen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenWelcome == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return _hasSeenWelcome!
        ? const EnterPasscodeScreen()
        : const WelcomeScreen();
  }
}
