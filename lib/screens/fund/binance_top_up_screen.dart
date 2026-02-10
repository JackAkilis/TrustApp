import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/token_image.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';
import '../receive/receive_detail_screen.dart';

class BinanceTopUpScreen extends StatefulWidget {
  const BinanceTopUpScreen({super.key});

  @override
  State<BinanceTopUpScreen> createState() => _BinanceTopUpScreenState();
}

class _BinanceTopUpScreenState extends State<BinanceTopUpScreen> {
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
          final balance = chain['balance']?.toString() ?? '0';
          final decimals = chain['decimals'] as int? ?? 18;
          
          final key = isToken ? '${chainName}_$symbol' : chainName;
          if (addedSymbols.contains(key)) continue;
          
          final chainDisplayName = _getChainDisplayName(chainName);
          
          // Calculate human-readable balance
          final balanceNum = double.tryParse(balance) ?? 0.0;
          final divisor = double.parse('1' + '0' * decimals);
          final humanReadableBalance = balanceNum / divisor;
          
          cryptoList.add({
            'chain': chainName,
            'symbol': symbol,
            'address': address,
            'chainDisplayName': chainDisplayName,
            'isToken': isToken,
            'balance': humanReadableBalance,
            'balanceRaw': balance,
            'decimals': decimals,
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
    if (chainUpper.contains('AVALANCHE') || chainUpper == 'AVAX') return 'avalanche';
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

  String _getTokenFullName(String symbol) {
    final nameMap = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'SOL': 'Solana',
      'TWT': 'Trust Wallet',
      'BNB': 'BNB Smart Chain',
      'USDT': 'Tether',
      'USDC': 'USD Coin',
      'WBTC': 'Wrapped Bitcoin',
      'BBTC': 'Binance Wrapped BTC',
      'TRX': 'Tron',
    };
    return nameMap[symbol.toUpperCase()] ?? symbol;
  }

  // Popular crypto pairs (symbol + chain) shown in this exact order in the Popular section.
  final List<Map<String, String>> _popularPairs = [
    {'symbol': 'BTC', 'chain': 'BITCOIN'},
    {'symbol': 'ETH', 'chain': 'ETHEREUM'},
    {'symbol': 'SOL', 'chain': 'SOLANA'},
    {'symbol': 'TWT', 'chain': 'BSC'},
    {'symbol': 'BNB', 'chain': 'BSC'},
    {'symbol': 'USDT', 'chain': 'ETHEREUM'},
    {'symbol': 'USDC', 'chain': 'ETHEREUM'},
  ];

  // Helper to build a unique key for a crypto entry based on symbol + chain
  String _cryptoKey(Map<String, dynamic> crypto) {
    final symbol = crypto['symbol']?.toString() ?? '';
    final chainId = crypto['chain']?.toString() ?? '';
    return '${symbol}_$chainId';
  }

  List<Map<String, dynamic>> get _popularCryptoList {
    final List<Map<String, dynamic>> result = [];

    // For each desired popular pair, pick the first matching entry (symbol + chain).
    // If none exists in backend data, we simply skip it (only show backend-supported pairs).
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

  List<Map<String, dynamic>> get _filteredCryptoList {
    var filtered = _cryptoList;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((crypto) {
        final symbol = crypto['symbol']?.toString().toLowerCase() ?? '';
        final chainName = crypto['chainDisplayName']?.toString().toLowerCase() ?? '';
        final fullName = _getTokenFullName(crypto['symbol']?.toString() ?? '').toLowerCase();
        return symbol.contains(_searchQuery) || 
               chainName.contains(_searchQuery) || 
               fullName.contains(_searchQuery);
      }).toList();
    }
    
    return filtered;
  }

  Future<void> _fetchPriceAndShowBalance(String symbol, double balance) async {
    try {
      final price = await ApiService.getTokenPriceUsd(symbol);
      if (price != null && mounted) {
        final usdValue = balance * price;
        // You can show this in a dialog or update UI
        // For now, we'll just navigate to receive detail screen
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final borderColor = ThemeHelper.getBorderColor(context);
    
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
          AppLocalizations.of(context)!.receivingPayment,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: grayColor,
                  borderRadius: BorderRadius.circular(999),
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
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.search,
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
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
            
            // Crypto list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCryptoList.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.noCryptocurrenciesFound,
                            style: TextStyle(
                              fontSize: 16,
                              color: secondaryTextColor,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            // Popular section (grid)
                            if (_popularCryptoList.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  AppLocalizations.of(context)!.popular,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.8,
                                ),
                                itemCount: _popularCryptoList.length,
                                itemBuilder: (context, index) {
                                  final crypto = _popularCryptoList[index];
                                  return _buildPopularCryptoCard(crypto, textColor, secondaryTextColor, grayColor, backgroundColor);
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                            
                            // All crypto section (list)
                            if (_allCryptoList.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  AppLocalizations.of(context)!.allCrypto,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              ..._allCryptoList.map((crypto) => _buildCryptoItem(crypto, textColor, secondaryTextColor, grayColor, backgroundColor, borderColor)),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCryptoCard(
    Map<String, dynamic> crypto,
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
    Color backgroundColor,
  ) {
    final symbol = crypto['symbol']?.toString() ?? '';
    final chainName = crypto['chainDisplayName']?.toString() ?? '';
    final address = crypto['address']?.toString() ?? '';
    final chain = crypto['chain']?.toString() ?? '';
    final isToken = crypto['isToken'] == true;
    final fullName = _getTokenFullName(symbol);
    
    return InkWell(
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
        height: 72,
        decoration: BoxDecoration(
          color: grayColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon: USDT/USDC show token icon + chain overlay; others show chain or token icon
            TokenImage(
              isNativeToken: !isToken,
              chain: isToken ? _getChainKeyForTokenImage(chain) : null,
              tokenName: !isToken ? _getChainKeyForTokenImage(chain) : null,
              tokenAssetName: isToken ? (_getTokenIconAssetForTokenImage(symbol) ?? 'usdt.png') : null,
            ),
            const SizedBox(width: 12),
            // Symbol and chain name on right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Symbol
                  Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Chain name
                  Text(
                    chainName,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoItem(
    Map<String, dynamic> crypto,
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
    Color backgroundColor,
    Color borderColor,
  ) {
    final symbol = crypto['symbol']?.toString() ?? '';
    final chainName = crypto['chainDisplayName']?.toString() ?? '';
    final address = crypto['address']?.toString() ?? '';
    final chain = crypto['chain']?.toString() ?? '';
    final isToken = crypto['isToken'] == true;
    final balance = crypto['balance'] as double? ?? 0.0;
    final fullName = _getTokenFullName(symbol);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
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
        child: Row(
          children: [
            // Crypto icon: USDT/USDC show token icon + chain overlay
            TokenImage(
              isNativeToken: !isToken,
              chain: isToken ? _getChainKeyForTokenImage(chain) : null,
              tokenName: !isToken ? _getChainKeyForTokenImage(chain) : null,
              tokenAssetName: isToken ? (_getTokenIconAssetForTokenImage(symbol) ?? 'usdt.png') : null,
            ),
            const SizedBox(width: 12),
            // Crypto info
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
                    fullName,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            // Balance info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FutureBuilder<double?>(
                  future: ApiService.getTokenPriceUsd(symbol),
                  builder: (context, snapshot) {
                    final price = snapshot.data;
                    final usdValue = price != null ? balance * price : 0.0;
                    return Text(
                      '\$${usdValue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  '${balance.toStringAsFixed(4)} $symbol',
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
