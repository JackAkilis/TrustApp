import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import 'google_account_selection_modal.dart';

class GoogleDriveProcessingScreen extends StatefulWidget {
  const GoogleDriveProcessingScreen({super.key});

  @override
  State<GoogleDriveProcessingScreen> createState() => _GoogleDriveProcessingScreenState();
}

class _GoogleDriveProcessingScreenState extends State<GoogleDriveProcessingScreen> {
  @override
  void initState() {
    super.initState();
    // Show processing for a moment, then show account selection
    // Use addPostFrameCallback to ensure navigation happens after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _showGoogleAccountSelection();
        }
      });
    });
  }

  void _showGoogleAccountSelection() async {
    if (!mounted) return;
    
    // Use Future.microtask to ensure dialog is shown after current frame
    await Future.microtask(() async {
      if (!mounted) return;
      
      final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const GoogleAccountSelectionModal(),
      );
      // Return result to parent (wallet details screen)
      if (mounted && result == true) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);

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
          'Processing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading icon
            Image.asset(
              'assets/animations/loading.gif',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 24),
            // Processing text
            Text(
              'Processing...',
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
