import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Standard rounded card used across all surfaces.
class FifeCard extends StatelessWidget {
  const FifeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
    this.borderColor,
    this.glow = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? borderColor;
  final bool glow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: gradient ?? AppColors.surfaceSheen,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: borderColor ?? AppColors.border),
      boxShadow: glow
          ? const [
              BoxShadow(
                color: Color(0x33C8F751),
                blurRadius: 26,
                spreadRadius: -8,
                offset: Offset(0, 8),
              ),
            ]
          : null,
    );

    final content = Padding(padding: padding, child: child);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: decoration,
          child: content,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.limeAccent, size: 18),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyles.headingMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}
