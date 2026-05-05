import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/body_measurement.dart';

/// Three stacked silhouettes showing First / Goal / Current measurements,
/// scaled by waist:hips ratio. Lightweight illustration — gives a clear
/// at-a-glance silhouette without external assets.
class BodyAvatarPainter extends CustomPainter {
  BodyAvatarPainter({
    required this.first,
    required this.goal,
    required this.current,
  });

  final BodyMeasurement? first;
  final BodyMeasurement? goal;
  final BodyMeasurement? current;

  @override
  void paint(Canvas canvas, Size size) {
    if (first != null) {
      _drawSilhouette(canvas, size, first!, AppColors.avatarFirst, dx: -20);
    }
    if (goal != null) {
      _drawSilhouette(canvas, size, goal!, AppColors.avatarGoal, dx: 0);
    }
    if (current != null) {
      _drawSilhouette(canvas, size, current!, AppColors.avatarCurrent, dx: 20);
    }
  }

  void _drawSilhouette(
    Canvas canvas,
    Size size,
    BodyMeasurement m,
    Color color, {
    double dx = 0,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    // Normalize widths to 0..1 so relative differences are visible.
    final maxRef = 60.0;
    final bust = (m.bustInches / maxRef).clamp(0.5, 1.1);
    final waist = (m.waistBellyButtonInches / maxRef).clamp(0.4, 1.0);
    final hips = (m.hipsInches / maxRef).clamp(0.5, 1.1);

    final cx = size.width / 2 + dx;
    final top = 18.0;
    final bottom = size.height - 18;
    final h = bottom - top;

    // Head
    canvas.drawCircle(Offset(cx, top + 14), 12, paint);

    // Torso path
    final torsoTopY = top + 30;
    final waistY = top + h * 0.45;
    final hipsY = top + h * 0.62;
    final feetY = bottom;

    final scale = size.width * 0.35;

    final path = Path()
      ..moveTo(cx - bust * scale * 0.5, torsoTopY)
      ..quadraticBezierTo(cx - bust * scale * 0.55, torsoTopY + 10,
          cx - waist * scale * 0.5, waistY)
      ..quadraticBezierTo(cx - waist * scale * 0.55, waistY + 10,
          cx - hips * scale * 0.5, hipsY)
      ..lineTo(cx - hips * scale * 0.4, feetY)
      ..moveTo(cx + bust * scale * 0.5, torsoTopY)
      ..quadraticBezierTo(cx + bust * scale * 0.55, torsoTopY + 10,
          cx + waist * scale * 0.5, waistY)
      ..quadraticBezierTo(cx + waist * scale * 0.55, waistY + 10,
          cx + hips * scale * 0.5, hipsY)
      ..lineTo(cx + hips * scale * 0.4, feetY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BodyAvatarPainter oldDelegate) =>
      oldDelegate.first != first ||
      oldDelegate.goal != goal ||
      oldDelegate.current != current;
}
