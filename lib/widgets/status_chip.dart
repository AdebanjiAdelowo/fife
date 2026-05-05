import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

enum FifeStatus { done, failed, pending }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final FifeStatus status;

  @override
  Widget build(BuildContext context) {
    late Color background;
    late Color foreground;
    late String label;
    switch (status) {
      case FifeStatus.done:
        background = AppColors.limeAccent;
        foreground = AppColors.textOnAccent;
        label = 'Done';
        break;
      case FifeStatus.failed:
        background = AppColors.danger.withValues(alpha: 0.18);
        foreground = AppColors.danger;
        label = 'Failed';
        break;
      case FifeStatus.pending:
        background = AppColors.surfaceMuted;
        foreground = AppColors.textSecondary;
        label = 'Pending';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
