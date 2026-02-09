import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import 'enter_mnemonic_screen.dart';

class SelectNetworkScreen extends StatefulWidget {
  const SelectNetworkScreen({super.key});

  @override
  State<SelectNetworkScreen> createState() => _SelectNetworkScreenState();
}

class _SelectNetworkScreenState extends State<SelectNetworkScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Networks list based on the image
  final List<Map<String, String>> _networks = [
    {'name': 'Bitcoin', 'icon': 'bitcoin.png'},
    {'name': 'Ethereum', 'icon': 'eth.png'},
    {'name': 'XRP', 'icon': 'xrp.png'},
    {'name': 'BNB Smart Chain', 'icon': 'BNB smart.png'},
    {'name': 'Solana', 'icon': 'solana.png'},
    {'name': 'Dogecoin', 'icon': 'dogecoin.png'},
    {'name': 'Cardano', 'icon': 'cardano.png'},
    {'name': 'Tron', 'icon': 'tron.png'},
  ];

  List<Map<String, String>> get _filteredNetworks {
    if (_searchQuery.isEmpty) {
      return _networks;
    }
    return _networks
        .where((network) =>
            network['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMultiCoinWalletSelected() {
    // Navigate to enter mnemonic screen for multi-coin wallet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EnterMnemonicScreen(),
      ),
    );
  }

  void _onNetworkSelected(String networkName) {
    // Navigate to enter mnemonic screen for single network wallet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnterMnemonicScreen(
          selectedNetwork: networkName,
        ),
      ),
    );
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
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select network',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: textColor,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  'i',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            onPressed: () {
              // TODO: Show info dialog
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: grayColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: secondaryTextColor),
                    prefixIcon: Icon(
                      Icons.search,
                      color: secondaryTextColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            // Recommended section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Multi-coin wallet card
                  InkWell(
                    onTap: _onMultiCoinWalletSelected,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: grayColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: textColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/icons/trustwallet.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.shield,
                                    color: primaryColor,
                                    size: 24,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Multi-coin wallet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: secondaryTextColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Recommended badge (positioned like in Create new wallet screen)
                  Positioned(
                    top: -8,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Networks list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredNetworks.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.white,
                ),
                itemBuilder: (context, index) {
                  final network = _filteredNetworks[index];
                  return InkWell(
                    onTap: () => _onNetworkSelected(network['name']!),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: grayColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          // Network icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/chain_icons/${network['icon']}',
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
                          // Network name
                          Expanded(
                            child: Text(
                              network['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          // Chevron
                          Icon(
                            Icons.chevron_right,
                            color: secondaryTextColor,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
