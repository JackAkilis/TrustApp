import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/chain_selector.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedChain;
  List<Map<String, dynamic>> _assets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _loadAssets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final walletId = await WalletStorage.getWalletId();
      if (walletId == null || walletId.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getWalletBalances(walletId);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final balances = data['balances'] as List<dynamic>? ?? [];

        final List<Map<String, dynamic>> assets = [];

        for (var balanceData in balances) {
          try {
            final balanceStr = balanceData['balance']?.toString() ?? '0';
            final humanReadableBalance = double.tryParse(balanceStr) ?? 0.0;

            if (humanReadableBalance <= 0) {
              continue;
            }

            final symbol = (balanceData['symbol']?.toString() ?? '').toUpperCase();
            final chain = balanceData['chain']?.toString() ?? '';
            if (symbol.isEmpty || chain.isEmpty) continue;

            // Get USD price
            final priceInfo = await ApiService.getTokenPriceWithChange(symbol);
            final priceUsd = priceInfo?['priceUsd'] ?? 0.0;
            final balanceUsd = humanReadableBalance * priceUsd;

            assets.add({
              'symbol': symbol,
              'chain': chain,
              'balance': humanReadableBalance,
              'balanceUsd': balanceUsd,
              'icon': _getChainIcon(chain),
            });
          } catch (e) {
            continue;
          }
        }

        setState(() {
          _assets = assets;
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

  String _getChainIcon(String chain) {
    final chainUpper = chain.toUpperCase();
    if (chainUpper.contains('BITCOIN') || chainUpper == 'BTC') {
      return 'bitcoin.png';
    } else if (chainUpper.contains('ETHEREUM') || chainUpper == 'ETH') {
      return 'eth.png';
    } else if (chainUpper.contains('SOLANA') || chainUpper == 'SOL') {
      return 'solana.png';
    } else if (chainUpper.contains('BSC') || chainUpper.contains('BNB')) {
      return 'BNB smart.png';
    } else if (chainUpper.contains('TRON') || chainUpper == 'TRX') {
      return 'tron.png';
    } else if (chainUpper.contains('AVALANCHE') || chainUpper == 'AVAX') {
      return 'avalanche.png';
    }
    return 'eth.png'; // Default
  }

  String _getChainName(String chain) {
    final chainUpper = chain.toUpperCase();
    if (chainUpper.contains('BITCOIN') || chainUpper == 'BTC') {
      return 'Bitcoin';
    } else if (chainUpper.contains('ETHEREUM') || chainUpper == 'ETH') {
      return 'Ethereum';
    } else if (chainUpper.contains('SOLANA') || chainUpper == 'SOL') {
      return 'Solana';
    } else if (chainUpper.contains('BSC') || chainUpper.contains('BNB')) {
      return 'BNB Smart Chain';
    } else if (chainUpper.contains('TRON') || chainUpper == 'TRX') {
      return 'Tron';
    } else if (chainUpper.contains('AVALANCHE') || chainUpper == 'AVAX') {
      return 'Avalanche';
    }
    return chain;
  }

  List<Map<String, dynamic>> get _filteredAssets {
    var filtered = _assets;

    // Filter by selected chain
    if (_selectedChain != null && _selectedChain != 'All') {
      filtered = filtered.where((asset) {
        final chain = asset['chain'] as String;
        final chainName = _getChainName(chain);
        // Match by chain name or check if chain contains the selected chain name
        return chainName == _selectedChain || 
               chain.toUpperCase().contains(_selectedChain!.toUpperCase()) ||
               _selectedChain!.toUpperCase().contains(chain.toUpperCase());
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((asset) {
        final symbol = asset['symbol'].toString().toLowerCase();
        final chain = asset['chain'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return symbol.contains(query) || chain.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.send,
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
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: grayColor,
                  borderRadius: BorderRadius.circular(999), // Fully rounded
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
                      style: TextStyle(
                        fontSize: 14,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                        color: secondaryTextColor,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Chain selector
            const SizedBox(height: 12),
            ChainSelector(
              onChainSelected: (chainName) {
                setState(() {
                  _selectedChain = chainName;
                });
              },
            ),
            const SizedBox(height: 16),
            // Assets list
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : _filteredAssets.isEmpty
                      ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/search_doc.png',
                      width: 64,
                      height: 64,
                      color: isDarkMode ? secondaryTextColor : null,
                      colorBlendMode: isDarkMode ? BlendMode.srcIn : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                                'No assets found',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredAssets.length,
                          itemBuilder: (context, index) {
                            final asset = _filteredAssets[index];
                            return _buildAssetItem(asset, textColor, secondaryTextColor, grayColor);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetItem(
    Map<String, dynamic> asset,
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
  ) {
    final symbol = asset['symbol'] as String;
    final chain = asset['chain'] as String;
    final balance = asset['balance'] as double;
    final balanceUsd = asset['balanceUsd'] as double;
    final iconPath = asset['icon'] as String;
    final chainName = _getChainName(chain);

    return InkWell(
                      onTap: () {
        // TODO: Navigate to send amount screen
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/chain_icons/$iconPath',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: grayColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.circle,
                      color: secondaryTextColor,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Name and chain
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
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: grayColor,
                          borderRadius: BorderRadius.circular(999), // Fully rounded
                        ),
                        child: Text(
                          chainName,
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chainName,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            // Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${balanceUsd.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${balance.toStringAsFixed(2)} $symbol',
                  style: TextStyle(
                    fontSize: 12,
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
