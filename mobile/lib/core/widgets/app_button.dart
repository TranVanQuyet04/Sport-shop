import 'package:flutter/cupertino.dart';
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
          AppButtonVariant.primary => SuperSportsTheme.colorPrimary,
          AppButtonVariant.secondary => SuperSportsTheme.colorAccent,
          AppButtonVariant.danger => AppColors.error,
          AppButtonVariant.outline => Colors.transparent,
        };
    final resolvedForegroundColor =
        foregroundColor ??
        (isOutline ? AppColors.textPrimary : AppColors.textInverse);
    final canPress = !isLoading && onPressed != null;
    final gradient = isOutline || !canPress
        ? null
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: variant == AppButtonVariant.secondary
                ? const [AppColors.secondary, AppColors.electric]
                : [resolvedBackgroundColor, AppColors.electric],
          );

    return Semantics(
      button: true,
      enabled: canPress,
      label: label,
      child: HoverLift(
        enabled: canPress,
        scale: 1.01,
        dy: -1,
        borderRadius: SuperSportsTheme.borderRadius,
        interactive: true,
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: gradient,
              color: onPressed == null || isLoading
                  ? AppColors.surfaceMuted
                  : gradient == null
                  ? resolvedBackgroundColor
                  : null,
              borderRadius: SuperSportsTheme.borderRadius,
              border: isOutline
                  ? Border.all(color: AppColors.borderStrong)
                  : Border.all(color: Colors.transparent),
              boxShadow: isOutline || onPressed == null || isLoading
                  ? null
                  : AppElevation.glow(resolvedBackgroundColor),
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              borderRadius: SuperSportsTheme.borderRadius,
              minimumSize: const Size(52, 52),
              pressedOpacity: 0.72,
              onPressed: isLoading ? null : onPressed,
              child: isLoading
                  ? CupertinoActivityIndicator(
                      color: isOutline
                          ? AppColors.textSecondary
                          : resolvedForegroundColor,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 18, color: resolvedForegroundColor),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.button.copyWith(
                              color: onPressed == null
                                  ? AppColors.textSecondary
                                  : resolvedForegroundColor,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
