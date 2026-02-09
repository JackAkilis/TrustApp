import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Painter used to draw a single rounded corner bracket for the scan frame.
class CornerPainter extends CustomPainter {
  CornerPainter({
    required this.strokeWidth,
    required this.radius,
  });

  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Draw from middle of top edge to left, then down.
    path.moveTo(size.width, 0);
    path.lineTo(radius, 0);
    path.arcToPoint(
      Offset(0, radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

