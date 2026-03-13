import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '_corner_painter.dart';

enum ScanMode {
  camera,
  gallery,
  manual,
}

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  final TextEditingController _manualController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  ScanMode _mode = ScanMode.camera;
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    setState(() {
      _hasScanned = true;
    });

    // Close scanner and return to previous screen (home).
    Navigator.of(context).pop(value);
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (file == null) return;

      final String path = file.path;
      if (path.isEmpty) return;

      final result = await _controller.analyzeImage(path);
      // If the controller could not decode anything, result will be null.
      if (result != null && result.barcodes.isNotEmpty) {
        _onDetect(result);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No QR code found in image'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to scan image'),
        ),
      );
    }
  }

  void _submitManual() {
    final text = _manualController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter QR data'),
        ),
      );
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeHelper.isDarkMode(context);
    // Use a teal-style background similar to the reference design in light mode,
    // and dark background in dark mode.
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : const Color(0xFF3D6E6E);
    final textColor =
        isDarkMode ? AppColors.darkText : AppColors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Scan QR code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.image_outlined,
              size: 22,
            ),
            color: textColor,
            onPressed: _pickFromGallery,
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 22,
            ),
            color: textColor,
            onPressed: _openManualInputDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Center scan overlay + frame
          _buildScanFrame(
            overlayColor: backgroundColor.withOpacity(isDarkMode ? 0.8 : 0.7),
          ),
          // Torch toggle in bottom-right corner
          Positioned(
            right: 16,
            bottom: 32,
            child: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                final isOn = state.torchState == TorchState.on;
                return IconButton(
                  onPressed: () => _controller.toggleTorch(),
                  icon: Icon(
                    isOn ? Icons.flash_on : Icons.flash_off,
                    size: 24,
                    color: textColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the dimmed overlay with a transparent cutout, plus corner brackets.
  Widget _buildScanFrame({required Color overlayColor}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide =
            constraints.biggest.shortestSide == double.infinity
                ? 260.0
                : constraints.biggest.shortestSide * 0.6;
        final size = shortestSide.clamp(220.0, 320.0);
        final rect = Rect.fromCenter(
          center: Offset(
            constraints.biggest.width / 2,
            constraints.biggest.height / 2,
          ),
          width: size,
          height: size,
        );

        return Stack(
          children: [
            // Dim the whole screen except the cutout (camera remains visible)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ScanCutoutPainter(
                    overlayColor: overlayColor,
                    cutoutRect: rect,
                    borderRadius: 12,
                  ),
                ),
              ),
            ),
            // Corner brackets on top of the cutout
            Center(
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  children: [
                    _buildCorner(alignment: Alignment.topLeft),
                    _buildCorner(alignment: Alignment.topRight),
                    _buildCorner(alignment: Alignment.bottomLeft),
                    _buildCorner(alignment: Alignment.bottomRight),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner({required Alignment alignment}) {
    const double cornerLength = 40;
    const double strokeWidth = 6;
    const double radius = 12;

    double angle;
    if (alignment == Alignment.topLeft) {
      angle = 0;
    } else if (alignment == Alignment.topRight) {
      angle = 0.5 * 3.1415926535897932; // 90 degrees
    } else if (alignment == Alignment.bottomRight) {
      angle = 3.1415926535897932; // 180 degrees
    } else {
      // bottomLeft
      angle = -0.5 * 3.1415926535897932; // -90 degrees
    }

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: cornerLength,
        height: cornerLength,
        child: Transform.rotate(
          angle: angle,
          child: CustomPaint(
            painter: CornerPainter(
              strokeWidth: strokeWidth,
              radius: radius,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openManualInputDialog() async {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final borderColor = ThemeHelper.getBorderColor(context);
    final isDarkMode = ThemeHelper.isDarkMode(context);

    _manualController.clear();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Enter QR code data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: _manualController,
              maxLines: 5,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Paste or type QR code content here...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
                filled: true,
                fillColor: isDarkMode
                    ? AppColors.darkBackground
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: primaryColor,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final text = _manualController.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter QR data'),
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(); // close dialog
                Navigator.of(context).pop(text); // return to home with value
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                elevation: 0,
              ),
              child: Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.darkBackground
                      : AppColors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeSelector(
    Color textColor,
    Color secondaryTextColor,
    Color grayColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    Color _chipColor(bool selected) =>
        selected ? AppColors.primaryBlue : grayColor;
    Color _chipTextColor(bool selected) =>
        selected ? (isDarkMode ? AppColors.darkBackground : AppColors.white) : textColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildModeChip(
          label: 'Camera',
          selected: _mode == ScanMode.camera,
          backgroundColor: _chipColor(_mode == ScanMode.camera),
          textColor: _chipTextColor(_mode == ScanMode.camera),
          onTap: () {
            setState(() {
              _mode = ScanMode.camera;
              _hasScanned = false;
            });
          },
        ),
        _buildModeChip(
          label: 'Gallery',
          selected: _mode == ScanMode.gallery,
          backgroundColor: _chipColor(_mode == ScanMode.gallery),
          textColor: _chipTextColor(_mode == ScanMode.gallery),
          onTap: () {
            setState(() {
              _mode = ScanMode.gallery;
              _hasScanned = false;
            });
          },
        ),
        _buildModeChip(
          label: 'Enter code',
          selected: _mode == ScanMode.manual,
          backgroundColor: _chipColor(_mode == ScanMode.manual),
          textColor: _chipTextColor(_mode == ScanMode.manual),
          onTap: () {
            setState(() {
              _mode = ScanMode.manual;
              _hasScanned = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildModeChip({
    required String label,
    required bool selected,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.borderGray,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeContent(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
    Color grayColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    switch (_mode) {
      case ScanMode.camera:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Point your camera at a QR code to scan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
              ),
            ),
          ],
        );
      case ScanMode.gallery:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 48,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan from screenshot or gallery image.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _pickFromGallery,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Choose image',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? AppColors.darkBackground
                                : AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case ScanMode.manual:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter QR code data',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _manualController,
                maxLines: null,
                expands: true,
                textInputAction: TextInputAction.newline,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Paste or type QR code content here...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? AppColors.darkBackground
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitManual,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppColors.darkBackground
                        : AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}

class _ScanCutoutPainter extends CustomPainter {
  final Color overlayColor;
  final Rect cutoutRect;
  final double borderRadius;

  _ScanCutoutPainter({
    required this.overlayColor,
    required this.cutoutRect,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;
    final paint = Paint()..color = overlayColor;

    // Use a saveLayer so BlendMode.clear actually punches a hole through.
    canvas.saveLayer(fullRect, Paint());
    canvas.drawRect(fullRect, paint);

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final rrect = RRect.fromRectAndRadius(
      cutoutRect,
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, clearPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScanCutoutPainter oldDelegate) {
    return oldDelegate.overlayColor != overlayColor ||
        oldDelegate.cutoutRect != cutoutRect ||
        oldDelegate.borderRadius != borderRadius;
  }
}

