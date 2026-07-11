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
      StatusTone.neutral => (
        AppColors.surfaceMuted,
        AppColors.textSecondary,
        AppColors.border,
      ),
      StatusTone.info => (
        AppColors.infoSoft,
        AppColors.info,
        AppColors.infoBorder,
      ),
      StatusTone.warning => (
        AppColors.warningSoft,
        AppColors.warning,
        AppColors.warningBorder,
      ),
      StatusTone.success => (
        AppColors.successSoft,
        AppColors.success,
        AppColors.successBorder,
      ),
      StatusTone.error => (
        AppColors.errorSoft,
        AppColors.error,
        AppColors.errorBorder,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.$3),
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
