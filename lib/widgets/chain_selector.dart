import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/theme_helper.dart';
import '../screens/send/chain_list_screen.dart';

class ChainSelector extends StatefulWidget {
  final Function(String)? onChainSelected;

  const ChainSelector({
    super.key,
    this.onChainSelected,
  });

  @override
  State<ChainSelector> createState() => _ChainSelectorState();
}

class _ChainSelectorState extends State<ChainSelector> {
  String _selectedChain = 'All';
  
  final List<Map<String, String?>> _chains = [
    {'name': 'All', 'icon': null, 'fullName': 'All'},
    {'name': 'Bitcoin', 'icon': 'bitcoin.png', 'fullName': 'Bitcoin'},
    {'name': 'Eth', 'icon': 'eth.png', 'fullName': 'Ethereum'},
    {'name': 'Sol', 'icon': 'solana.png', 'fullName': 'Solana'},
    {'name': 'BNB', 'icon': 'BNB smart.png', 'fullName': 'BNB Smart Chain'},
    {'name': 'Tron', 'icon': 'tron.png', 'fullName': 'Tron'},
    {'name': 'Arbitrum', 'icon': 'arbitrum.png', 'fullName': 'Arbitrum'},
    {'name': 'Base', 'icon': 'base.png', 'fullName': 'Base'},
  ];

  // Check if selected chain is in the popular chains list
  bool _isPopularChain(String chainName) {
    if (chainName == 'All') return true;
    for (var chain in _chains) {
      final fullName = chain['fullName'] ?? chain['name'];
      if (fullName == chainName || chain['name'] == chainName) {
        return true;
      }
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final borderColor = ThemeHelper.getBorderColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);
    
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 20),
                ..._chains.map((chain) {
                  // Check if this chain is selected (match by name or fullName)
                  final chainName = chain['name'];
                  final chainFullName = chain['fullName'] ?? chainName;
                  bool isSelected = false;
                  if (_selectedChain == 'All') {
                    isSelected = chainName == 'All';
                  } else {
                    isSelected = (_selectedChain == chainName || 
                                  _selectedChain == chainFullName);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        final fullName = chain['fullName'] ?? chain['name'] ?? 'All';
                        setState(() {
                          _selectedChain = fullName;
                        });
                        widget.onChainSelected?.call(fullName);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? primaryColor : borderColor,
                            width: isSelected ? 2 : 4,
                          ),
                        ),
                        child: chain['icon'] == null
                            ? Center(
                                child: Text(
                                  'All',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? primaryColor : textColor,
                                  ),
                                ),
                              )
                            : ClipOval(
                                child: Image.asset(
                                  'assets/chain_icons/${chain['icon']}',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  );
                }).toList(),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              ChainListScreen(
                            selectedChain: _selectedChain == 'All' ? null : _selectedChain,
                            onChainSelected: (chainName) {
                              setState(() {
                                _selectedChain = chainName;
                              });
                              widget.onChainSelected?.call(chainName);
                            },
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      height: 40, // Same height as other buttons
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: grayColor,
                        borderRadius: BorderRadius.circular(999), // Fully rounded
                        border: Border.all(
                          color: _selectedChain != 'All' && !_isPopularChain(_selectedChain)
                              ? primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '100+',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
