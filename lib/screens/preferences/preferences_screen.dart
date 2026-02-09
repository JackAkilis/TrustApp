import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
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
          AppLocalizations.of(context)!.preferences,
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
            title: AppLocalizations.of(context)!.currency,
            value: 'USDT',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onTap: () {
              // Handle currency selection
            },
          ),
          _buildPreferenceItem(
            context: context,
            title: AppLocalizations.of(context)!.appLanguage,
            value: _getLanguageDisplayName(context),
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onTap: () => _showLanguagePicker(context),
          ),
          _buildPreferenceItem(
            context: context,
            title: AppLocalizations.of(context)!.dappBrowser,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onTap: () {
              // Handle DApp Browser
            },
          ),
          _buildPreferenceItem(
            context: context,
            title: AppLocalizations.of(context)!.nodeSetting,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onTap: () {
              // Handle Node Setting
            },
          ),
          _buildPreferenceItem(
            context: context,
            title: AppLocalizations.of(context)!.unlockUixos,
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

  String _getLanguageDisplayName(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final code = localeProvider.locale?.languageCode ?? 'en';
    switch (code) {
      case 'ko':
        return '한국어 (대한민국)';
      case 'vi':
        return 'Tiếng Việt (Việt Nam)';
      case 'pt':
        return 'Português (Brasil)';
      default:
        return 'English (United Kingdom)';
    }
  }

  void _showLanguagePicker(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final options = [
      ('en', 'English (United Kingdom)'),
      ('ko', '한국어 (대한민국)'),
      ('vi', 'Tiếng Việt (Việt Nam)'),
      ('pt', 'Português (Brasil)'),
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (opt) => ListTile(
                  title: Text(opt.$2),
                  onTap: () {
                    localeProvider.setLocaleFromCode(opt.$1);
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
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
