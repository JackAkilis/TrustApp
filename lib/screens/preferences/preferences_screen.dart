import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);

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
          'Preferences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildPreferenceItem(
            context: context,
            title: 'Currency',
            value: 'USDT',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onTap: () {
              // Handle currency selection
            },
          ),
          _buildPreferenceItem(
            context: context,
            title: 'App Language',
            value: 'English(United Kingdom)',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onTap: () {
              // Handle language selection
            },
          ),
          _buildPreferenceItem(
            context: context,
            title: 'DApp Browser',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onTap: () {
              // Handle DApp Browser
            },
          ),
          _buildPreferenceItem(
            context: context,
            title: 'Node Setting',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onTap: () {
              // Handle Node Setting
            },
          ),
          _buildPreferenceItem(
            context: context,
            title: 'Unlock UIXOs',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onTap: () {
              // Handle Unlock UIXOs
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required BuildContext context,
    required String title,
    String? value,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  color: secondaryTextColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
