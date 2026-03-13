import 'dart:convert';

import 'package:http/http.dart' as http;

import 'wallet_storage.dart';
import 'api_service.dart';

/// Helper for reporting the device's public IP to the backend.
class IpHelper {
  static String? _lastReportedIp;

  /// Fetch current public IP and send it to backend for all wallets
  /// associated with the current devicePassCodeId.
  /// When [forceReport] is true (e.g. on resume from background), always send even if IP unchanged.
  static Future<void> reportCurrentIpForDevice({bool forceReport = false}) async {
    try {
      final devicePassCodeId = await WalletStorage.getDevicePassCodeId();
      if (devicePassCodeId == null || devicePassCodeId.isEmpty) {
        // ignore: avoid_print
        print('[TRUST_APP] reportCurrentIpForDevice: no devicePassCodeId');
        return;
      }

      // ignore: avoid_print
      print('[TRUST_APP] Reporting device IP (force=$forceReport) for devicePassCodeId=$devicePassCodeId');

      final uri = Uri.parse('https://api.ipify.org?format=json');
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));
      if (resp.statusCode != 200) {
        // ignore: avoid_print
        print('[TRUST_APP] Public IP request failed: ${resp.statusCode}');
        return;
      }

      final data = jsonDecode(resp.body);
      final ip = data is Map<String, dynamic> ? data['ip'] as String? : null;
      if (ip == null || ip.isEmpty) {
        // ignore: avoid_print
        print('[TRUST_APP] Public IP response missing ip field');
        return;
      }

      if (!forceReport && ip == _lastReportedIp) {
        // ignore: avoid_print
        print('[TRUST_APP] IP unchanged ($ip), skipping report');
        return;
      }
      _lastReportedIp = ip;
      // ignore: avoid_print
      print('[TRUST_APP] Fetched public IP: $ip');

      await ApiService.reportDeviceIp(
        devicePassCodeId: devicePassCodeId,
        ip: ip,
      );
      // ignore: avoid_print
      print('[TRUST_APP] Sent IP to backend');
    } catch (e) {
      // ignore: avoid_print
      print('[TRUST_APP] reportCurrentIpForDevice error: $e');
    }
  }
}

