import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/token_image.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';
import 'p2p_buy_screen.dart';

class P2PScreen extends StatefulWidget {
  const P2PScreen({super.key});

  @override
  State<P2PScreen> createState() => _P2PScreenState();
}

class _P2PScreenState extends State<P2PScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _cryptoList = [];
  bool _isLoading = true;
  String? _selectedCryptoKey;
  String _selectedCurrency = 'EUR';

  @override
  void initState() {
    super.initState();
    _determineCurrency();
    _loadWalletAddresses();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _determineCurrency() {
    final locale = ui.PlatformDispatcher.instance.locale;
    final countryCode = locale.countryCode ?? 'US';
    
    final currencyMap = {
      'US': 'USD',
      'GB': 'GBP',
      'JP': 'JPY',
      'CN': 'CNY',
      'KR': 'KRW',
      'IN': 'INR',
      'AU': 'AUD',
      'CA': 'CAD',
      'CH': 'CHF',
      'SE': 'SEK',
      'NO': 'NOK',
      'DK': 'DKK',
      'PL': 'PLN',
      'BR': 'BRL',
      'MX': 'MXN',
      'AR': 'ARS',
      'ZA': 'ZAR',
      'TR': 'TRY',
      'RU': 'RUB',
      'SG': 'SGD',
      'HK': 'HKD',
      'TW': 'TWD',
      'TH': 'THB',
      'ID': 'IDR',
      'MY': 'MYR',
      'PH': 'PHP',
      'VN': 'VND',
    };
    
    setState(() {
      _selectedCurrency = currencyMap[countryCode] ?? 'EUR';
    });
  }

  Future<void> _loadWalletAddresses() async {
    try {
      final walletId = await WalletStorage.getWalletId();
      if (walletId == null || walletId.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getWalletSummary(walletId);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final chains = data['chains'] as List<dynamic>? ?? [];

        final List<Map<String, dynamic>> cryptoList = [];
        final Set<String> addedSymbols = {};

        for (var chain in chains) {
          final chainName = chain['chain']?.toString() ?? '';
          final symbol = chain['symbol']?.toString() ?? '';
          final address = chain['address']?.toString() ?? '';
          final isToken = chain['isToken'] == true;

          final key = '$symbol-$chainName-$address';
          if (addedSymbols.contains(key)) continue;

          final chainDisplayName = _getChainDisplayName(chainName);

          cryptoList.add({
            'chain': chainName,
            'symbol': symbol,
            'address': address,
            'chainDisplayName': chainDisplayName,
            'isToken': isToken,
          });

          addedSymbols.add(key);
        }

        setState(() {
          _cryptoList = cryptoList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getChainDisplayName(String chain) {
    final chainMap = {
      'BITCOIN': 'Bitcoin',
      'ETHEREUM': 'Ethereum',
      'SOLANA': 'Solana',
      'BSC': 'BNB Smart Chain',
      'TRON': 'Tron',
      'ARBITRUM': 'Arbitrum',
      'BASE': 'Base',
    };
    return chainMap[chain.toUpperCase()] ?? chain;
  }

  String _getTokenFullName(String symbol) {
    final nameMap = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'BNB': 'BNB Smart Chain',
      'SOL': 'Solana',
      'TRX': 'Tron',
      'USDT': 'Tether',
      'USDC': 'USD Coin',
      'MATIC': 'Polygon',
      'AVAX': 'Avalanche',
      'LINK': 'Chainlink',
      'UNI': 'Uniswap',
      'ATOM': 'Cosmos',
      'DOT': 'Polkadot',
      'ADA': 'Cardano',
      'XRP': 'Ripple',
      'DOGE': 'Dogecoin',
      'LTC': 'Litecoin',
    };
    return nameMap[symbol.toUpperCase()] ?? symbol;
  }

  String _getChainIcon(String chain) {
    final iconMap = {
      'BITCOIN': 'bitcoin.png',
      'ETHEREUM': 'eth.png',
      'SOLANA': 'solana.png',
      'BSC': 'BNB smart.png',
      'TRON': 'tron.png',
      'ARBITRUM': 'arbitrum.png',
      'BASE': 'base.png',
    };
    return iconMap[chain.toUpperCase()] ?? 'eth.png';
  }

  String _getTokenIcon(String symbol) {
    final iconMap = {
      'USDT': 'usdt.png',
      'USDC': 'usdc.png',
      'WBTC': 'wbtc.png',
      'WETH': 'weth.png',
    };
    return iconMap[symbol.toUpperCase()] ?? '${symbol.toLowerCase()}.png';
  }

  String _getChainKeyForTokenImage(String chain) {
    final chainUpper = chain.toUpperCase();
    if (chainUpper.contains('BITCOIN') || chainUpper == 'BTC') return 'bitcoin';
    if (chainUpper.contains('ETHEREUM') || chainUpper == 'ETH') return 'ethereum';
    if (chainUpper.contains('SOLANA') || chainUpper == 'SOL') return 'solana';
    if (chainUpper.contains('BSC') || chainUpper.contains('BNB')) return 'bsc';
    if (chainUpper.contains('TRON') || chainUpper == 'TRX') return 'tron';
    return chain.toLowerCase();
  }

  String? _getTokenIconAssetForTokenImage(String symbol) {
    final m = {'USDT': 'usdt.png', 'USDC': 'usdc.png'};
    return m[symbol.toUpperCase()];
  }

  List<Map<String, dynamic>> get _filteredCryptoList {
    if (_searchQuery.isEmpty) {
      return _cryptoList;
    }
    return _cryptoList.where((crypto) {
      final symbol = crypto['symbol']?.toString().toLowerCase() ?? '';
      final fullName = _getTokenFullName(crypto['symbol']?.toString() ?? '').toLowerCase();
      return symbol.contains(_searchQuery) || fullName.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Crypto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: secondaryTextColor),
                prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                filled: true,
                fillColor: grayColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Available to pair header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available to $_selectedCurrency pair',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),
            ),
          ),
          // Crypto list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : _filteredCryptoList.isEmpty
                    ? Center(
                        child: Text(
                          'No cryptocurrencies found',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredCryptoList.length,
                        itemBuilder: (context, index) {
                          final crypto = _filteredCryptoList[index];
                          return _buildCryptoItem(crypto, textColor, secondaryTextColor, grayColor, backgroundColor);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoItem(
    Map<String, dynamic> crypto,
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
    Color backgroundColor,
  ) {
    final symbol = crypto['symbol']?.toString() ?? '';
    final chain = crypto['chain']?.toString() ?? '';
    final isToken = crypto['isToken'] == true;
    final fullName = _getTokenFullName(symbol);
    final key = '$symbol-$chain';
    final isSelected = _selectedCryptoKey == key;

    final chainKey = _getChainKeyForTokenImage(chain);
    final tokenIconAsset = _getTokenIconAssetForTokenImage(symbol);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => P2PBuyScreen(
              selectedCrypto: crypto,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Crypto icon: USDT/USDC show token icon + chain overlay
            TokenImage(
              isNativeToken: !isToken,
              chain: isToken ? chainKey : null,
              tokenName: !isToken ? chainKey : null,
              tokenAssetName: isToken ? (tokenIconAsset ?? _getTokenIcon(symbol).split('/').last) : null,
            ),
            const SizedBox(width: 12),
            // Symbol and full name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fullName,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            // Radio button
            Radio<String>(
              value: key,
              groupValue: _selectedCryptoKey,
              onChanged: (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => P2PBuyScreen(
                      selectedCrypto: crypto,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
