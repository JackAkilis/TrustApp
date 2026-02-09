import 'package:shared_preferences/shared_preferences.dart';

class WalletStorage {
  static const String _walletIdKey = 'wallet_id';
  static const String _devicePassCodeIdKey = 'device_passcode_id';
  static const String _walletNameKey = 'wallet_name';
  static const String _mnemonicKey = 'mnemonic';
  static const String _googleDriveBackupKey = 'google_drive_backup';
  static const String _manualBackupKey = 'manual_backup';

  /// Save wallet ID
  static Future<bool> saveWalletId(String walletId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_walletIdKey, walletId);
    } catch (e) {
      return false;
    }
  }

  /// Get saved wallet ID
  static Future<String?> getWalletId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_walletIdKey);
    } catch (e) {
      return null;
    }
  }

  /// Save device passcode ID
  static Future<bool> saveDevicePassCodeId(String devicePassCodeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_devicePassCodeIdKey, devicePassCodeId);
    } catch (e) {
      return false;
    }
  }

  /// Get saved device passcode ID
  static Future<String?> getDevicePassCodeId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_devicePassCodeIdKey);
    } catch (e) {
      return null;
    }
  }

  /// Save wallet name
  static Future<bool> saveWalletName(String walletName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_walletNameKey, walletName);
    } catch (e) {
      return false;
    }
  }

  /// Get saved wallet name
  static Future<String?> getWalletName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_walletNameKey);
    } catch (e) {
      return null;
    }
  }

  /// Save wallet name for a specific wallet ID (per-wallet name)
  static Future<bool> saveWalletNameForId(String walletId, String walletName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString('wallet_name_$walletId', walletName);
    } catch (e) {
      return false;
    }
  }

  /// Get saved wallet name for a specific wallet ID (per-wallet name)
  static Future<String?> getWalletNameForId(String walletId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('wallet_name_$walletId');
    } catch (e) {
      return null;
    }
  }

  /// Save mnemonic (encrypted in production)
  static Future<bool> saveMnemonic(String mnemonic) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_mnemonicKey, mnemonic);
    } catch (e) {
      return false;
    }
  }

  /// Get saved mnemonic
  static Future<String?> getMnemonic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_mnemonicKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if wallet exists
  static Future<bool> hasWallet() async {
    final walletId = await getWalletId();
    return walletId != null && walletId.isNotEmpty;
  }

  /// Save Google Drive backup status
  static Future<bool> saveGoogleDriveBackup(bool hasBackup) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_googleDriveBackupKey, hasBackup);
    } catch (e) {
      return false;
    }
  }

  /// Get Google Drive backup status
  static Future<bool> hasGoogleDriveBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_googleDriveBackupKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Save manual backup status
  static Future<bool> saveManualBackup(bool hasBackup) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_manualBackupKey, hasBackup);
    } catch (e) {
      return false;
    }
  }

  /// Get manual backup status
  static Future<bool> hasManualBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_manualBackupKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Clear all wallet data
  static Future<bool> clearWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_walletIdKey);
      await prefs.remove(_devicePassCodeIdKey);
      await prefs.remove(_walletNameKey);
      await prefs.remove(_mnemonicKey);
      await prefs.remove(_googleDriveBackupKey);
      await prefs.remove(_manualBackupKey);
      return true;
    } catch (e) {
      return false;
    }
  }
}
