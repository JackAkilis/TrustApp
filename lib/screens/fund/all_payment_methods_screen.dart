import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';
import 'buy_screen.dart';

class AllPaymentMethodsScreen extends StatefulWidget {
  const AllPaymentMethodsScreen({super.key});

  @override
  State<AllPaymentMethodsScreen> createState() => _AllPaymentMethodsScreenState();
}

class _AllPaymentMethodsScreenState extends State<AllPaymentMethodsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _cryptoList = [];
  bool _isLoading = true;
  String? _selectedCryptoKey;
  String _selectedTab = 'All';
  String _selectedChainFilter = 'All';
  late TabController _tabController;

  final List<String> _tabs = ['All', 'Top 100', 'Stables', 'Watchlist'];
  
  final List<Map<String, String>> _chainFilters = [
    {'name': 'All', 'icon': ''},
    {'name': 'Bitcoin', 'icon': 'bitcoin.png'},
    {'name': 'Ethereum', 'icon': 'eth.png'},
    {'name': 'Solana', 'icon': 'solana.png'},
    {'name': 'BNB', 'icon': 'BNB smart.png'},
    {'name': 'Tron', 'icon': 'tron.png'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabs[_tabController.index];
      });
    });
    _loadWalletAddresses();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      'SOLANA': 'Solana',
      'BSC': 'BNB Smart Chain',
      'TRON': 'Tron',
      'ARBITRUM': 'Arbitrum',
      'BASE': 'Base',
      'POLYGON': 'Polygon',
      'POLYGON_ZKEVM': 'Polygon zkEVM',
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
      'POLYGON': 'polygon.png',
      'POLYGON_ZKEVM': 'polygon zkevm.png',
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

  List<Map<String, dynamic>> get _filteredCryptoList {
    var filtered = _cryptoList;

    // Filter by chain
    if (_selectedChainFilter != 'All') {
      filtered = filtered.where((crypto) {
        final chainDisplayName = crypto['chainDisplayName']?.toString() ?? '';
        return chainDisplayName == _selectedChainFilter;
      }).toList();
    }

    // Filter by tab
    if (_selectedTab == 'Stables') {
      filtered = filtered.where((crypto) {
        final symbol = crypto['symbol']?.toString().toUpperCase() ?? '';
        return symbol == 'USDT' || symbol == 'USDC' || symbol == 'BUSD' || symbol == 'DAI';
      }).toList();
    } else if (_selectedTab == 'Top 100') {
      // For now, just return all - can be enhanced with ranking data
      filtered = filtered;
    } else if (_selectedTab == 'Watchlist') {
      // For now, return empty - can be enhanced with watchlist
      filtered = [];
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((crypto) {
        final symbol = crypto['symbol']?.toString().toLowerCase() ?? '';
        final fullName = _getTokenFullName(crypto['symbol']?.toString() ?? '').toLowerCase();
        final chainName = crypto['chainDisplayName']?.toString().toLowerCase() ?? '';
        return symbol.contains(_searchQuery) || 
               fullName.contains(_searchQuery) || 
               chainName.contains(_searchQuery);
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: grayColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 20, color: secondaryTextColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: 'Search',
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
              // Tab bar
              Container(
                height: 48,
                child: TabBar(
                  controller: _tabController,
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  labelColor: primaryColor,
                  unselectedLabelColor: secondaryTextColor,
                  indicatorColor: primaryColor,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Chain filter chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _chainFilters.length,
              itemBuilder: (context, index) {
                final filter = _chainFilters[index];
                final isSelected = _selectedChainFilter == filter['name'];
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedChainFilter = filter['name']!;
                      });
                    },
                    child: Container(
                      width: filter['name'] == 'All' ? 60 : 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: primaryColor, width: 2)
                            : null,
                      ),
                      child: filter['name'] == 'All'
                          ? Center(
                              child: Text(
                                'All',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? primaryColor : textColor,
                                ),
                              ),
                            )
                          : Center(
                              child: Image.asset(
                                'assets/chain_icons/${filter['icon']}',
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: grayColor,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
                );
              },
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
    final chainDisplayName = crypto['chainDisplayName']?.toString() ?? '';
    final fullName = isToken ? _getTokenFullName(symbol) : chainDisplayName;
    final key = '$symbol-$chain';
    final isSelected = _selectedCryptoKey == key;

    // Use token icon for tokens, chain icon for native coins
    final iconPath = isToken
        ? 'assets/icons/${_getTokenIcon(symbol)}'
        : 'assets/chain_icons/${_getChainIcon(chain)}';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyScreen(
              selectedCrypto: crypto,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Crypto icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  ClipOval(
                    child: Image.asset(
                      iconPath,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: grayColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.circle, size: 40, color: grayColor),
                        );
                      },
                    ),
                  ),
                  // Network badge for tokens
                  if (isToken)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/chain_icons/${_getChainIcon(chain)}',
                            width: 12,
                            height: 12,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
                    builder: (context) => BuyScreen(
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
