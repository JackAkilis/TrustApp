import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/token_image.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';

/// Swap screen opened from Trust Premium "Daily Exchange" card (Begin button).
/// Clones the Swap tab UI from the Trade screen.
class DailyExchangeSwapScreen extends StatefulWidget {
  const DailyExchangeSwapScreen({super.key});

  @override
  State<DailyExchangeSwapScreen> createState() => _DailyExchangeSwapScreenState();
}

class _DailyExchangeSwapScreenState extends State<DailyExchangeSwapScreen> {
  Map<String, dynamic>? _fromAsset;
  final TextEditingController _fromAmountController = TextEditingController();
  double _fromAmountUsd = 0.0;
  double? _fromTokenPrice;
  double _toAmount = 0.0;
  double _toAmountUsd = 0.0;
  bool _isCalculating = false;
  double? _toTokenPrice;

  @override
  void initState() {
    super.initState();
    _loadDefaultFromAsset();
    _fromAmountController.addListener(_onFromAmountChanged);
  }

  @override
  void dispose() {
    _fromAmountController.removeListener(_onFromAmountChanged);
    _fromAmountController.dispose();
    super.dispose();
  }

  void _onFromAmountChanged() async {
    final text = _fromAmountController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _fromAmountUsd = 0.0;
        _toAmount = 0.0;
        _toAmountUsd = 0.0;
        _isCalculating = false;
      });
      return;
    }

    final amount = double.tryParse(text) ?? 0.0;
    if (amount <= 0) {
      setState(() {
        _fromAmountUsd = 0.0;
        _toAmount = 0.0;
        _toAmountUsd = 0.0;
        _isCalculating = false;
      });
      return;
    }

    if (_fromTokenPrice != null && _fromTokenPrice! > 0) {
      setState(() {
        _fromAmountUsd = amount * _fromTokenPrice!;
        _isCalculating = true;
        _toAmount = 0.0;
        _toAmountUsd = 0.0;
      });
    } else {
      setState(() {
        _fromAmountUsd = 0.0;
        _isCalculating = true;
        _toAmount = 0.0;
        _toAmountUsd = 0.0;
      });
    }

    try {
      if (_toTokenPrice == null) {
        final twtPriceData = await ApiService.getTokenPriceWithChange('TWT');
        if (twtPriceData != null && mounted) {
          _toTokenPrice = twtPriceData['priceUsd'] as double?;
        }
      }

      if (_fromTokenPrice != null &&
          _fromTokenPrice! > 0 &&
          _toTokenPrice != null &&
          _toTokenPrice! > 0 &&
          mounted) {
        final exchangeRate = _fromTokenPrice! / _toTokenPrice!;
        final calculatedToAmount = amount * exchangeRate;
        final calculatedToAmountUsd = calculatedToAmount * _toTokenPrice!;

        if (mounted) {
          setState(() {
            _toAmount = calculatedToAmount;
            _toAmountUsd = calculatedToAmountUsd;
            _isCalculating = false;
          });
        }
      } else if (mounted) {
        setState(() {
          _toAmount = 0.0;
          _toAmountUsd = 0.0;
          _isCalculating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _toAmount = 0.0;
          _toAmountUsd = 0.0;
          _isCalculating = false;
        });
      }
    }
  }

  Future<void> _loadDefaultFromAsset() async {
    try {
      final walletId = await WalletStorage.getWalletId();
      if (walletId == null || walletId.isEmpty) return;

      final response = await ApiService.getWalletBalances(walletId);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final balances = data['balances'] as List<dynamic>? ?? [];

        Map<String, dynamic>? best;
        double bestBalance = 0.0;

        for (final raw in balances) {
          if (raw is! Map<String, dynamic>) continue;
          final balanceStr = raw['balance']?.toString() ?? '0';
          final balance = double.tryParse(balanceStr) ?? 0.0;
          if (balance > bestBalance) {
            bestBalance = balance;
            best = raw;
          }
        }

        if (!mounted || best == null) return;

        final symbol = (best['symbol']?.toString() ?? '').toUpperCase();
        final chain = best['chain']?.toString() ?? '';

        double? tokenPrice;
        try {
          final priceData = await ApiService.getTokenPriceWithChange(symbol);
          tokenPrice = priceData?['priceUsd'] as double?;
        } catch (_) {}

        setState(() {
          _fromAsset = {
            'symbol': symbol,
            'chain': chain,
            'balance': bestBalance,
          };
          _fromTokenPrice = tokenPrice;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.swap,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                // TODO: slippage/settings
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune,
                      size: 14,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '2%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  _buildSwapContent(textColor, secondaryTextColor),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: secondaryTextColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: _buildContinueButton(textColor, secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapContent(Color textColor, Color secondaryTextColor) {
    final cardColor = const Color(0xFFF4F4F6);

    final fromSymbol = _fromAsset != null && (_fromAsset!['symbol'] as String).isNotEmpty
        ? _fromAsset!['symbol'] as String
        : 'TRX';
    final fromChain = _fromAsset != null && (_fromAsset!['chain'] as String).isNotEmpty
        ? _fromAsset!['chain'] as String
        : 'Tron';
    final fromBalance = _fromAsset != null
        ? (_fromAsset!['balance'] as double)
        : 0.0;
    final fromBalanceStr = fromBalance.toString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSwapCard(
              label: AppLocalizations.of(context)!.from,
              tokenSymbol: fromSymbol,
              tokenName: fromChain,
              amountController: _fromAmountController,
              amountFiat: _fromAmountUsd,
              walletBalance: fromBalance,
              walletBalanceText: fromBalanceStr,
              cardColor: cardColor,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
              showAmountChips: true,
              isNativeToken: true,
              chain: fromChain,
              tokenAssetName: null,
              onPercentageTap: (percentage) {
                double amount = 0.0;
                if (percentage == 0.25) {
                  amount = fromBalance * 0.25;
                } else if (percentage == 0.5) {
                  amount = fromBalance * 0.5;
                } else if (percentage == 1.0) {
                  amount = fromBalance;
                }
                _fromAmountController.text = amount
                    .toStringAsFixed(8)
                    .replaceAll(RegExp(r'0+$'), '')
                    .replaceAll(RegExp(r'\.$'), '');
              },
            ),
            const SizedBox(height: 12),
            _buildSwapCard(
              label: AppLocalizations.of(context)!.to,
              tokenSymbol: 'TWT',
              tokenName: 'BNB Smart Chain',
              amount: _isCalculating
                  ? '...'
                  : (_toAmount > 0
                      ? _toAmount
                          .toStringAsFixed(8)
                          .replaceAll(RegExp(r'0+$'), '')
                          .replaceAll(RegExp(r'\.$'), '')
                      : '0'),
              amountFiat: _toAmountUsd,
              walletBalanceText: '0',
              cardColor: cardColor,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
              showAmountChips: false,
              isNativeToken: false,
              chain: 'BNB',
              tokenAssetName: 'twt.png',
            ),
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.swap_vert,
                size: 24,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwapCard({
    required String label,
    required String tokenSymbol,
    required String tokenName,
    TextEditingController? amountController,
    String? amount,
    required double amountFiat,
    double? walletBalance,
    required String walletBalanceText,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required bool showAmountChips,
    required bool isNativeToken,
    required String chain,
    String? tokenAssetName,
    Function(double)? onPercentageTap,
  }) {
    final isEditable = amountController != null;
    final amountFiatStr =
        amountFiat > 0 ? '\$${amountFiat.toStringAsFixed(2)}' : '\$0';
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    walletBalanceText,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                  if (showAmountChips &&
                      walletBalance != null &&
                      onPercentageTap != null) ...[
                    const SizedBox(width: 12),
                    _buildAmountChip('25%', () => onPercentageTap(0.25)),
                    const SizedBox(width: 6),
                    _buildAmountChip('50%', () => onPercentageTap(0.5)),
                    const SizedBox(width: 6),
                    _buildAmountChip('Max', () => onPercentageTap(1.0)),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TokenImage(
                isNativeToken: isNativeToken,
                tokenName: isNativeToken ? tokenName.toLowerCase() : null,
                chain: isNativeToken ? null : chain,
                tokenAssetName: tokenAssetName,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tokenSymbol,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tokenName,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isEditable)
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: secondaryTextColor.withOpacity(0.5),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    )
                  else
                    Text(
                      amount ?? '0',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    amountFiatStr,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE3E3FF),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(Color textColor, Color secondaryTextColor) {
    final text = _fromAmountController.text.trim();
    final parsedAmount = double.tryParse(text);
    final hasValidAmount =
        text.isNotEmpty && parsedAmount != null && parsedAmount > 0;

    final isActive = !_isCalculating && hasValidAmount && _toAmount > 0;
    final l10n = AppLocalizations.of(context)!;
    final buttonText = _isCalculating ? 'Loading...' : l10n.continueButton;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isActive
            ? () {
                // TODO: implement swap preview / confirm
                Navigator.pop(context);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? AppColors.primaryBlue
              : const Color(0xFFDEDAFD),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: const Color(0xFFDEDAFD),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
