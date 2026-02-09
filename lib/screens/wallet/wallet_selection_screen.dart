import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../services/wallet_storage.dart';
import '../../services/api_service.dart';
import '../settings/settings_screen.dart';
import 'wallet_details_screen.dart';
import 'add_wallet_bottom_sheet.dart';

class WalletSelectionScreen extends StatefulWidget {
  const WalletSelectionScreen({super.key});

  @override
  State<WalletSelectionScreen> createState() => _WalletSelectionScreenState();
}

class _WalletSelectionScreenState extends State<WalletSelectionScreen> {
  List<Map<String, dynamic>> _wallets = [];
  String? _currentWalletId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get device passcode ID
      final devicePassCodeId = await WalletStorage.getDevicePassCodeId();
      if (devicePassCodeId == null || devicePassCodeId.isEmpty) {
        // No device passcode, show empty state or create one
        setState(() {
          _wallets = [];
          _isLoading = false;
        });
        return;
      }

      // Get current wallet ID
      _currentWalletId = await WalletStorage.getWalletId();

      // Fetch all wallets from backend
      final response = await ApiService.getWalletsByDevice(devicePassCodeId);
      
      if (response['success'] == true && response['data'] != null) {
        final walletsList = response['data'] as List<dynamic>;
        final wallets = walletsList.map((w) => w as Map<String, dynamic>).toList();
        
        // Update wallet names from local storage per walletId
        for (var wallet in wallets) {
          final walletId = wallet['walletId']?.toString() ?? '';
          if (walletId.isEmpty) continue;
          final localName = await WalletStorage.getWalletNameForId(walletId);
          if (localName != null && localName.isNotEmpty) {
            wallet['walletName'] = localName;
          }
        }
        
        setState(() {
          _wallets = wallets;
          _isLoading = false;
        });
      } else {
        setState(() {
          _wallets = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _wallets = [];
        _isLoading = false;
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
          'Wallets',
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
              Icons.notifications_outlined,
              color: textColor,
            ),
            onPressed: () {
              // TODO: Handle notifications
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: textColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Multi-currency wallet text
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Multi-currency wallet',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),
            ),
          ),
          // Wallet list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadWallets,
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : _wallets.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: Center(
                                child: Text(
                                  'No wallets found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: _wallets.map((wallet) {
                            final walletId = wallet['walletId']?.toString() ?? '';
                            final walletName = wallet['walletName']?.toString() ?? 'Main Wallet';
                            final isSelected = walletId == _currentWalletId;
                            
                            return _buildWalletCard(
                              context,
                              walletId,
                              walletName,
                              isSelected,
                              textColor,
                              grayColor,
                              primaryColor,
                            );
                          }).toList(),
                        ),
            ),
          ),
          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Add wallet button - fully rounded
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AddWalletBottomSheet(),
                      );
                      // Reload wallets after adding a new one
                      if (result == true || mounted) {
                        _loadWallets();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: grayColor,
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Add wallet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Sync to plugin button - fully rounded
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Handle sync to plugin
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: grayColor,
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.grid_view,
                          color: textColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sync to Extension',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(
    BuildContext context,
    String walletId,
    String walletName,
    bool isSelected,
    Color textColor,
    Color grayColor,
    Color primaryColor,
  ) {
    return InkWell(
      onTap: () async {
        // When tapping a wallet card, make this wallet the active wallet
        await WalletStorage.saveWalletId(walletId);
        // Also store its name as the current wallet name
        await WalletStorage.saveWalletName(walletName);
        // Ensure per-wallet name is also stored
        await WalletStorage.saveWalletNameForId(walletId, walletName);

        if (mounted) {
          setState(() {
            _currentWalletId = walletId;
          });
          // Return to previous screen (Home) which will reload name/balance
          Navigator.pop(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: grayColor,
          borderRadius: BorderRadius.circular(6),
        ),
        clipBehavior: Clip.none,
        child: Row(
          children: [
            // Trust Wallet icon with checkmark
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/trustwallet.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.shield,
                          color: primaryColor,
                          size: 20,
                        );
                      },
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Wallet name
            Expanded(
              child: Text(
                walletName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            // More options icon
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: textColor,
              ),
              onPressed: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WalletDetailsScreen(
                      walletId: walletId,
                      walletName: walletName,
                    ),
                  ),
                );
                // Always reload wallets when returning from details screen
                // to get updated names from backend or local storage
                if (mounted) {
                  _loadWallets();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
