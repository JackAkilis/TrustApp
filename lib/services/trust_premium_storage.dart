import 'package:shared_preferences/shared_preferences.dart';

class TrustPremiumStorage {
  static const String _hasCompletedOnboardingKey = 'trust_premium_has_completed_onboarding';

  /// True if the user has already passed the Trust Premium onboarding (or skipped it) once.
  static Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasCompletedOnboardingKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mark that the user has completed or skipped the Trust Premium onboarding.
  static Future<bool> setHasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_hasCompletedOnboardingKey, true);
    } catch (e) {
      return false;
    }
  }
}
