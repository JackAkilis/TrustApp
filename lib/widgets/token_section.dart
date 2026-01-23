import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../constants/app_colors.dart';
import 'token_list_item.dart';

class TokenSection extends StatefulWidget {
  final String title;
  final List<String> tabs;
  final int selectedTabIndex;
  final String subtitle;
  final List<TokenItemData> items;
  final String viewAllText;
  final Function(int)? onTabChanged;
  final VoidCallback? onViewAll;

  const TokenSection({
    super.key,
    required this.title,
    required this.tabs,
    this.selectedTabIndex = 0,
    required this.subtitle,
    required this.items,
    required this.viewAllText,
    this.onTabChanged,
    this.onViewAll,
  });

  @override
  State<TokenSection> createState() => _TokenSectionState();
}

class _TokenSectionState extends State<TokenSection> {
  late int _selectedTabIndex;
  final ScrollController _tabScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.selectedTabIndex;
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title - outside the gray container
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              height: 20 / 16, // line height 20 / font size 16
              fontWeight: FontWeight.w600,
              color: AppColors.mainBlack,
            ),
          ),
          const SizedBox(height: 12),
          // Gray container with content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Horizontal scrollable tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: SizedBox(
                        height: 40,
                        child: SingleChildScrollView(
                          controller: _tabScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: widget.tabs.asMap().entries.map((entry) {
                              final index = entry.key;
                              final label = entry.value;
                              final isSelected = _selectedTabIndex == index;
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index < widget.tabs.length - 1 ? 50 : 0,
                                ),
                                child: _buildSectionTab(label, index, isSelected),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryGray,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // List items
                    ...widget.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < widget.items.length - 1 ? 12 : 0,
                        ),
                        child: TokenListItem(
                          rank: item.rank,
                          name: item.name,
                          price: item.price,
                          marketCap: item.marketCap,
                          change: item.change,
                          isPositive: item.isPositive,
                          icon: item.icon,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    // Separator above "View all"
                    Container(
                      height: 1,
                      color: const Color(0xFFE1E1E1),
                    ),
                    const SizedBox(height: 12),
                    // View all link - centered and blue
                    Center(
                      child: GestureDetector(
                        onTap: widget.onViewAll,
                        child: Text(
                          widget.viewAllText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Border under tabs - ignores container padding
                Positioned(
                  left: 0,
                  right: 0,
                  top: 40, // Height of tab bar
                  child: Container(
                    height: 1,
                    color: const Color(0xFFE1E1E1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTab(String label, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        widget.onTabChanged?.call(index);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.mainBlack : AppColors.secondaryGray,
                ),
              ),
              const SizedBox(height: 4),
              // Spacer
              const SizedBox(height: 0),
            ],
          ),
          // Blue underline - positioned at bottom to overlap border, width matches text
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final textPainter = TextPainter(
                    text: TextSpan(
                      text: label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    textDirection: TextDirection.ltr,
                  );
                  textPainter.layout();
                  return Container(
                    width: textPainter.width,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Data class for token items
class TokenItemData {
  final int rank;
  final String name;
  final String price;
  final String marketCap;
  final String change;
  final bool isPositive;
  final String? icon;

  TokenItemData({
    required this.rank,
    required this.name,
    required this.price,
    required this.marketCap,
    required this.change,
    required this.isPositive,
    this.icon,
  });
}
