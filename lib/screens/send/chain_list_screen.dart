import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';

class ChainListScreen extends StatefulWidget {
  final String? selectedChain;
  final Function(String)? onChainSelected;

  const ChainListScreen({
    super.key,
    this.selectedChain,
    this.onChainSelected,
  });

  @override
  State<ChainListScreen> createState() => _ChainListScreenState();
}

class _ChainListScreenState extends State<ChainListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Popular networks - order must be preserved (not alphabetical)
  // Order: Bitcoin, Ethereum, Solana, BNB Smart Chain, Tron, Arbitrum, Base
  final List<Map<String, String>> _popularNetworks = [
    {'name': 'Bitcoin', 'icon': 'bitcoin.png'},
    {'name': 'Ethereum', 'icon': 'eth.png'},
    {'name': 'Solana', 'icon': 'solana.png'},
    {'name': 'BNB Smart Chain', 'icon': 'BNB smart.png'},
    {'name': 'Tron', 'icon': 'tron.png'},
    {'name': 'Arbitrum', 'icon': 'arbitrum.png'},
    {'name': 'Base', 'icon': 'base.png'},
  ];

  // All networks from chain_icons folder (A-Z)
  final List<Map<String, String>> _allNetworks = [
    {'name': 'Acala', 'icon': 'acala.png'},
    {'name': 'Aeternity', 'icon': 'aeternity.png'},
    {'name': 'Agoric', 'icon': 'agoric.png'},
    {'name': 'Aion', 'icon': 'aion.png'},
    {'name': 'Akash', 'icon': 'akash.png'},
    {'name': 'Algorand', 'icon': 'algorand.png'},
    {'name': 'Aptos', 'icon': 'aptos.png'},
    {'name': 'Arbitrum', 'icon': 'arbitrum.png'},
    {'name': 'Avalanche', 'icon': 'avalanche.png'},
    {'name': 'Axelar', 'icon': 'axelar.png'},
    {'name': 'Base', 'icon': 'base.png'},
    {'name': 'Bitcoin', 'icon': 'bitcoin.png'},
    {'name': 'Bitcoin Cash', 'icon': 'bitcoin cash.png'},
    {'name': 'Blast', 'icon': 'blast.png'},
    {'name': 'BNB Greenfield', 'icon': 'bnb greenfield.png'},
    {'name': 'BNB Smart Chain', 'icon': 'BNB smart.png'},
    {'name': 'Boba', 'icon': 'boba.png'},
    {'name': 'Bouncebit', 'icon': 'bouncebit.png'},
    {'name': 'Callisto', 'icon': 'callisto.png'},
    {'name': 'Cardano', 'icon': 'cardano.png'},
    {'name': 'Celo', 'icon': 'celo.png'},
    {'name': 'Conflux Espace', 'icon': 'conflux espace.png'},
    {'name': 'Cosmos Hub', 'icon': 'cosmos hub.png'},
    {'name': 'Cronos Chain', 'icon': 'cronos chain.png'},
    {'name': 'Crypto.org', 'icon': 'crypto.org.png'},
    {'name': 'Dash', 'icon': 'dash.png'},
    {'name': 'Decred', 'icon': 'decred.png'},
    {'name': 'Digibyte', 'icon': 'digibyte.png'},
    {'name': 'Dogecoin', 'icon': 'dogecoin.png'},
    {'name': 'Ethereum', 'icon': 'eth.png'},
    {'name': 'Ethereum Classic', 'icon': 'ethereum classic.png'},
    {'name': 'Evmos', 'icon': 'evmos.png'},
    {'name': 'Fantom', 'icon': 'fantom.png'},
    {'name': 'Filecoin', 'icon': 'filecoin.png'},
    {'name': 'FIO', 'icon': 'fio.png'},
    {'name': 'Firo', 'icon': 'firo.png'},
    {'name': 'Flux', 'icon': 'flux.png'},
    {'name': 'Gnosis Chain', 'icon': 'gnosis chain.png'},
    {'name': 'GoChain', 'icon': 'gochain.png'},
    {'name': 'Groestlcoin', 'icon': 'groestlcoin.png'},
    {'name': 'Harmony', 'icon': 'harmony.png'},
    {'name': 'Icon', 'icon': 'icon.png'},
    {'name': 'Internet Computer', 'icon': 'internet computer.png'},
    {'name': 'IoTex', 'icon': 'iotex.png'},
    {'name': 'IoTex EVM', 'icon': 'iotex evm.png'},
    {'name': 'Juno', 'icon': 'juno.png'},
    {'name': 'Kaia', 'icon': 'kaia.png'},
    {'name': 'Kava', 'icon': 'kava.png'},
    {'name': 'Kava EVM', 'icon': 'kava evm.png'},
    {'name': 'Kucoin', 'icon': 'kucoin.png'},
    {'name': 'Kusama', 'icon': 'kusama.png'},
    {'name': 'Linea', 'icon': 'linea.png'},
    {'name': 'Litecoin', 'icon': 'litecoin.png'},
    {'name': 'Manta Pacific', 'icon': 'manta pacific.png'},
    {'name': 'Mantle', 'icon': 'mantle.png'},
    {'name': 'Metis', 'icon': 'metis.png'},
    {'name': 'Moonbeam', 'icon': 'moonbeam.png'},
    {'name': 'Moonriver', 'icon': 'moonriver.png'},
    {'name': 'MultiversX', 'icon': 'multiversx.png'},
    {'name': 'Nano', 'icon': 'nano.png'},
    {'name': 'Native Evmos', 'icon': 'native evmos.png'},
    {'name': 'Native Injective', 'icon': 'native injective.png'},
    {'name': 'Native ZetaChain', 'icon': 'nativezetachain.png'},
    {'name': 'Near', 'icon': 'near.png'},
    {'name': 'Nebulas', 'icon': 'nebulas.png'},
    {'name': 'Neon', 'icon': 'neon.png'},
    {'name': 'Neutron', 'icon': 'neutron.png'},
    {'name': 'Nimiq', 'icon': 'nimiq.png'},
    {'name': 'Ontology', 'icon': 'ontology.png'},
    {'name': 'OP Mainnet', 'icon': 'op mainnet.png'},
    {'name': 'OPBNB', 'icon': 'opbnb.png'},
    {'name': 'Osmosis', 'icon': 'osmosis.png'},
    {'name': 'Plasma Mainnet', 'icon': 'plasma mainnet.png'},
    {'name': 'Polkadot', 'icon': 'polkadot.png'},
    {'name': 'Polygon', 'icon': 'polygon.png'},
    {'name': 'Polygon zkEVM', 'icon': 'polygon zkevm.png'},
    {'name': 'Qtum', 'icon': 'qtum.png'},
    {'name': 'Ravencoin', 'icon': 'ravencoin.png'},
    {'name': 'Ronin', 'icon': 'ronin.png'},
    {'name': 'Scroll', 'icon': 'scroll.png'},
    {'name': 'Sei', 'icon': 'sei.png'},
    {'name': 'Solana', 'icon': 'solana.png'},
    {'name': 'Sonic', 'icon': 'sonic.png'},
    {'name': 'Stargaze', 'icon': 'stargaze.png'},
    {'name': 'Stellar', 'icon': 'stellar.png'},
    {'name': 'Stride', 'icon': 'stride.png'},
    {'name': 'Sui', 'icon': 'sui.png'},
    {'name': 'Terra Classic', 'icon': 'terra classic.png'},
    {'name': 'Tezos', 'icon': 'tezos.png'},
    {'name': 'Theta', 'icon': 'theta.png'},
    {'name': 'Thorchain', 'icon': 'thorchain.png'},
    {'name': 'Thundercore', 'icon': 'thundercore.png'},
    {'name': 'TON', 'icon': 'ton.png'},
    {'name': 'Tron', 'icon': 'tron.png'},
    {'name': 'Vechain', 'icon': 'vechain.png'},
    {'name': 'Viacoin', 'icon': 'viacoin.png'},
    {'name': 'Viction', 'icon': 'viction.png'},
    {'name': 'Wanchain', 'icon': 'wanchain.png'},
    {'name': 'Waves', 'icon': 'waves.png'},
    {'name': 'XRP', 'icon': 'xrp.png'},
    {'name': 'Zcash', 'icon': 'zcash.png'},
    {'name': 'Zeta EVM', 'icon': 'zeta evm.png'},
    {'name': 'Ziliqa', 'icon': 'ziliqa.png'},
    {'name': 'zkLink Nova Mainnet', 'icon': 'zklink nova mainnet.png'},
    {'name': 'zkSync Era', 'icon': 'zksync era.png'},
  ];

  List<Map<String, String>> get _filteredAllNetworks {
    if (_searchQuery.isEmpty) {
      return _allNetworks;
    }
    return _allNetworks
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

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    final borderColor = ThemeHelper.getBorderColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Select network',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Sticky search bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickySearchBarDelegate(
              backgroundColor: backgroundColor,
              grayColor: grayColor,
              secondaryTextColor: secondaryTextColor,
              textColor: textColor,
              searchController: _searchController,
            ),
          ),
          // All networks option
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  widget.onChainSelected?.call('All');
                  Navigator.pop(context, 'All');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: grayColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.language,
                          size: 24,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'All networks',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: borderColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Popular networks section
          if (_searchQuery.isEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Popular networks',
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final network = _popularNetworks[index];
                  final isSelected = widget.selectedChain == network['name'];
                  return _buildNetworkItem(
                    network, 
                    isSelected,
                    textColor: textColor,
                    primaryColor: primaryColor,
                    borderColor: borderColor,
                    grayColor: grayColor,
                    secondaryTextColor: secondaryTextColor,
                    isDarkMode: isDarkMode,
                  );
                },
                childCount: _popularNetworks.length,
              ),
            ),
          ],
          // A-Z networks section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'A-Z networks',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // A-Z networks list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final network = _filteredAllNetworks[index];
                final isSelected = widget.selectedChain == network['name'];
                return _buildNetworkItem(
                  network, 
                  isSelected,
                  textColor: textColor,
                  primaryColor: primaryColor,
                  borderColor: borderColor,
                  grayColor: grayColor,
                  secondaryTextColor: secondaryTextColor,
                  isDarkMode: isDarkMode,
                );
              },
              childCount: _filteredAllNetworks.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkItem(
    Map<String, String> network, 
    bool isSelected, {
    required Color textColor,
    required Color primaryColor,
    required Color borderColor,
    required Color grayColor,
    required Color secondaryTextColor,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () {
        final networkName = network['name']!;
        widget.onChainSelected?.call(networkName);
        Navigator.pop(context, networkName);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/chain_icons/${network['icon']}',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: grayColor,
                      child: Icon(
                        Icons.circle,
                        size: 40,
                        color: secondaryTextColor,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
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
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primaryColor : borderColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 12,
                      color: isDarkMode ? AppColors.darkBackground : AppColors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Delegate for sticky search bar
class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Color backgroundColor;
  final Color grayColor;
  final Color secondaryTextColor;
  final Color textColor;
  final TextEditingController searchController;

  _StickySearchBarDelegate({
    required this.backgroundColor,
    required this.grayColor,
    required this.secondaryTextColor,
    required this.textColor,
    required this.searchController,
  });

  @override
  double get minExtent => 72.0; // 20 padding top + 32 height + 20 padding bottom

  @override
  double get maxExtent => 72.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: grayColor,
            borderRadius: BorderRadius.circular(999), // Fully rounded
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/icons/search_icon_20.png',
                width: 20,
                height: 20,
                color: secondaryTextColor,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for network',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_StickySearchBarDelegate oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor ||
        grayColor != oldDelegate.grayColor ||
        secondaryTextColor != oldDelegate.secondaryTextColor ||
        textColor != oldDelegate.textColor;
  }
}
