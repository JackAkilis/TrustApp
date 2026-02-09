import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../services/wallet_storage.dart';
import 'manual_backup_intro_bottom_sheet.dart';
import 'google_drive_processing_screen.dart';

class WalletDetailsScreen extends StatefulWidget {
  final String walletId;
  final String walletName;

  const WalletDetailsScreen({
    super.key,
    required this.walletId,
    required this.walletName,
  });

  @override
  State<WalletDetailsScreen> createState() => _WalletDetailsScreenState();
}

class _WalletDetailsScreenState extends State<WalletDetailsScreen> with WidgetsBindingObserver {
  late TextEditingController _nameController;
  bool _hasGoogleDriveBackup = false;
  bool _hasManualBackup = false;
  bool _isNameChanged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _nameController = TextEditingController(text: widget.walletName);
    _nameController.addListener(_onNameChanged);
    _loadBackupStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadBackupStatus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh backup status when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBackupStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final newText = _nameController.text.trim();
    final isChanged = newText != widget.walletName && newText.isNotEmpty;
    if (isChanged != _isNameChanged) {
      setState(() {
        _isNameChanged = isChanged;
      });
    }
  }

  Future<void> _loadBackupStatus() async {
    final manualBackup = await WalletStorage.hasManualBackup();
    final googleDriveBackup = await WalletStorage.hasGoogleDriveBackup();
    setState(() {
      _hasManualBackup = manualBackup;
      _hasGoogleDriveBackup = googleDriveBackup;
    });
  }

  void _showManualBackupIntroBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ManualBackupIntroBottomSheet(),
    );
    
    // Refresh backup status when returning, especially if backup was completed
    if (result == true || mounted) {
      _loadBackupStatus();
    }
  }

  void _clearInput() {
    _nameController.clear();
  }

  Future<void> _saveWalletName() async {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      // Save per-wallet name
      final savedPerWallet = await WalletStorage.saveWalletNameForId(widget.walletId, newName);

      // Also update global current-wallet name if this wallet is current
      final currentWalletId = await WalletStorage.getWalletId();
      if (currentWalletId == widget.walletId) {
        await WalletStorage.saveWalletName(newName);
      }

      if (savedPerWallet && mounted) {
        Navigator.pop(context, newName);
      } else if (mounted) {
        // Show error if save failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save wallet name'),
            duration: Duration(seconds: 2),
          ),
        );
      }
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
          widget.walletName,
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
              Icons.delete_outline,
              color: textColor,
            ),
            onPressed: () {
              // TODO: Handle delete wallet
            },
          ),
          if (_isNameChanged)
            IconButton(
              icon: Icon(
                Icons.check,
                color: textColor,
              ),
              onPressed: _saveWalletName,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name section
            Text(
              'Name',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
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
                    color: grayColor,
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,
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
                            onPressed: _clearInput,
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Backup section
            Text(
              'Mnemonic Backup',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            // Google Drive backup option
            _buildBackupOption(
              context,
              icon: 'assets/icons/google-drive.png',
              title: 'Google Drive',
              status: _hasGoogleDriveBackup ? 'Active' : 'Back up now',
              statusColor: _hasGoogleDriveBackup
                  ? AppColors.primaryGreen
                  : AppColors.errorRed,
              onTap: () async {
                if (!_hasGoogleDriveBackup) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GoogleDriveProcessingScreen(),
                    ),
                  );
                  // Refresh backup status when returning
                  if (result == true || mounted) {
                    _loadBackupStatus();
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            // Manual backup option
            _buildBackupOption(
              context,
              icon: 'assets/icons/manual.png',
              title: 'Manual',
              status: _hasManualBackup ? 'Active' : 'Back up now',
              statusColor: _hasManualBackup
                  ? AppColors.primaryGreen
                  : AppColors.errorRed,
              onTap: () {
                if (!_hasManualBackup) {
                  _showManualBackupIntroBottomSheet(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupOption(
    BuildContext context, {
    required String icon,
    required String title,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    final textColor = ThemeHelper.getTextColor(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            // Icon
            Image.asset(
              icon,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.cloud_upload,
                  color: textColor,
                  size: 24,
                );
              },
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            // Status
            Text(
              status,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
