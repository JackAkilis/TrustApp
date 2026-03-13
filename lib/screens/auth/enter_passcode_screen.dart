import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/passcode_keypad.dart';
import '../../widgets/passcode_dots.dart';
import '../../constants/app_colors.dart';
import '../../services/passcode_storage.dart';
import '../home/home_screen.dart';
import 'confirm_passcode_screen.dart';

class EnterPasscodeScreen extends StatefulWidget {
  final bool isImportingWallet;
  /// When true, a successful unlock just pops this screen instead of
  /// navigating to a new HomeScreen. Used when returning from background.
  final bool unlockExistingSession;

  const EnterPasscodeScreen({
    super.key,
    this.isImportingWallet = false,
    this.unlockExistingSession = false,
  });

  @override
  State<EnterPasscodeScreen> createState() => _EnterPasscodeScreenState();
}

class _EnterPasscodeScreenState extends State<EnterPasscodeScreen> {
  String _passcode = '';
  bool _isMatched = false;
  bool _isError = false;
  bool _isNewUser = true;
  bool _passcodeChecked = false;
  String? _savedPasscode;

  @override
  void initState() {
    super.initState();
    _checkPasscodeExists();
  }

  Future<void> _checkPasscodeExists() async {
    final hasPasscode = await PasscodeStorage.hasPasscode();
    if (hasPasscode) {
      _savedPasscode = await PasscodeStorage.getPasscode();
      if (!mounted) return;
      setState(() {
        _isNewUser = false;
        _passcodeChecked = true;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _passcodeChecked = true;
    });
  }

  void _onNumberPressed(String number) {
    if (_passcode.length < 6 && !_isError) {
      setState(() {
        _passcode += number;
      });

      if (_passcode.length == 6) {
        if (_isNewUser) {
          // New user - navigate to confirm passcode screen
          final passcodeToPass = _passcode;
          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmPasscodeScreen(
                  initialPasscode: passcodeToPass,
                  isImportingWallet: widget.isImportingWallet,
                ),
              ),
            );
          });
        } else {
          // Existing user - validate against saved passcode
          if (_passcode == _savedPasscode) {
            // Passcode matches - show blue and navigate to next screen
            setState(() {
              _isMatched = true;
            });
            Future.delayed(const Duration(milliseconds: 300), () {
              if (widget.unlockExistingSession) {
                // Returning from background: just unlock current session
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              }
            });
          } else {
            // Passcode doesn't match - show red error
            _showErrorAndReset();
          }
        }
      }
    }
  }

  void _onDeletePressed() {
    if (_passcode.isNotEmpty && !_isError) {
      setState(() {
        _passcode = _passcode.substring(0, _passcode.length - 1);
      });
    }
  }

  void _showErrorAndReset() {
    // Show red error state
    setState(() {
      _isError = true;
    });
    
    // After 0.5 seconds, clear input and reset colors
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _passcode = '';
          _isMatched = false;
          _isError = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canNavigateBack = _passcodeChecked && _isNewUser;
    return WillPopScope(
      // If this screen is being used to unlock an existing wallet, disable
      // Android back / iOS back-swipe to avoid leaving the auth flow.
      onWillPop: () async => canNavigateBack,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: canNavigateBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.mainBlack),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                AppLocalizations.of(context)!.enterPasscode,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainBlack,
                ),
              ),
              const SizedBox(height: 40),
              PasscodeDots(
                passcodeLength: _passcode.length,
                isConfirming: false,
                isMatched: _isMatched,
                isError: _isError,
              ),
              const Spacer(),
              PasscodeKeypad(
                onNumberPressed: _onNumberPressed,
                onDeletePressed: _onDeletePressed,
                showBiometric: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
