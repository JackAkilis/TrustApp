import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'app_locale';

/// Provides app locale and persists user's language selection.
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  /// Load saved locale from storage.
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  /// Set app locale and persist.
  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale != null) {
      await prefs.setString(_localeKey, locale.languageCode);
    } else {
      await prefs.remove(_localeKey);
    }
    notifyListeners();
  }

  /// Set locale by language code.
  Future<void> setLocaleFromCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }
}
