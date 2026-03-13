import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'app_locale';

/// Provides an optional in-app locale override.
///
/// By default the app follows the **system language** on every launch.
/// That means we do **not** persist the selected locale across restarts.
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  /// On app launch, always follow the system language.
  ///
  /// We also clear any previously persisted locale to ensure older installs
  /// don't keep using a stale language after system settings change.
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_localeKey)) {
      await prefs.remove(_localeKey);
    }
    _locale = null; // null => MaterialApp resolves locale from system settings
    notifyListeners();
  }

  /// Set an in-app locale override for the current session only.
  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
  }

  /// Set locale by language code.
  Future<void> setLocaleFromCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }
}
