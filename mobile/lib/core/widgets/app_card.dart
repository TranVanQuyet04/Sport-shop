import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'hover_effect.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return HoverLift(
      enabled: onTap != null,
      interactive: onTap != null,
      scale: 1.01,
      dy: -1.5,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                colorScheme.secondary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: onTap == null
                  ? AppColors.border.withValues(alpha: 0.86)
                  : colorScheme.secondary.withValues(alpha: 0.22),
            ),
            boxShadow: AppElevation.role(colorScheme.secondary),
          ),
          child: InkWell(
            onTap: onTap,
            splashColor: colorScheme.secondary.withValues(alpha: 0.12),
            highlightColor: colorScheme.secondary.withValues(alpha: 0.05),
            child: DefaultTextStyle.merge(
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 0,
              ),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
