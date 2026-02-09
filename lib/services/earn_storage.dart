import 'package:shared_preferences/shared_preferences.dart';

class EarnStorage {
  static const String _hasVisitedEarnKey = 'has_visited_earn';

  /// Check if user has visited the Earn screen
  static Future<bool> hasVisitedEarn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasVisitedEarnKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mark that the user has visited the Earn screen
  static Future<bool> setHasVisitedEarn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_hasVisitedEarnKey, true);
    } catch (e) {
      return false;
    }
  }
}
