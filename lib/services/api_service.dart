import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  /// Backend API base URL (TrustWallet-Like Multi-Chain Backend)


  static const String baseUrl = 'https://dev-wallet.newtwwin.com:7074';

  // Optional: use local backend per platform (uncomment to override [baseUrl] above)
  // static String get baseUrl {
  //   if (kIsWeb) return 'http://localhost:8083';
  //   if (Platform.isAndroid) return 'http://10.0.2.2:8083';
  //   if (Platform.isIOS) return 'http://localhost:8083';
  //   return 'http://127.0.0.1:8083';
  // }


  /// Create device passcode
  static Future<Map<String, dynamic>> createDevicePasscode({
    required String name,
    required String passcode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}/device-passcodes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'passcode': passcode,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create device passcode: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating device passcode: $e');
    }
  }

  /// Create multi-chain wallet
  static Future<Map<String, dynamic>> createWallet({
    required String devicePassCodeId,
    required String walletName,
    required String mnemonic,
    bool isMain = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}/multichain/wallet/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'devicePassCodeId': devicePassCodeId,
          'walletName': walletName,
          'mnemonic': mnemonic,
          'isMain': isMain,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create wallet: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating wallet: $e');
    }
  }

  /// Get wallet balances for all chains
  static Future<Map<String, dynamic>> getWalletBalances(String walletId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/multichain/wallet/$walletId/balances'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get wallet balances: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting wallet balances: $e');
    }
  }

  /// Get wallet summary with balances (legacy - kept for compatibility)
  static Future<Map<String, dynamic>> getWalletSummary(String walletId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/multichain/wallet/$walletId/summary'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get wallet summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting wallet summary: $e');
    }
  }

  /// Get all wallets for a device
  static Future<Map<String, dynamic>> getWalletsByDevice(String devicePassCodeId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/wallet/device/$devicePassCodeId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get wallets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting wallets: $e');
    }
  }

  /// Get live USD price for a token symbol using backend QuickNode/CoinGecko integration
  /// The backend handles symbol-to-CoinGecko-ID mapping automatically
  static Future<double?> getTokenPriceUsd(String symbol) async {
    try {
      // Normalize symbol - uppercase and trim
      final symbolToSend = symbol.toUpperCase().trim();
      
      if (symbolToSend.isEmpty) {
        return null;
      }

      // Call backend API
      final response = await http.get(
        Uri.parse('${baseUrl}/quicknode/price/$symbolToSend'),
        headers: {'Content-Type': 'application/json'},
      );

      // Parse response
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
        // Check if request was successful
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          final price = data['priceUSD'] as num?;
          
          if (price != null && price > 0) {
            return price.toDouble();
          }
        }
      }

      return null;
    } catch (e) {
      // Return null on any error
      return null;
    }
  }

  /// Get top tokens by market cap for \"Popular tokens\" section.
  /// Uses the backend `/market/top` endpoint which proxies official market data.
  static Future<List<dynamic>> getTopTokens({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/market/top?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['success'] == true && body['data'] != null) {
          final data = body['data'];
          // Controller returns { total, tokens: [...] }
          if (data is Map && data['tokens'] is List) {
            return List<dynamic>.from(data['tokens'] as List);
          }
          // Fallback: if data itself is already a list
          if (data is List) {
            return data;
          }
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get live USD price **and** 24h percentage change for a token symbol.
  /// Returns a map with keys: 'priceUsd' and 'change24hPct' (both nullable).
  static Future<Map<String, double?>?> getTokenPriceWithChange(String symbol) async {
    try {
      final symbolToSend = symbol.toUpperCase().trim();
      if (symbolToSend.isEmpty) return null;

      final response = await http.get(
        Uri.parse('${baseUrl}/quicknode/price/$symbolToSend'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          final price = data['priceUSD'] as num?;
          final change = data['change24hPct'] as num?;

          return {
            'priceUsd': price?.toDouble(),
            'change24hPct': change?.toDouble(),
          };
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
