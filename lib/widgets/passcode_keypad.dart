import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PasscodeKeypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onDeletePressed;
  final bool showBiometric;

  const PasscodeKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onDeletePressed,
    this.showBiometric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Rows 1-3 (numbers 1-9)
          for (int row = 0; row < 3; row++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int col = 0; col < 3; col++)
                    _KeypadButton(
                      label: '${row * 3 + col + 1}',
                      onPressed: () => onNumberPressed('${row * 3 + col + 1}'),
                    ),
                ],
              ),
            ),
          // Bottom row (biometric, 0, delete)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                showBiometric
                    ? _KeypadButton(
                        icon: Icons.fingerprint,
                        onPressed: () {
                          // Handle biometric authentication
                        },
                      )
                    : const SizedBox(width: 80),
                _KeypadButton(
                  label: '0',
                  onPressed: () => onNumberPressed('0'),
                ),
                _KeypadButton(
                  icon: Icons.backspace_outlined,
                  onPressed: onDeletePressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  const _KeypadButton({
    this.label,
    this.icon,
    required this.onPressed,
  }) : assert(label != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          child: Center(
            child: label != null
                ? Text(
                    label!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: AppColors.keypadText,
                    ),
                  )
                : Icon(
                    icon,
                    size: 28,
                    color: AppColors.keypadText,
                  ),
          ),
        ),
      ),
    );
  }
}
