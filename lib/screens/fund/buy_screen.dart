import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';

class BuyScreen extends StatefulWidget {
  final Map<String, dynamic> selectedCrypto;

  const BuyScreen({
    super.key,
    required this.selectedCrypto,
  });

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
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
    // Calculate initial amount if there's a default value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_amountController.text.isNotEmpty) {
        _calculateCryptoAmount();
      }
    });
  }

  void _onAmountChanged() {
    // Debounce the calculation to avoid too many API calls
    _calculationTimer?.cancel();
    _calculationTimer = Timer(const Duration(milliseconds: 500), () {
      _calculateCryptoAmount();
    });
  }

  String _getFlagAssetForCurrency(String currency) {
    // Map currency codes to flag icons in assets/flag_icons
    // Note: filenames in flag_icons folder use currency codes (e.g., usd.png, eur.png)
    final map = {
      'USD': 'usd.png',
      'EUR': 'EUR.png',
      'GBP': 'GBP.png',
      'JPY': 'JPY.png',
      'CNY': 'cny.png',
      'KRW': 'KRW.png',
      'INR': 'INR.png',
      'AUD': 'AUD.png',
      'CAD': 'CAD.png',
      'CHF': 'CHF.png',
      'SEK': 'SEK.png',
      'NOK': 'NOK.png',
      'DKK': 'DKK.png',
      'PLN': 'PLN.png',
      'BRL': 'BRL.png',
      'MXN': 'MXN.png',
      'ARS': 'ARS.png',
      'ZAR': 'ZAR.png',
      'TRY': 'TRY.png',
      'RUB': 'RUB.png',
      'SGD': 'SGD.png',
      'HKD': 'HKD.png',
      'TWD': 'TWD.png',
      'THB': 'THB.png',
      'IDR': 'IDR.png',
      'MYR': 'MYR.png',
      'PHP': 'PHP.png',
      'VND': 'VND.png',
    };
    final file = map[currency] ?? 'usd.png';
    return 'assets/flag_icons/$file';
  }

  @override
  void dispose() {
    _calculationTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  void _determineCurrency() {
    // Get device locale and determine currency
    final locale = ui.PlatformDispatcher.instance.locale;
    final countryCode = locale.countryCode ?? 'US';
    
    // Map country codes to currencies
    final currencyMap = {
      'US': 'USD',
      'GB': 'GBP',
      'EU': 'EUR',
      'DE': 'EUR',
      'FR': 'EUR',
      'IT': 'EUR',
      'ES': 'EUR',
      'NL': 'EUR',
      'BE': 'EUR',
      'AT': 'EUR',
      'PT': 'EUR',
      'IE': 'EUR',
      'FI': 'EUR',
      'GR': 'EUR',
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
        // Convert currency amount to USD (simplified - in production, use real exchange rates)
        double amountUsd = amount;
        if (_selectedCurrency != 'USD') {
          // For demo, assume 1 EUR = 1.1 USD, etc. In production, fetch real rates
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
        // Price not found - reset crypto amount
        if (mounted) {
          setState(() {
            _cryptoAmount = 0.0;
            _isCalculating = false;
          });
        }
      }
    } catch (e) {
      // Error fetching price - reset crypto amount
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
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buy',
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
                            _buildCryptoSelector(textColor, secondaryTextColor, grayColor, backgroundColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Quick amount buttons - above payment method
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAmountButton('25', textColor, secondaryTextColor, grayColor, primaryColor),
                  _buildQuickAmountButton('50', textColor, secondaryTextColor, grayColor, primaryColor),
                  _buildQuickAmountButton('100', textColor, secondaryTextColor, grayColor, primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Payment method section - at bottom above Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: grayColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Cards icon (Visa + MoonPay)
                    Image.asset(
                      'assets/icons/cards.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.credit_card),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Card',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'with MoonPay',
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

  Widget _buildCurrencySelector(
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
    Color backgroundColor,
  ) {
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final flagAsset = _getFlagAssetForCurrency(_selectedCurrency);

    return SizedBox(
      width: 100,
      height: 44,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          // TODO: Show currency selection dialog
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
              // Flag icon
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _selectedCurrency,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                'assets/icons/right.png',
                width: 12,
                height: 12,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.keyboard_arrow_right,
                    size: 16,
                    color: secondaryTextColor,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
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
      'WMTX': 'wmtx.png',
      'BBTC': 'bbtc.png',
      'WBTC': 'wbtc.png',
      'TRX': 'trx.png',
    };
    
    final iconName = tokenIconMap[symbol.toUpperCase()] ?? 'token_1.png';
    return 'assets/icons/$iconName';
  }

  Widget _buildCryptoSelector(
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
    Color backgroundColor,
  ) {
    // Determine if it's a token or native coin based on selectedCrypto data
    final isToken = _currentSelectedCrypto['isToken'] == true;
    final chain = _currentSelectedCrypto['chain']?.toString() ?? '';
    final symbol = _selectedCrypto;
    
    // Use token icon for tokens, chain icon for native coins
    final iconPath = isToken 
        ? _getTokenIcon(symbol)
        : 'assets/chain_icons/${_getChainIcon(chain)}';
    
    return SizedBox(
      width: 100,
      height: 44,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          _showCryptoSelectionBottomSheet();
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
              // Token/Coin icon
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: Icon(
                        Icons.diamond,
                        size: 14,
                        color: secondaryTextColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _selectedCrypto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                'assets/icons/right.png',
                width: 12,
                height: 12,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.keyboard_arrow_right,
                    size: 16,
                    color: secondaryTextColor,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(
    String amount,
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
    Color primaryColor,
  ) {
    return SizedBox(
      width: 100,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => _setQuickAmount(double.parse(amount)),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        ),
      ),
    );
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

  String _getChainDisplayName(String chain) {
    final chainMap = {
      'BITCOIN': 'Bitcoin',
      'ETHEREUM': 'Ethereum',
      'BSC': 'BNB Smart Chain',
      'SOLANA': 'Solana',
      'TRON': 'Tron',
      'POLYGON': 'Polygon',
    };
    return chainMap[chain.toUpperCase()] ?? chain;
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
        final Set<String> addedKeys = {};

        for (var chain in chains) {
          final chainName = chain['chain']?.toString() ?? '';
          final symbol = chain['symbol']?.toString() ?? '';
          final address = chain['address']?.toString() ?? '';
          final isToken = chain['isToken'] == true;

          final key = isToken ? '${chainName}_$symbol' : chainName;
          if (addedKeys.contains(key)) continue;

          final chainDisplayName = _getChainDisplayName(chainName);

          cryptoList.add({
            'chain': chainName,
            'symbol': symbol,
            'address': address,
            'chainDisplayName': chainDisplayName,
            'isToken': isToken,
          });

          addedKeys.add(key);
        }

        setState(() {
          _cryptoList = cryptoList;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _showCryptoSelectionBottomSheet() {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Reload if list is empty
          if (_cryptoList.isEmpty) {
            _loadCryptoList().then((_) {
              if (mounted) {
                setModalState(() {});
              }
            });
          }

          return Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
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
                          child: CircularProgressIndicator(color: primaryColor),
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
                              primaryColor,
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
    Color primaryColor,
  ) {
    final symbol = crypto['symbol']?.toString() ?? '';
    final chainName = crypto['chainDisplayName']?.toString() ?? '';
    final chain = crypto['chain']?.toString() ?? '';
    final isToken = crypto['isToken'] == true;
    final fullName = _getTokenFullName(symbol);
    final currentChain = _currentSelectedCrypto['chain']?.toString() ?? '';
    final isSelected = _selectedCrypto == symbol && currentChain == chain;
    
    // Use token icon for tokens, chain icon for native coins
    final iconPath = isToken 
        ? _getTokenIcon(symbol)
        : 'assets/chain_icons/${_getChainIcon(chain)}';

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCrypto = symbol;
          // Update the selected crypto data
          _currentSelectedCrypto = {
            'symbol': symbol,
            'chain': chain,
            'isToken': isToken,
            'chainDisplayName': crypto['chainDisplayName'],
            'address': crypto['address'],
          };
        });
        Navigator.pop(context);
        // Recalculate crypto amount with new selection
        _calculateCryptoAmount();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Icon with network badge for tokens
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      iconPath,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.currency_bitcoin),
                        );
                      },
                    ),
                  ),
                ),
                // Network badge for tokens
                if (isToken)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
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
                          width: 16,
                          height: 16,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: grayColor,
                              child: const Icon(Icons.circle, size: 12),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
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
              value: '${symbol}_$chain',
              groupValue: isSelected ? '${_selectedCrypto}_$currentChain' : null,
              onChanged: (value) {
                setState(() {
                  _selectedCrypto = symbol;
                  _currentSelectedCrypto = {
                    'symbol': symbol,
                    'chain': chain,
                    'isToken': isToken,
                    'chainDisplayName': crypto['chainDisplayName'],
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
