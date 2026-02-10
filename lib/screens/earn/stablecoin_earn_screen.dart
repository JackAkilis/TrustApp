import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_helper.dart';
import '../../widgets/token_image.dart';

class StablecoinEarnScreen extends StatelessWidget {
  const StablecoinEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final cardSurfaceColor = isDarkMode ? AppColors.secondaryGray.withOpacity(0.3) : const Color(0xFFF4F4F6);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.earn,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Earn portfolio card (simple placeholder)
            _buildPortfolioCard(context, textColor, secondaryTextColor, cardSurfaceColor),
            const SizedBox(height: 24),
            // Stablecoin Earn section (placeholder list)
            Text(
              l10n.stablecoinEarn,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildSimpleCard(
              cardSurfaceColor: cardSurfaceColor,
              child: Column(
                children: [
                  _buildStablecoinRow(
                    context,
                    'USDT',
                    'ethereum',
                    '3.65',
                    textColor,
                    secondaryTextColor,
                  ),
                  const SizedBox(height: 12),
                  _buildStablecoinRow(
                    context,
                    'USDC',
                    'ethereum',
                    '3.79',
                    textColor,
                    secondaryTextColor,
                  ),
                  const SizedBox(height: 12),
                  _buildStablecoinRow(
                    context,
                    'USDT',
                    'bnb',
                    '1.6',
                    textColor,
                    secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: secondaryTextColor.withOpacity(0.2),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      l10n.seeAll,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Native Staking placeholder
            Text(
              l10n.nativeStaking,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildSimpleCard(
              cardSurfaceColor: cardSurfaceColor,
              child: Column(
                children: [
                  _buildNativeRow(context, 'Ethereum', 'ethereum', '\$1,919.03', '-7.32%', '2.64', textColor, secondaryTextColor),
                  const SizedBox(height: 12),
                  _buildNativeRow(context, 'BNB Smart Chain', 'bnb', '\$633.01', '-7.27%', '0.97', textColor, secondaryTextColor),
                  const SizedBox(height: 12),
                  _buildNativeRow(context, 'Solana', 'solana', '\$80.98', '-9.88%', '6.61', textColor, secondaryTextColor),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: secondaryTextColor.withOpacity(0.2),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      l10n.seeAll,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioCard(BuildContext context, Color textColor, Color secondaryTextColor, Color cardSurfaceColor) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSimpleCard(
      cardSurfaceColor: cardSurfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myEarnPortfolio,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$0.00',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.totalStakedRewards,
            style: TextStyle(
              fontSize: 12,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: DashedBorderPainter(
                    color: secondaryTextColor.withOpacity(0.2),
                    strokeWidth: 1,
                    borderRadius: 12,
                  ),
                ),
                Center(
                  child: Text(
                    l10n.yourEarningAssetsWillAppearHere,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
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

  Widget _buildSimpleCard({required Color cardSurfaceColor, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardSurfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildStablecoinRow(
    BuildContext context,
    String symbol,
    String chain,
    String percent,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // Use lowercase chain key for TokenImage, but nicer label for text
    final chainKey = chain.toLowerCase();
    final chainLabel =
        chainKey == 'bnb' ? 'BNB Smart Chain' : 'Ethereum';

    return Row(
      children: [
        // Token + chain icon, same style as home screen lists
        TokenImage(
          isNativeToken: false,
          chain: chainKey,
          tokenAssetName: '${symbol.toLowerCase()}.png', // expects e.g. usdt.png, usdc.png
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Text(
              chainLabel,
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l10n.upToPercent(percent),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ThemeHelper.getPrimaryColor(context),
              ),
            ),
            Text(
              'APY',
              style: TextStyle(
                fontSize: 11,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNativeRow(
    BuildContext context,
    String name,
    String chain,
    String price,
    String changePct,
    String percent,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final chainKey = chain.toLowerCase();
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        // Use TokenImage for native tokens
        TokenImage(
          isNativeToken: true,
          chain: chainKey,
          tokenName: chainKey,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  changePct,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l10n.upToPercent(percent),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ThemeHelper.getPrimaryColor(context),
              ),
            ),
            Text(
              'APY',
              style: TextStyle(
                fontSize: 11,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, 
                    size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(borderRadius),
    );

    // Create path for the rounded rectangle
    final path = Path()..addRRect(rrect);

    // Draw dashed border
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(
          distance,
          (distance + dashWidth).clamp(0.0, pathMetric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

