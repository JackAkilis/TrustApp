import 'package:flutter/material.dart';
import '../../widgets/passcode_keypad.dart';
import '../../widgets/passcode_dots.dart';
import '../../widgets/biometric_login_modal.dart';
import '../../constants/app_colors.dart';
import '../../services/passcode_storage.dart';
import '../home/home_screen.dart';

class ConfirmPasscodeScreen extends StatefulWidget {
  final String initialPasscode;

  const ConfirmPasscodeScreen({
    super.key,
    required this.initialPasscode,
  });

  @override
  State<ConfirmPasscodeScreen> createState() => _ConfirmPasscodeScreenState();
}

class _ConfirmPasscodeScreenState extends State<ConfirmPasscodeScreen> {
  String _passcode = '';
  bool _isMatched = false;
  bool _isError = false;

  void _onNumberPressed(String number) {
    if (_passcode.length < 6 && !_isError) {
      setState(() {
        _passcode += number;
      });

      if (_passcode.length == 6) {
        if (_passcode == widget.initialPasscode) {
          // Passcodes match - save to storage, show primary blue and then biometric modal
          setState(() {
            _isMatched = true;
          });
          // Save passcode to local storage
          PasscodeStorage.savePasscode(_passcode);
          Future.delayed(const Duration(milliseconds: 300), () {
            _showBiometricModal();
          });
        } else {
          // Passcodes don't match - show red error state
          _showErrorAndReset();
        }
      }
    }
  }

  void _onDeletePressed() {
    if (_passcode.isNotEmpty) {
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

  void _showBiometricModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BiometricLoginModal(),
    ).then((value) {
      // If modal is dismissed without button press (swiped down), navigate to home
      // (passcode is already confirmed and saved)
      // Buttons already handle navigation, so we only navigate if value is null
      if (mounted && value == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mainBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Confirm passcode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.mainBlack,
              ),
            ),
            const SizedBox(height: 40),
            PasscodeDots(
              passcodeLength: _passcode.length,
              isConfirming: true,
              isMatched: _isMatched,
              isError: _isError,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Re-enter your passcode. Be sure to remember it so you can unlock your wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryGray,
                  height: 1.5,
                ),
              ),
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
    );
  }
}
