import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/token_image.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';
import 'receive_detail_screen.dart';

/// Select Crypto screen — same layout as Receive screen but with title "Select Crypto".
/// Used for: Crypto wallet option in Fund your wallet, Sell button on home.
class SelectCryptoScreen extends StatefulWidget {
  const SelectCryptoScreen({super.key});

  @override
  State<SelectCryptoScreen> createState() => _SelectCryptoScreenState();
}

class _SelectCryptoScreenState extends State<SelectCryptoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _cryptoList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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

          final key = isToken ? '${chainName}_$symbol' : chainName;
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getChainDisplayName(String chain) {
    final chainMap = {
      'BITCOIN': 'Bitcoin',
      'ETHEREUM': 'Ethereum',
      'BSC': 'BNB Smart Chain',
      'SOLANA': 'Solana',
      'TRON': 'Tron',
      'POLYGON': 'Polygon',
      'ARBITRUM': 'Arbitrum',
      'OPTIMISM': 'Optimism',
      'AVALANCHE': 'Avalanche',
      'FANTOM': 'Fantom',
      'BASE': 'Base',
      'COSMOS': 'Cosmos',
      'VECHAIN': 'Vechain',
      'LITECOIN': 'Litecoin',
      'DOGECOIN': 'Dogecoin',
    };
    return chainMap[chain.toUpperCase()] ?? chain;
  }

  String _getChainIcon(String chain) {
    final iconMap = {
      'BITCOIN': 'bitcoin.png',
      'ETHEREUM': 'eth.png',
      'BSC': 'BNB smart.png',
      'SOLANA': 'solana.png',
      'TRON': 'tron.png',
      'POLYGON': 'polygon.png',
      'ARBITRUM': 'arbitrum.png',
      'OPTIMISM': 'optimism.png',
      'AVALANCHE': 'avalanche.png',
      'FANTOM': 'fantom.png',
      'BASE': 'base.png',
      'COSMOS': 'cosmos.png',
      'VECHAIN': 'vechain.png',
      'LITECOIN': 'litecoin.png',
      'DOGECOIN': 'dogecoin.png',
    };
    return iconMap[chain.toUpperCase()] ?? 'eth.png';
  }

  String _getTokenIcon(String symbol) {
    final tokenIconMap = {
      'USDT': 'usdt.png',
      'USDC': 'usdc.png',
      'TWT': 'twt.png',
      'WMTX': 'wmtx.png',
      'BBTC': 'bbtc.png',
      'WBTC': 'wbtc.png',
      'TRX': 'trx.png',
    };

    final iconName = tokenIconMap[symbol.toUpperCase()] ?? 'token_1.png';
    return 'assets/icons/$iconName';
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
    final m = {
      'USDT': 'usdt.png',
      'USDC': 'usdc.png',
      'TWT': 'twt.png',
      'WMTX': 'WMTX.png',
    };
    return m[symbol.toUpperCase()];
  }

  final List<Map<String, String>> _popularPairs = [
    {'symbol': 'BTC', 'chain': 'BITCOIN'},
    {'symbol': 'ETH', 'chain': 'ETHEREUM'},
    {'symbol': 'SOL', 'chain': 'SOLANA'},
    {'symbol': 'TWT', 'chain': 'BSC'},
    {'symbol': 'BNB', 'chain': 'BSC'},
    {'symbol': 'USDT', 'chain': 'ETHEREUM'},
    {'symbol': 'USDC', 'chain': 'ETHEREUM'},
  ];

  List<Map<String, dynamic>> get _filteredCryptoList {
    var filtered = _cryptoList;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((crypto) {
        final symbol = crypto['symbol']?.toString().toLowerCase() ?? '';
        final chainName = crypto['chainDisplayName']?.toString().toLowerCase() ?? '';
        return symbol.contains(_searchQuery) || chainName.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  String _cryptoKey(Map<String, dynamic> crypto) {
    final symbol = crypto['symbol']?.toString() ?? '';
    final chainId = crypto['chain']?.toString() ?? '';
    return '${symbol}_$chainId';
  }

  List<Map<String, dynamic>> get _popularCryptoList {
    final List<Map<String, dynamic>> result = [];

    for (final pair in _popularPairs) {
      final targetSymbol = pair['symbol']!;
      final targetChain = pair['chain']!;

      Map<String, dynamic>? match;
      for (final crypto in _filteredCryptoList) {
        final symbol = crypto['symbol']?.toString() ?? '';
        final chainId = crypto['chain']?.toString() ?? '';
        if (symbol == targetSymbol && chainId.toUpperCase() == targetChain.toUpperCase()) {
          match = crypto;
          break;
        }
      }

      if (match != null) {
        result.add(match);
      }
    }

    return result;
  }

  List<Map<String, dynamic>> get _allCryptoList {
    final popularKeys = _popularCryptoList.map(_cryptoKey).toSet();
    return _filteredCryptoList.where((crypto) {
      return !popularKeys.contains(_cryptoKey(crypto));
    }).toList();
  }

  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.addressCopiedToClipboard),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildCryptoItem(Map<String, dynamic> crypto) {
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final backgroundColor = ThemeHelper.getBackgroundColor(context);

    final symbol = crypto['symbol']?.toString() ?? '';
    final chainName = crypto['chainDisplayName']?.toString() ?? '';
    final address = (crypto['address'] ?? '').toString();
    final chain = crypto['chain']?.toString() ?? '';
    final isToken = crypto['isToken'] == true;

    final truncatedAddress = address.length > 12
        ? '${address.substring(0, 6)}...${address.substring(address.length - 6)}'
        : address;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          TokenImage(
            isNativeToken: !isToken,
            chain: isToken ? _getChainKeyForTokenImage(chain) : null,
            tokenName: !isToken ? _getChainKeyForTokenImage(chain) : null,
            tokenAssetName: isToken ? (_getTokenIconAssetForTokenImage(symbol) ?? _getTokenIcon(symbol).split('/').last) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      symbol,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        chainName,
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  truncatedAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReceiveDetailScreen(
                    symbol: symbol,
                    chainName: chainName,
                    address: address,
                  ),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: grayColor,
              ),
              child: Icon(Icons.qr_code_2, color: secondaryTextColor),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _copyAddress(address),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: grayColor,
              ),
              child: Icon(Icons.copy, color: secondaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.selectCrypto,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: grayColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/search_icon_20.png',
                      width: 20,
                      height: 20,
                      color: secondaryTextColor,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: l10n.search,
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCryptoList.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noCryptocurrenciesFound,
                            style: TextStyle(
                              fontSize: 16,
                              color: secondaryTextColor,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            if (_popularCryptoList.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  l10n.popular,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              ..._popularCryptoList.map((crypto) => _buildCryptoItem(crypto)),
                              const SizedBox(height: 24),
                            ],
                            if (_allCryptoList.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  l10n.allCrypto,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              ..._allCryptoList.map((crypto) => _buildCryptoItem(crypto)),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
