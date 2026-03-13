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
    final code = _currentLanguageCode(context);
    switch (code) {
      case 'ko':
        return '한국어 (대한민국)';
      case 'vi':
        return 'Tiếng Việt (Việt Nam)';
      case 'pt':
        return 'Português (Brasil)';
      case 'ru':
        return 'Русский';
      default:
        return 'English (United Kingdom)';
    }
  }

  String _currentLanguageCode(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    // If user never selected a language, LocaleProvider.locale is null and the app
    // falls back to the device/system locale. Use the actual current locale in that case.
    return localeProvider.locale?.languageCode ?? Localizations.localeOf(context).languageCode;
  }

  void _showLanguagePicker(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final selectedCode = _currentLanguageCode(context);
    final sheetBackground = ThemeHelper.getBackgroundColor(context);
    final sheetTextColor = ThemeHelper.getTextColor(context);
    final options = [
      ('en', 'English (United Kingdom)'),
      ('ko', '한국어 (대한민국)'),
      ('vi', 'Tiếng Việt (Việt Nam)'),
      ('pt', 'Português (Brasil)'),
      ('ru', 'Русский'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBackground,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.secondaryGray.withOpacity(0.4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.appLanguage,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: sheetTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...options.map((opt) {
              final isSelected = opt.$1 == selectedCode;
              final radioBorderColor = isSelected
                  ? AppColors.primaryBlue
                  : AppColors.secondaryGray.withOpacity(0.5);
              return ListTile(
                title: Text(
                  opt.$2,
                  style: TextStyle(
                    color: sheetTextColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: _LanguageRadio(
                  isSelected: isSelected,
                  borderColor: radioBorderColor,
                  fillColor: AppColors.primaryBlue,
                ),
                onTap: () {
                  localeProvider.setLocaleFromCode(opt.$1);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
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

class _LanguageRadio extends StatelessWidget {
  final bool isSelected;
  final Color borderColor;
  final Color fillColor;

  const _LanguageRadio({
    required this.isSelected,
    required this.borderColor,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: isSelected ? 10 : 0,
            height: isSelected ? 10 : 0,
            decoration: BoxDecoration(
              color: isSelected ? fillColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
