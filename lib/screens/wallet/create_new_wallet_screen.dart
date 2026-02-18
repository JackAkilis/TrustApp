import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';
import '../../services/passcode_storage.dart';
import '../auth/wallet_ready_screen.dart';

class CreateNewWalletScreen extends StatefulWidget {
  const CreateNewWalletScreen({super.key});

  @override
  State<CreateNewWalletScreen> createState() => _CreateNewWalletScreenState();
}

class _CreateNewWalletScreenState extends State<CreateNewWalletScreen> {
  bool _showSecretPhraseDetails = false;
  bool _showSwiftDetails = false;

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
          'Create new wallet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Secret phrase option
              _buildWalletOption(
                context,
                isRecommended: true,
                icon: Icons.edit_outlined,
                iconColor: AppColors.primaryBlue,
                iconBackgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                title: 'Secret phrase',
                subtitle: 'Show details',
                showDetails: _showSecretPhraseDetails,
                onShowDetailsToggle: () {
                  setState(() {
                    _showSecretPhraseDetails = !_showSecretPhraseDetails;
                  });
                },
                onCreate: () async {
                  await _createSecretPhraseWallet(context);
                },
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                grayColor: grayColor,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 16),
              // Swift option
              _buildWalletOption(
                context,
                isRecommended: false,
                icon: Icons.settings_outlined,
                iconColor: AppColors.primaryBlue,
                iconBackgroundColor: const Color(0xFFD4D3F3), // light purple/blue background
                title: 'Swift',
                badge: 'Beta',
                subtitle: 'Show details',
                showDetails: _showSwiftDetails,
                onShowDetailsToggle: () {
                  setState(() {
                    _showSwiftDetails = !_showSwiftDetails;
                  });
                },
                onCreate: () {
                  // TODO: Navigate to Swift wallet creation flow
                },
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                grayColor: grayColor,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 20), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletOption(
    BuildContext context, {
    required bool isRecommended,
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    String? badge,
    required String subtitle,
    required bool showDetails,
    required VoidCallback onShowDetailsToggle,
    required VoidCallback onCreate,
    required Color textColor,
    required Color secondaryTextColor,
    required Color grayColor,
    required Color primaryColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: grayColor,
        borderRadius: BorderRadius.circular(12),
        border: isRecommended
            ? Border.all(
                color: primaryColor,
                width: 1,
              )
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Recommended badge
          if (isRecommended)
            Positioned(
              top: -8,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(999), // Fully rounded
                ),
                child: const Text(
                  'Recommended',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title, badge, and show details (vertically stacked)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and badge row
                          Row(
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              if (badge != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(999), // Fully rounded
                                  ),
                                  child: Text(
                                    badge,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Show/Hide details row
                          InkWell(
                            onTap: onShowDetailsToggle,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  showDetails ? 'Hide details' : 'Show details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  showDetails
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: secondaryTextColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Create button
                    ElevatedButton(
                      onPressed: onCreate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRecommended
                            ? primaryColor
                            : Colors.black.withOpacity(0.15), // Darker than card bg
                        foregroundColor: isRecommended
                            ? Colors.white
                            : secondaryTextColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                // Details content (expandable)
                if (showDetails) ...[
                  const SizedBox(height: 16),
                  _buildDetailsSection(
                    context,
                    title: 'Security',
                    description: isRecommended
                        ? 'Create and recover wallet with a 12, 18 or 24-word secret phrase. You must manually store this, or back up with Google Drive storage.'
                        : 'Create and recover wallet with Face ID or fingerprint. This is done automatically with your device\'s passkey.',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailsSection(
                    context,
                    title: 'Transaction',
                    description: isRecommended
                        ? 'Transactions are available on more networks (chains), but requires more steps to complete.'
                        : 'Transactions are available on 8 EVM networks (chains) currently, but complete in fewer, simpler steps.',
                    chainIcons: isRecommended
                        ? _getSecretPhraseChainIcons()
                        : _getSwiftChainIcons(),
                    moreText: isRecommended ? '+ 88 more chains' : '+ more to come',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailsSection(
                    context,
                    title: 'Fees',
                    description: isRecommended
                        ? 'Pay network fee (gas) with native tokens only. For example, if your transaction is on the Ethereum network, you can only pay for this fee with ETH.'
                        : 'Pay network fee (gas) with any of our 200+ tokens. Regardless of the transaction network, you can pay this fee with any token that has enough balance.',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(
    BuildContext context, {
    required String title,
    required String description,
    List<Widget>? chainIcons,
    String? moreText,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
          ),
        ),
        if (chainIcons != null && chainIcons.isNotEmpty) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...chainIcons,
                if (moreText != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    moreText,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _getSecretPhraseChainIcons() {
    return [
      _buildChainIconFromAsset('assets/chain_icons/bitcoin.png'), // Bitcoin
      _buildChainIconFromAsset('assets/chain_icons/BNB smart.png'), // BNB
      _buildChainIconFromAsset('assets/chain_icons/eth.png'), // Ethereum
      _buildChainIconFromAsset('assets/chain_icons/polygon.png'), // Polygon
      _buildChainIconFromAsset('assets/chain_icons/tron.png'), // Tron
    ];
  }

  List<Widget> _getSwiftChainIcons() {
    return [
      _buildChainIconFromAsset('assets/chain_icons/eth.png'), // Ethereum
      _buildChainIconFromAsset('assets/chain_icons/BNB smart.png'), // BNB
      _buildChainIconFromAsset('assets/chain_icons/polygon.png'), // Polygon
      _buildChainIconFromAsset('assets/chain_icons/arbitrum.png'), // Arbitrum
      _buildChainIconFromAsset('assets/chain_icons/base.png'), // Base
    ];
  }

  Widget _buildChainIconFromAsset(String assetPath) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(right: 8),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        assetPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to a simple colored circle if icon not found
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline,
              size: 16,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Future<void> _createSecretPhraseWallet(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false, // Prevent back button
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ThemeHelper.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/animations/loading.gif',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const CircularProgressIndicator();
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Creating wallet...',
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeHelper.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Try to reuse existing device passcode ID if available.
      // This ensures all wallets for this user are attached to the same device,
      // so they all appear together in the wallets list.
      String? devicePassCodeId = await WalletStorage.getDevicePassCodeId();

      if (devicePassCodeId == null || devicePassCodeId.isEmpty) {
        // No device passcode yet – create one.
        // Get the saved passcode (or use a default if not found)
        String? passcode = await PasscodeStorage.getPasscode();
        
        // If no passcode exists, we need to create one
        // For now, we'll use a default or prompt the user
        if (passcode == null || passcode.isEmpty) {
          // Generate a default passcode or use device ID
          passcode = 'default_passcode_${DateTime.now().millisecondsSinceEpoch}';
          await PasscodeStorage.savePasscode(passcode);
        }

        // Generate a unique device name (using timestamp)
        final deviceName = 'Mobile_${DateTime.now().millisecondsSinceEpoch}';

        // Step 1: Create device passcode on backend
        final deviceResponse = await ApiService.createDevicePasscode(
          name: deviceName,
          passcode: passcode,
        );

        if (!deviceResponse['success'] || deviceResponse['data'] == null) {
          throw Exception('Failed to create device passcode');
        }

        devicePassCodeId = deviceResponse['data']['serverPasscodeId'] as String;
        
        // Save device passcode ID locally
        await WalletStorage.saveDevicePassCodeId(devicePassCodeId);
      }

      // Step 2: Generate mnemonic
      final mnemonic = bip39.generateMnemonic();
      
      // Save mnemonic locally
      await WalletStorage.saveMnemonic(mnemonic);

      // Step 3: Create wallet on backend
      // Wait a bit to show loading (minimum 2 seconds for UX)
      await Future.delayed(const Duration(seconds: 2));
      
      // Determine if this should be marked as main wallet:
      // only the very first wallet isMain = true.
      final existingWalletId = await WalletStorage.getWalletId();
      final isFirstWallet = existingWalletId == null || existingWalletId.isEmpty;

      final defaultWalletName = await _nextDefaultWalletName(
        devicePassCodeId: devicePassCodeId,
      );

      final walletResponse = await ApiService.createWallet(
        devicePassCodeId: devicePassCodeId,
        walletName: defaultWalletName,
        mnemonic: mnemonic,
        isMain: isFirstWallet,
      );

      if (!walletResponse['success'] || walletResponse['data'] == null) {
        throw Exception('Failed to create wallet');
      }

      final walletId = walletResponse['data']['walletId'] as String;
      final walletName =
          walletResponse['data']['walletName'] as String? ?? defaultWalletName;

      // Save wallet info locally (only if this is the first wallet / main wallet)
      // Don't overwrite existing wallet if user is adding a second wallet.
      if (isFirstWallet) {
        // First wallet - save as current
        await WalletStorage.saveWalletId(walletId);
        await WalletStorage.saveWalletName(walletName);
      }
      // Always save per-wallet name so WalletSelection shows unique names.
      await WalletStorage.saveWalletNameForId(walletId, walletName);

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        // Navigate to wallet ready screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WalletReadyScreen(),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to create wallet: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Returns "Main Wallet" for the first wallet, then "Main Wallet 2", "Main Wallet 3", etc.
  Future<String> _nextDefaultWalletName({required String devicePassCodeId}) async {
    const base = 'Main Wallet';
    try {
      final response = await ApiService.getWalletsByDevice(devicePassCodeId);
      if (response['success'] == true && response['data'] is List) {
        final wallets = List<dynamic>.from(response['data'] as List);
        final nextIndex = wallets.length + 1;
        return nextIndex <= 1 ? base : '$base $nextIndex';
      }
    } catch (_) {
      // ignore - fall back to base
    }
    return base;
  }
}
