import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';

enum StatusTone { neutral, info, warning, success, error }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
  });

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      StatusTone.neutral => (AppColors.surfaceMuted, AppColors.textSecondary),
      StatusTone.info => (const Color(0xFFEFF6FF), AppColors.info),
      StatusTone.warning => (const Color(0xFFFFF7ED), AppColors.warning),
      StatusTone.success => (const Color(0xFFF0FDF4), AppColors.success),
      StatusTone.error => (const Color(0xFFFEF2F2), AppColors.error),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: colors.$2,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
