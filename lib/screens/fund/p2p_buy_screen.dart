import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';

class P2PBuyScreen extends StatefulWidget {
  final Map<String, dynamic> selectedCrypto;

  const P2PBuyScreen({
    super.key,
    required this.selectedCrypto,
  });

  @override
  State<P2PBuyScreen> createState() => _P2PBuyScreenState();
}

class _P2PBuyScreenState extends State<P2PBuyScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedCurrency = 'EUR';
  String _selectedCrypto = 'ETH';
  double _cryptoAmount = 0.0;
  bool _isCalculating = false;
  List<Map<String, dynamic>> _cryptoList = [];
  Map<String, dynamic> _currentSelectedCrypto = {};
  Timer? _calculationTimer;

  @override
  void initState() {
    super.initState();
    _currentSelectedCrypto = Map<String, dynamic>.from(widget.selectedCrypto);
    _selectedCrypto = _currentSelectedCrypto['symbol']?.toString() ?? 'ETH';
    _determineCurrency();
    _amountController.addListener(_onAmountChanged);
    _loadCryptoList();
  }

  void _onAmountChanged() {
    // Debounce the calculation to avoid too many API calls
    _calculationTimer?.cancel();
    _calculationTimer = Timer(const Duration(milliseconds: 500), () {
      _calculateCryptoAmount();
    });
  }

  @override
  void dispose() {
    _calculationTimer?.cancel();
    _amountController.dispose();
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

  Future<void> _calculateCryptoAmount() async {
    final amountText = _amountController.text;
    if (amountText.isEmpty) {
      setState(() {
        _cryptoAmount = 0.0;
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        _cryptoAmount = 0.0;
      });
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    try {
      // Get crypto price in USD - ensure we're using the correct symbol
      final symbolToFetch = _selectedCrypto.toUpperCase().trim();
      if (symbolToFetch.isEmpty) {
        setState(() {
          _cryptoAmount = 0.0;
          _isCalculating = false;
        });
        return;
      }
      
      final priceUsd = await ApiService.getTokenPriceUsd(symbolToFetch);
      if (priceUsd != null && priceUsd > 0) {
        // Convert currency amount to USD
        double amountUsd = amount;
        if (_selectedCurrency != 'USD') {
          final exchangeRates = {
            'EUR': 1.1,
            'GBP': 1.27,
            'JPY': 0.0067,
            'CNY': 0.14,
            'KRW': 0.00075,
            'INR': 0.012,
            'AUD': 0.65,
            'CAD': 0.73,
            'CHF': 1.12,
            'SEK': 0.095,
            'NOK': 0.093,
            'DKK': 0.15,
            'PLN': 0.25,
            'BRL': 0.19,
            'MXN': 0.058,
            'ARS': 0.0011,
            'ZAR': 0.053,
            'TRY': 0.031,
            'RUB': 0.011,
            'SGD': 0.74,
            'HKD': 0.13,
            'TWD': 0.031,
            'THB': 0.028,
            'IDR': 0.000064,
            'MYR': 0.21,
            'PHP': 0.018,
            'VND': 0.000041,
          };
          final rate = exchangeRates[_selectedCurrency] ?? 1.0;
          amountUsd = amount * rate;
        }

        // Calculate crypto amount
        final cryptoAmount = amountUsd / priceUsd;
        if (mounted) {
          setState(() {
            _cryptoAmount = cryptoAmount;
            _isCalculating = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _cryptoAmount = 0.0;
            _isCalculating = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cryptoAmount = 0.0;
          _isCalculating = false;
        });
      }
    }
  }

  void _setQuickAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(0);
    // Immediately calculate when quick amount is set
    _calculationTimer?.cancel();
    _calculateCryptoAmount();
  }

  Future<void> _loadCryptoList() async {
    try {
      final walletId = await WalletStorage.getWalletId();
      if (walletId == null || walletId.isEmpty) {
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

          cryptoList.add({
            'chain': chainName,
            'symbol': symbol,
            'address': address,
            'isToken': isToken,
          });

          addedSymbols.add(key);
        }

        setState(() {
          _cryptoList = cryptoList;
        });
      }
    } catch (_) {
      // Ignore errors
    }
  }

  String _getFlagAssetForCurrency(String currency) {
    final flagMap = {
      'USD': 'assets/flag_icons/usd.png',
      'EUR': 'assets/flag_icons/EUR.png',
      'GBP': 'assets/flag_icons/GBP.png',
      'JPY': 'assets/flag_icons/JPY.png',
      'CNY': 'assets/flag_icons/CNY.png',
      'KRW': 'assets/flag_icons/KRW.png',
      'INR': 'assets/flag_icons/INR.png',
      'AUD': 'assets/flag_icons/AUD.png',
      'CAD': 'assets/flag_icons/CAD.png',
      'CHF': 'assets/flag_icons/CHF.png',
      'SEK': 'assets/flag_icons/SEK.png',
      'NOK': 'assets/flag_icons/NOK.png',
      'DKK': 'assets/flag_icons/DKK.png',
      'PLN': 'assets/flag_icons/PLN.png',
      'BRL': 'assets/flag_icons/BRL.png',
      'MXN': 'assets/flag_icons/MXN.png',
      'ARS': 'assets/flag_icons/ARS.png',
      'ZAR': 'assets/flag_icons/ZAR.png',
      'TRY': 'assets/flag_icons/TRY.png',
      'RUB': 'assets/flag_icons/RUB.png',
      'SGD': 'assets/flag_icons/SGD.png',
      'HKD': 'assets/flag_icons/HKD.png',
      'TWD': 'assets/flag_icons/TWD.png',
      'THB': 'assets/flag_icons/THB.png',
      'IDR': 'assets/flag_icons/IDR.png',
      'MYR': 'assets/flag_icons/MYR.png',
      'PHP': 'assets/flag_icons/PHP.png',
      'VND': 'assets/flag_icons/VND.png',
    };
    return flagMap[currency] ?? 'assets/flag_icons/EUR.png';
  }

  String _getChainIcon(String chain) {
    final iconMap = {
      'BITCOIN': 'bitcoin.png',
      'ETHEREUM': 'eth.png',
      'BSC': 'BNB smart.png',
      'SOLANA': 'solana.png',
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

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);

    final isToken = _currentSelectedCrypto['isToken'] == true;
    final chain = _currentSelectedCrypto['chain']?.toString() ?? '';
    final symbol = _selectedCrypto;
    final iconPath = isToken
        ? 'assets/icons/${_getTokenIcon(symbol)}'
        : 'assets/chain_icons/${_getChainIcon(chain)}';

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
          'Buy with P2P',
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
            // Amount display section - centered in remaining space
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Fiat amount
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              child: TextField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 70,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF000000),
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    fontSize: 70,
                                    fontWeight: FontWeight.w700,
                                    color: secondaryTextColor,
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            _buildCurrencySelector(textColor, secondaryTextColor, grayColor, backgroundColor),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Crypto amount
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _isCalculating
                                  ? '...'
                                  : _cryptoAmount > 0
                                      ? _cryptoAmount.toStringAsFixed(6)
                                      : '0',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: secondaryTextColor,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(width: 32),
                            _buildCryptoSelector(textColor, secondaryTextColor, grayColor, backgroundColor, iconPath, symbol),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Quick amount buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAmountButton('100', textColor, primaryColor, grayColor),
                  _buildQuickAmountButton('150', textColor, primaryColor, grayColor),
                  _buildQuickAmountButton('300', textColor, primaryColor, grayColor),
                  _buildQuickAmountButton('550', textColor, primaryColor, grayColor),
                ],
              ),
            ),
            // Binance Connect section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: grayColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Binance icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icons/binance.png',
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
                              child: const Icon(Icons.circle, size: 40),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Binance Connect',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Continue button - fully rounded, no border
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Handle continue action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String amount, Color textColor, Color primaryColor, Color grayColor) {
    return InkWell(
      onTap: () => _setQuickAmount(double.parse(amount)),
      child: Container(
        width: 75,
        height: 36,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
    Color backgroundColor,
  ) {
    final flagAsset = _getFlagAssetForCurrency(_selectedCurrency);

    return SizedBox(
      width: 100,
      height: 44,
      child: Opacity(
        opacity: 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: grayColor,
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipOval(
                child: Image.asset(
                  flagAsset,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 20,
                      height: 20,
                      color: grayColor,
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _selectedCurrency,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                'assets/icons/right.png',
                width: 16,
                height: 16,
                color: secondaryTextColor,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.chevron_right, size: 16, color: secondaryTextColor);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoSelector(
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
    Color backgroundColor,
    String iconPath,
    String symbol,
  ) {
    return SizedBox(
      width: 100,
      height: 44,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          _showCryptoSelectionBottomSheet(context, textColor, secondaryTextColor, grayColor, backgroundColor);
        },
        child: Container(
          decoration: BoxDecoration(
            color: grayColor,
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipOval(
                child: Image.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 20,
                      height: 20,
                      color: grayColor,
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                'assets/icons/right.png',
                width: 16,
                height: 16,
                color: secondaryTextColor,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.chevron_right, size: 16, color: secondaryTextColor);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCryptoSelectionBottomSheet(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
    Color backgroundColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: grayColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Crypto',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: textColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Crypto list
                _cryptoList.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: CircularProgressIndicator(color: ThemeHelper.getPrimaryColor(context)),
                        ),
                      )
                    : Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _cryptoList.length,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemBuilder: (context, index) {
                            final crypto = _cryptoList[index];
                            return _buildCryptoBottomSheetItem(
                              crypto,
                              textColor,
                              secondaryTextColor,
                              grayColor,
                              backgroundColor,
                              setModalState,
                            );
                          },
                        ),
                      ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCryptoBottomSheetItem(
    Map<String, dynamic> crypto,
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
    Color backgroundColor,
    StateSetter setModalState,
  ) {
    final symbol = crypto['symbol']?.toString() ?? '';
    final chain = crypto['chain']?.toString() ?? '';
    final isToken = crypto['isToken'] == true;
    final fullName = _getTokenFullName(symbol);
    final currentChain = _currentSelectedCrypto['chain']?.toString() ?? '';
    final isSelected = _selectedCrypto == symbol && currentChain == chain;
    
    final iconPath = isToken 
        ? 'assets/icons/${_getTokenIcon(symbol)}'
        : 'assets/chain_icons/${_getChainIcon(chain)}';

    return InkWell(
      onTap: () {
        setModalState(() {
          _selectedCrypto = symbol;
          _currentSelectedCrypto = {
            'symbol': symbol,
            'chain': chain,
            'isToken': isToken,
            'address': crypto['address'],
          };
        });
        Navigator.pop(context);
        _calculateCryptoAmount();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
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
                        );
                      },
                    ),
                  ),
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
            Radio<String>(
              value: '${symbol}_$chain',
              groupValue: isSelected ? '${_selectedCrypto}_$currentChain' : null,
              onChanged: (value) {
                setModalState(() {
                  _selectedCrypto = symbol;
                  _currentSelectedCrypto = {
                    'symbol': symbol,
                    'chain': chain,
                    'isToken': isToken,
                    'address': crypto['address'],
                  };
                });
                Navigator.pop(context);
                _calculateCryptoAmount();
              },
            ),
          ],
        ),
      ),
    );
  }
}
