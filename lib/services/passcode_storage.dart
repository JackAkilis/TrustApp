import 'package:shared_preferences/shared_preferences.dart';

class PasscodeStorage {
  static const String _passcodeKey = 'saved_passcode';

  /// Save passcode to local storage
  static Future<bool> savePasscode(String passcode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_passcodeKey, passcode);
    } catch (e) {
      return false;
    }
  }

  /// Get saved passcode from local storage
  static Future<String?> getPasscode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_passcodeKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if passcode exists
  static Future<bool> hasPasscode() async {
    final passcode = await getPasscode();
    return passcode != null && passcode.isNotEmpty;
  }

  /// Delete saved passcode
  static Future<bool> deletePasscode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_passcodeKey);
    } catch (e) {
      return false;
    }
  }
}
