import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// A pill-shaped CTA with an electric-lime glow halo, mirroring the
/// "START YOUR JOURNEY" / "CREATE ACCOUNT" buttons in the references.
class GlowButton extends StatelessWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final double height;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final child = Container(
      height: height,
      width: expanded ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppColors.limeGlow,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: disabled
            ? null
            : const [
                BoxShadow(
                  color: Color(0x66C8F751),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textOnAccent, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            label.toUpperCase(),
            style: AppTextStyles.button,
          ),
        ],
      ),
    );

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(height / 2),
          child: child,
        ),
      ),
    );
  }
}

/// Outlined ghost button used as secondary action ("Already a FIFER? Log In").
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon == null
            ? const SizedBox.shrink()
            : Icon(icon, size: 18, color: AppColors.textPrimary),
        label: Text(label, style: AppTextStyles.button.copyWith(
          color: AppColors.textPrimary,
        )),
      ),
    );
  }
}
