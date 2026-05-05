import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Decorative dark canvas with soft lime glows and twinkling particles —
/// matches the "starry / dust" backdrop of the FiFe screens.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.particleCount = 36,
    this.showSideGlow = true,
  });

  final Widget child;
  final int particleCount;
  final bool showSideGlow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.background),
        if (showSideGlow)
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppColors.ambientGlow,
              ),
            ),
          ),
        Positioned.fill(
          child: CustomPaint(
            painter: _ParticlePainter(seed: 7, count: particleCount),
          ),
        ),
        child,
      ],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.seed, required this.count});

  final int seed;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    for (int i = 0; i < count; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final radius = rng.nextDouble() * 1.6 + 0.4;
      final glow = rng.nextDouble() > 0.7;

      final paint = Paint()
        ..color = (glow
                ? AppColors.limeAccent
                : AppColors.textPrimary)
            .withValues(alpha: rng.nextDouble() * 0.55 + 0.15);

      canvas.drawCircle(Offset(dx, dy), radius, paint);

      if (glow) {
        final halo = Paint()
          ..color = AppColors.limeAccent.withValues(alpha: 0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(Offset(dx, dy), radius * 4, halo);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => false;
}
