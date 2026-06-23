import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'hover_effect.dart';

enum AppButtonVariant { primary, secondary, danger, outline }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final isOutline = variant == AppButtonVariant.outline;
    final resolvedBackgroundColor =
        backgroundColor ??
        switch (variant) {
          AppButtonVariant.primary => AppColors.primary,
          AppButtonVariant.secondary => AppColors.secondary,
          AppButtonVariant.danger => AppColors.error,
          AppButtonVariant.outline => Colors.transparent,
        };
    final resolvedForegroundColor =
        foregroundColor ??
        (isOutline ? AppColors.textPrimary : AppColors.textInverse);

    return HoverLift(
      enabled: !isLoading && onPressed != null,
      scale: 1.01,
      dy: -1,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: resolvedBackgroundColor,
            foregroundColor: resolvedForegroundColor,
            disabledBackgroundColor: AppColors.surfaceMuted,
            disabledForegroundColor: AppColors.textSecondary,
            elevation: isOutline ? 0 : 2,
            shadowColor: resolvedBackgroundColor.withValues(alpha: 0.22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: isOutline
                  ? const BorderSide(color: AppColors.borderStrong)
                  : BorderSide.none,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.button.copyWith(
                        color: resolvedForegroundColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
