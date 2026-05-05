import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Stylised "FiFe" wordmark used in the app bar / branded headers.
/// Echoes the structure of the Fit & Feline logo (a charcoal "F"
/// with two lime accent blocks).
class FifeLogo extends StatelessWidget {
  const FifeLogo({
    super.key,
    this.size = 28,
    this.showWordmark = true,
    this.color,
  });

  final double size;
  final bool showWordmark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final primary = color ?? AppColors.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _FMarkPainter(stroke: primary),
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 8),
          Text(
            'FiFe',
            style: TextStyle(
              fontSize: size * 0.95,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: primary,
            ),
          ),
        ],
      ],
    );
  }
}

class _FMarkPainter extends CustomPainter {
  _FMarkPainter({required this.stroke});

  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final fPaint = Paint()
      ..color = stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Vertical stem of the F
    canvas.drawLine(
      Offset(w * 0.25, h * 0.08),
      Offset(w * 0.25, h * 0.92),
      fPaint,
    );
    // Top arm
    canvas.drawLine(
      Offset(w * 0.25, h * 0.18),
      Offset(w * 0.62, h * 0.18),
      fPaint,
    );
    // Middle arm
    canvas.drawLine(
      Offset(w * 0.25, h * 0.50),
      Offset(w * 0.55, h * 0.50),
      fPaint,
    );

    final accent = Paint()..color = AppColors.limeAccent;
    final radius = Radius.circular(w * 0.10);
    // Two lime blocks echoing the logo's accent dots.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.70, h * 0.10, w * 0.22, h * 0.18),
        radius,
      ),
      accent,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.62, h * 0.40, w * 0.22, h * 0.18),
        radius,
      ),
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant _FMarkPainter oldDelegate) =>
      oldDelegate.stroke != stroke;
}
