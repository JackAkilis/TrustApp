import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/theme_helper.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';
import '../send/chain_list_screen.dart';
import 'buy_screen.dart';

class GPaySelectCryptoScreen extends StatefulWidget {
  const GPaySelectCryptoScreen({super.key});

  @override
  State<GPaySelectCryptoScreen> createState() => _GPaySelectCryptoScreenState();
}

class _GPaySelectCryptoScreenState extends State<GPaySelectCryptoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedChain = 'All';
  List<Map<String, dynamic>> _cryptoList = [];
  bool _isLoading = true;
  String? _selectedCryptoKey;

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
    };
    return iconMap[chain.toUpperCase()] ?? 'eth.png';
  }

  String _getTokenIcon(String symbol) {
    final tokenIconMap = {
      'USDT': 'usdt.png',
      'USDC': 'usdc.png',
      'TWT': 'twt.png',
      'WBTC': 'wbtc.png',
    };
    final iconName = tokenIconMap[symbol.toUpperCase()] ?? 'token_1.png';
    return 'assets/icons/$iconName';
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
    };
    return nameMap[symbol.toUpperCase()] ?? symbol;
  }

  String _cryptoKey(Map<String, dynamic> crypto) {
    final symbol = crypto['symbol']?.toString() ?? '';
    final chainId = crypto['chain']?.toString() ?? '';
    final address = crypto['address']?.toString() ?? '';
    return '$symbol-$chainId-$address';
  }

  String? _getChainIdFromSelectorName(String? chainName) {
    if (chainName == null || chainName == 'All') return null;
    final chainMap = {
      'Bitcoin': 'BITCOIN',
      'Eth': 'ETHEREUM',
      'Ethereum': 'ETHEREUM',
      'Sol': 'SOLANA',
      'Solana': 'SOLANA',
      'BNB': 'BSC',
      'BNB Smart Chain': 'BSC',
      'Tron': 'TRON',
      'Arbitrum': 'ARBITRUM',
      'Base': 'BASE',
      'Polygon': 'POLYGON',
      'Avalanche': 'AVALANCHE',
      'Fantom': 'FANTOM',
      'Optimism': 'OPTIMISM',
      'Cosmos': 'COSMOS',
      'Vechain': 'VECHAIN',
      'Litecoin': 'LITECOIN',
      'Dogecoin': 'DOGECOIN',
    };
    return chainMap[chainName];
  }

  List<Map<String, dynamic>> get _filteredCryptoList {
    var filtered = _cryptoList;

    if (_selectedChain != null && _selectedChain != 'All') {
      final chainId = _getChainIdFromSelectorName(_selectedChain);
      if (chainId != null) {
        filtered = filtered.where((crypto) {
          return crypto['chain']?.toString().toUpperCase() ==
              chainId.toUpperCase();
        }).toList();
      } else {
        filtered = filtered.where((crypto) {
          final chainDisplayName = crypto['chainDisplayName']?.toString() ?? '';
          return chainDisplayName == _selectedChain;
        }).toList();
      }
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((crypto) {
        final symbol = crypto['symbol']?.toString().toLowerCase() ?? '';
        final chainName =
            crypto['chainDisplayName']?.toString().toLowerCase() ?? '';
        final fullName =
            _getTokenFullName(crypto['symbol']?.toString() ?? '').toLowerCase();
        return symbol.contains(_searchQuery) ||
            chainName.contains(_searchQuery) ||
            fullName.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);

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
          AppLocalizations.of(context)!.selectCrypto,
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
                    Icon(Icons.search,
                        size: 20, color: secondaryTextColor),
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
            const SizedBox(height: 12),
            // All Networks button
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () async {
                    final selectedNetwork = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChainListScreen(
                          selectedChain: _selectedChain,
                          onChainSelected: (chainName) {
                            // ChainListScreen handles the pop and returns the value
                          },
                        ),
                      ),
                    );
                    if (selectedNetwork != null && mounted) {
                      setState(() {
                        _selectedChain = selectedNetwork == 'All' ? 'All' : selectedNetwork;
                      });
                    }
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: grayColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedChain == 'All' ? AppLocalizations.of(context)!.allNetworks : _selectedChain!,
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
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
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                AppLocalizations.of(context)!.allCrypto,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                            ..._filteredCryptoList.map(
                              (crypto) => _buildCryptoItem(
                                crypto,
                                textColor,
                                secondaryTextColor,
                                grayColor,
                                backgroundColor,
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
  ) {
    final symbol = crypto['symbol']?.toString() ?? '';
    final chainName = crypto['chainDisplayName']?.toString() ?? '';
    final chain = crypto['chain']?.toString() ?? '';
    final isToken = crypto['isToken'] == true;
    final fullName = _getTokenFullName(symbol);
    final cryptoKey = _cryptoKey(crypto);
    final isSelected = _selectedCryptoKey == cryptoKey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuyScreen(selectedCrypto: crypto),
            ),
          );
        },
        child: Row(
          children: [
            Stack(
              children: [
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
                    ),
                  ),
                ),
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
                        ),
                      ),
                    ),
                  ),
              ],
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
                    fullName,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: cryptoKey,
              groupValue: _selectedCryptoKey,
              onChanged: (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BuyScreen(selectedCrypto: crypto),
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

