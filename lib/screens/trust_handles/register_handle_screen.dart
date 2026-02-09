import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';

class RegisterHandleScreen extends StatefulWidget {
  const RegisterHandleScreen({super.key});

  @override
  State<RegisterHandleScreen> createState() => _RegisterHandleScreenState();
}

class _RegisterHandleScreenState extends State<RegisterHandleScreen> {
  final TextEditingController _handleController = TextEditingController();

  @override
  void dispose() {
    _handleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
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
          'Register handle',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Name label
                  Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Handle input field with @trust suffix
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.secondaryGray.withOpacity(0.3)
                          : grayColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _handleController,
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your handle',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: secondaryTextColor,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            '@trust',
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color(0xFF0302FD), // Blue color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Validation rules box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E7), // #FFF9E7
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRuleItem(
                          'Max 36 characters',
                        ),
                        const SizedBox(height: 8),
                        _buildRuleItem(
                          'Accepted characters A-Z & 0-9-(dash)',
                        ),
                        const SizedBox(height: 8),
                        _buildRuleItem(
                          'Cannot start or end with a dash',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Continue button at bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle continue
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9E99FF), // #9E99FF
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999), // Fully rounded
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    const ruleColor = Color(0xFFDFAD24); // #DFAD24
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6, right: 12),
          decoration: const BoxDecoration(
            color: ruleColor,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: ruleColor,
            ),
          ),
        ),
      ],
    );
  }
}
