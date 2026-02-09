import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/theme_helper.dart';
import '../../services/trust_premium_storage.dart';
import 'trust_premium_screen.dart';

/// Multi-step onboarding for Trust Premium. Shown only the first time the user
/// taps "Begin" on the Trust Premium card. After complete or skip, never shown again.
class TrustPremiumOnboardingScreen extends StatefulWidget {
  const TrustPremiumOnboardingScreen({super.key});

  @override
  State<TrustPremiumOnboardingScreen> createState() =>
      _TrustPremiumOnboardingScreenState();
}

class _TrustPremiumOnboardingScreenState
    extends State<TrustPremiumOnboardingScreen> {
  static const int _totalSteps = 4;
  final PageController _pageController = PageController();

  int _currentPage = 0;

  Future<void> _completeOnboardingAndGoToPremium() async {
    await TrustPremiumStorage.setHasCompletedOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TrustPremiumScreen()),
    );
  }

  void _onSkip() {
    _completeOnboardingAndGoToPremium();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProgressIndicator(textColor, secondaryTextColor, primaryColor),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomePage(textColor, secondaryTextColor, primaryColor),
                  _buildGoldPage(textColor, secondaryTextColor, primaryColor),
                  _buildLockTwtPage(textColor, secondaryTextColor, primaryColor),
                  _buildKeepActivePage(textColor, secondaryTextColor, primaryColor),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  _buildPrimaryButton(primaryColor, textColor),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _currentPage == 3
                        ? () {
                            // Optional: open help URL or show info
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Learn more at Trust Premium')),
                            );
                          }
                        : _onSkip,
                    child: Text(
                      _currentPage == 3 ? 'Learn more' : AppLocalizations.of(context)!.skip,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
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

  Widget _buildProgressIndicator(
      Color textColor, Color secondaryTextColor, Color primaryColor) {
    const double circleSize = 24;
    const double connectorHeight = 2;
    final grayColor = secondaryTextColor.withOpacity(0.3);
    // Last page index is 3 (4 steps: 0,1,2,3)
    final isLastPage = _currentPage == 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int index = 0; index < _totalSteps; index++) ...[
            if (index > 0)
              Expanded(
                child: Container(
                  height: connectorHeight,
                  color: (isLastPage ? true : _currentPage >= index) ? primaryColor : grayColor,
                ),
              ),
            _buildProgressCircle(
              index: index,
              circleSize: circleSize,
              primaryColor: primaryColor,
              grayColor: grayColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCircle({
    required int index,
    required double circleSize,
    required Color primaryColor,
    required Color grayColor,
  }) {
    final isLastPage = _currentPage == 3;
    // Current or completed: main blue circle + white checkmark
    final isCurrentOrCompleted = isLastPage ? true : index <= _currentPage;
    // Next page: semi blue border, white bg, small blue dot
    final isNext = !isLastPage && index == _currentPage + 1;
    // Other: gray circle, white bg
    final isOther = !isCurrentOrCompleted && !isNext;

    if (isCurrentOrCompleted) {
      return Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor,
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }

    if (isNext) {
      return Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFD4D3F3),
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
            ),
          ),
        ),
      );
    }

    // Other page: gray circle, white bg
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: grayColor, width: 1.5),
      ),
    );
  }

  Widget _buildWelcomePage(
      Color textColor, Color secondaryTextColor, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.welcomeToTrustPremium,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Earn real benefits just by using your wallet. Get XP from activity and unlock fee discounts, partner perks, exclusive campaigns and Trust Alpha access as you level up.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 32),
          _buildOnboardingImageCard(
            'assets/images/trust_premium_onboarding_1.png',
            secondaryTextColor,
          ),
        ],
      ),
    );
  }

  static const double _imageCardHeight = 346;

  Widget _buildOnboardingImageCard(String assetPath, Color secondaryTextColor, {String placeholderLabel = 'Image'}) {
    final borderColor = secondaryTextColor.withOpacity(0.4);
    return Container(
      width: double.infinity,
      height: _imageCardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            assetPath,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _buildPlaceholderCard(placeholderLabel, secondaryTextColor),
          ),
        ),
      ),
    );
  }

  Widget _buildGoldPage(
      Color textColor, Color secondaryTextColor, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.useEarnLevelUp,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.trustPremiumOnboardingGoldDescription,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 32),
          _buildOnboardingImageCard(
            'assets/images/trust_premium_onboarding_2.png',
            secondaryTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLockTwtPage(
      Color textColor, Color secondaryTextColor, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.boostWithTwt,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.boostWithTwtDescription,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 32),
          _buildOnboardingImageCard(
            'assets/images/trust_premium_onboarding_3.png',
            secondaryTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildKeepActivePage(
      Color textColor, Color secondaryTextColor, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.keepMovingToKeepYourTier,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.trustPremiumKeepActiveDescription,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 32),
          _buildOnboardingImageCard(
            'assets/images/trust_premium_onboarding_4.png',
            secondaryTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard(String label, Color secondaryTextColor) {
    final borderColor = secondaryTextColor.withOpacity(0.4);
    return Container(
      width: double.infinity,
      height: _imageCardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: secondaryTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(Color primaryColor, Color textColor) {
    final isLastPage = _currentPage == 3;
    final l10n = AppLocalizations.of(context)!;
    final label = isLastPage
        ? 'Go to Trust Premium'
        : (_currentPage <= 1 ? l10n.getStarted : l10n.next);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (isLastPage) {
            _completeOnboardingAndGoToPremium();
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
