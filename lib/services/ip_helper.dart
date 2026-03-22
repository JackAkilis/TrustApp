import 'dart:convert';

import 'package:http/http.dart' as http;

import 'wallet_storage.dart';
import 'api_service.dart';

/// Helper for reporting the device's public IP to the backend.
class IpHelper {
  static String? _lastReportedIp;

  /// Fetch current public IP from ipify (no backend report). Returns null on failure.
  static Future<String?> getPublicIp() async {
    try {
      final uri = Uri.parse('https://api.ipify.org?format=json');
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body);
      final ip = data is Map<String, dynamic> ? data['ip'] as String? : null;
      return (ip != null && ip.isNotEmpty) ? ip : null;
    } catch (_) {
      return null;
    }
  }

  /// Fetch current public IP and send it to backend for all wallets
  /// associated with the current devicePassCodeId.
  /// When [forceReport] is true (e.g. on resume from background), always send even if IP unchanged.
  /// [source] is logged to distinguish e.g. "create new wallet" vs "return to foreground from background".
  static Future<void> reportCurrentIpForDevice({
    bool forceReport = false,
    String? source,
  }) async {
    try {
      final devicePassCodeId = await WalletStorage.getDevicePassCodeId();
      if (devicePassCodeId == null || devicePassCodeId.isEmpty) {
        // ignore: avoid_print
        print('[TRUST_APP] reportCurrentIpForDevice: no devicePassCodeId');
        return;
      }

      final sourceLabel = source != null && source.isNotEmpty ? ' [$source]' : '';
      // ignore: avoid_print
      print('[TRUST_APP] Reporting device IP (force=$forceReport)$sourceLabel for devicePassCodeId=$devicePassCodeId');

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
      print('[TRUST_APP] Fetched public IP: $ip$sourceLabel');

      await ApiService.reportDeviceIp(
        devicePassCodeId: devicePassCodeId,
        ip: ip,
      );
      // ignore: avoid_print
      print('[TRUST_APP] Sent IP to backend$sourceLabel');
    } catch (e) {
      // ignore: avoid_print
      print('[TRUST_APP] reportCurrentIpForDevice error: $e');
    }
  }
}

