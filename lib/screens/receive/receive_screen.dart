import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';
import '../../widgets/chain_selector.dart';
import 'receive_detail_screen.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedChain;
  List<Map<String, dynamic>> _cryptoList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedChain = 'All';
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
        
        // Build crypto list from chains
        final List<Map<String, dynamic>> cryptoList = [];
        final Set<String> addedSymbols = {}; // Track added symbols to avoid duplicates
        
        for (var chain in chains) {
          final chainName = chain['chain']?.toString() ?? '';
          final symbol = chain['symbol']?.toString() ?? '';
          final address = chain['address']?.toString() ?? '';
          final isToken = chain['isToken'] == true;
          
          // Skip if already added (for native coins) or if it's a token and we want native first
          final key = isToken ? '${chainName}_$symbol' : chainName;
          if (addedSymbols.contains(key)) continue;
          
          // Get chain display name
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
    // Map token symbols to their icon paths
    // If token icon doesn't exist, fallback to generic token icon
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
    // Try token icon first, fallback to generic token icon
    return 'assets/icons/$iconName';
  }

  // Popular crypto pairs (symbol + chain) shown in this exact order in the Popular section.
  // These MUST match the mapping you specified:
  // BTC — Bitcoin
  // ETH — Ethereum
  // SOL — Solana
  // TWT — BNB Smart Chain
  // BNB — BNB Smart Chain
  // USDT — Ethereum
  // USDC — Ethereum
  final List<Map<String, String>> _popularPairs = [
    {'symbol': 'BTC', 'chain': 'BITCOIN'},
    {'symbol': 'ETH', 'chain': 'ETHEREUM'},
    {'symbol': 'SOL', 'chain': 'SOLANA'},
    {'symbol': 'TWT', 'chain': 'BSC'},
    {'symbol': 'BNB', 'chain': 'BSC'},
    {'symbol': 'USDT', 'chain': 'ETHEREUM'},
    {'symbol': 'USDC', 'chain': 'ETHEREUM'},
  ];

  // Map ChainSelector names to chain IDs
  String? _getChainIdFromSelectorName(String? selectorName) {
    if (selectorName == null || selectorName == 'All') return null;
    
    final nameMap = {
      'Bitcoin': 'BITCOIN',
      'Ethereum': 'ETHEREUM',
      'Solana': 'SOLANA',
      'BNB Smart Chain': 'BSC',
      'Tron': 'TRON',
      'Arbitrum': 'ARBITRUM',
      'Base': 'BASE',
    };
    
    return nameMap[selectorName];
  }

  List<Map<String, dynamic>> get _filteredCryptoList {
    var filtered = _cryptoList;
    
    // Filter by selected chain
    if (_selectedChain != null && _selectedChain != 'All') {
      final chainId = _getChainIdFromSelectorName(_selectedChain);
      if (chainId != null) {
        filtered = filtered.where((crypto) {
          return crypto['chain']?.toString().toUpperCase() == chainId.toUpperCase();
        }).toList();
      } else {
        // Try matching by display name if chain ID not found
        filtered = filtered.where((crypto) {
          final chainDisplayName = crypto['chainDisplayName']?.toString() ?? '';
          return chainDisplayName == _selectedChain;
        }).toList();
      }
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((crypto) {
        final symbol = crypto['symbol']?.toString().toLowerCase() ?? '';
        final chainName = crypto['chainDisplayName']?.toString().toLowerCase() ?? '';
        return symbol.contains(_searchQuery) || chainName.contains(_searchQuery);
      }).toList();
    }
    
    return filtered;
  }

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

  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard'),
        duration: Duration(seconds: 2),
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
    
    // Truncate address
    final truncatedAddress = address.length > 12
        ? '${address.substring(0, 6)}...${address.substring(address.length - 6)}'
        : address;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          // Crypto icon
          Stack(
            children: [
              // Main icon: token icon for tokens, chain icon for native coins
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: ClipOval(
                  child: Image.asset(
                    isToken 
                        ? _getTokenIcon(symbol)
                        : 'assets/chain_icons/${_getChainIcon(chain)}',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback: try generic token icon for tokens, or chain icon
                      if (isToken) {
                        return Image.asset(
                          'assets/icons/token_1.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.currency_bitcoin),
                            );
                          },
                        );
                      }
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.currency_bitcoin),
                      );
                    },
                  ),
                ),
              ),
              // Network badge for tokens (shows chain icon)
              if (isToken)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: grayColor,
                      border: Border.all(
                        color: backgroundColor,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/chain_icons/${_getChainIcon(chain)}',
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: grayColor,
                            child: const Icon(Icons.circle, size: 16),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
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
                  truncatedAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          // QR code button
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
          // Copy button
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

  void _showQRCode(String address, String symbol, String chainName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$symbol ($chainName)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              // TODO: Add QR code generation library (qr_flutter)
              Container(
                width: 200,
                height: 200,
                color: Colors.grey[200],
                child: const Center(
                  child: Text('QR Code\n(Add qr_flutter package)'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
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
          'Receive',
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
            // Search bar
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
                          hintText: 'Search',
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
            
            // Chain selector (same as Send screen)
            const SizedBox(height: 12),
            ChainSelector(
              onChainSelected: (chainName) {
                setState(() {
                  _selectedChain = chainName == 'All' ? 'All' : chainName;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Crypto list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCryptoList.isEmpty
                      ? Center(
                          child: Text(
                            'No cryptocurrencies found',
                            style: TextStyle(
                              fontSize: 16,
                              color: secondaryTextColor,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            // Popular section
                            if (_popularCryptoList.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  'Popular',
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
                            
                            // All crypto section
                            if (_allCryptoList.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  'All crypto',
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
