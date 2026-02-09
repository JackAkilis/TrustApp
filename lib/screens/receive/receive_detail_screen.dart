import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/theme_helper.dart';
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';

class ReceiveDetailScreen extends StatefulWidget {
  final String symbol;
  final String chainName;
  final String address;

  const ReceiveDetailScreen({
    super.key,
    required this.symbol,
    required this.chainName,
    required this.address,
  });
  
  @override
  State<ReceiveDetailScreen> createState() => _ReceiveDetailScreenState();
}

class _ReceiveDetailScreenState extends State<ReceiveDetailScreen> {
  String? _amountText;
  double? _amountUsd;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    // Use fixed #333333 for main text elements in this screen
    const Color primaryTextColor = Color(0xFF333333);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final warningBackground = const Color(0xFFFFF7E6);
    final warningIconColor = const Color(0xFFFFA000);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Receiving',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Open Trust Wallet official website
              final uri = Uri.parse('https://trustwallet.com');
              launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.info_outline, color: primaryTextColor),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Warning banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: warningBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: warningIconColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Only send ${widget.chainName} (${widget.symbol}) network assets to this address. '
                        'Otherwise, other assets will be permanently lost.',
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Token header (symbol + chain badge)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.symbol,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getGrayColor(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.chainName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // QR code (no gray background, fully filled)
              QrImageView(
                data: widget.address,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),

              const SizedBox(height: 16),

              // Full address text (same width as QR, centered)
              SizedBox(
                width: 220,
                child: Text(
                  widget.address,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Amount + fiat row (if amount is set)
              if (_amountText != null && _amountUsd != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF777777),
                        ),
                        children: [
                          TextSpan(
                            text: '$_amountText ${widget.symbol}',
                            style: const TextStyle(
                              color: Color(0xFF111111),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' ≈ \$${_amountUsd!.toStringAsFixed(2)}',
                            // keep default style (slightly lighter gray)
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _amountText = null;
                          _amountUsd = null;
                        });
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF777777),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],

              // Action buttons: Copy, Set amount, Share
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  _ActionButton(
                    icon: Icons.tune,
                    label: 'Set Amount',
                    onTap: () {
                      _showSetAmountDialog(context);
                    },
                  ),
                  _ActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () {
                      // TODO: Implement share flow
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Deposit from trading platform section (visual only)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeHelper.getGrayColor(context), // Keep gray background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.15), // Semi blue circle background
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_downward,
                        color: AppColors.primaryBlue, // Main blue arrow
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deposit from the trading platform',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Direct transfer through personal account',
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
            ],
          ),
        ),
      ),
    );
  }
}

extension on _ReceiveDetailScreenState {
  Future<void> _showSetAmountDialog(BuildContext context) async {
    final controller = TextEditingController(text: _amountText);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Enter Amount'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Amount',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) return;

    final parsed = double.tryParse(result);
    if (parsed == null || parsed <= 0) return;

    final priceUsd = await ApiService.getTokenPriceUsd(widget.symbol);
    if (!mounted) return;

    if (priceUsd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch token price'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _amountText = result;
      _amountUsd = parsed * priceUsd;
    });
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final grayColor = ThemeHelper.getGrayColor(context);
    const Color textColor = Color(0xFF333333);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: grayColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

