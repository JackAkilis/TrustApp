import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../providers/theme_provider.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _passcodeEnabled = false;
  bool _transactionSigningEnabled = true;
  String _autoLockValue = 'Immediate';

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final borderColor = ThemeHelper.getBorderColor(context);

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
          'Security',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.secondaryGray.withOpacity(0.5)
                    : AppColors.secondaryGray.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline,
                color: textColor,
                size: 16,
              ),
            ),
            onPressed: () {
              // Handle info button
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Passcode section
          _buildSecurityItem(
            context: context,
            title: 'Passcode',
            textColor: textColor,
            trailing: Switch(
              value: _passcodeEnabled,
              onChanged: (value) {
                setState(() {
                  _passcodeEnabled = value;
                });
              },
              activeColor: primaryColor,
            ),
          ),
          // Auto-lock
          _buildSecurityItem(
            context: context,
            title: 'Auto-lock',
            value: _autoLockValue,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onTap: () {
              _showAutoLockModal(context);
            },
          ),
          // Lock method
          _buildSecurityItem(
            context: context,
            title: 'Lock method',
            value: 'Passcode',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onTap: () {
              // Handle lock method selection
            },
          ),
          // Divider
          Container(
            height: 1,
            color: borderColor,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          // Transaction signing
          _buildSecurityItem(
            context: context,
            title: 'Transaction signing',
            subtitle: 'Ask for approval ahead of transactions.',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            trailing: Switch(
              value: _transactionSigningEnabled,
              onChanged: (value) {
                setState(() {
                  _transactionSigningEnabled = value;
                });
              },
              activeColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem({
    required BuildContext context,
    required String title,
    String? value,
    String? subtitle,
    required Color textColor,
    Color? secondaryTextColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final itemSecondaryTextColor = secondaryTextColor ?? ThemeHelper.getSecondaryTextColor(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      if (value != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            color: itemSecondaryTextColor,
                          ),
                        ),
                      ],
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: itemSecondaryTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAutoLockModal(BuildContext context) {
    final textColor = ThemeHelper.getTextColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);

    final options = [
      'Immediate',
      'Leave for more than 1 minute',
      'Leave for more than 5 minute',
      'Leave for more than 1 hour',
      'Leave for more than 5 hour',
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Options list
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options[index];
                    final isSelected = option == _autoLockValue;
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _autoLockValue = option;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? AppColors.mainBlack : AppColors.mainBlack,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
