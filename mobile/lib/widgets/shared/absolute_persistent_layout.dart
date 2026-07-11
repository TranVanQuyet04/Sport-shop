import 'package:flutter/material.dart';

import '../../core/constants/device_profiles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AbsolutePersistentLayout extends StatelessWidget {
  const AbsolutePersistentLayout({
    super.key,
    required this.title,
    required this.filterAndSearchZone,
    required this.dynamicContent,
    this.subtitle,
    this.icon,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.lg,
      AppSpacing.lg,
      0,
    ),
    this.contentSpacing = AppSpacing.md,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Widget filterAndSearchZone;
  final Widget dynamicContent;
  final EdgeInsetsGeometry padding;
  final double contentSpacing;

  @override
  Widget build(BuildContext context) {
    final isPixel7 = AppDeviceProfiles.isPixel7WidthOrNarrower(context);
    final headerIconSize = isPixel7 ? 40.0 : 44.0;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.adminBackground, AppColors.background],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned(
              right: -36,
              top: 72,
              child: Icon(
                Icons.directions_run_rounded,
                size: 168,
                color: AppColors.adminPrimary.withValues(alpha: 0.035),
              ),
            ),
            Positioned(
              left: 20,
              top: 0,
              child: Container(
                width: 72,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: AppColors.adminAction.withValues(
                              alpha: 0.10,
                            ),
                          ),
                          boxShadow: AppElevation.role(AppColors.adminAction),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (icon != null) ...[
                              Container(
                                width: headerIconSize,
                                height: headerIconSize,
                                decoration: BoxDecoration(
                                  color: AppColors.electricSoft,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  border: Border.all(
                                    color: AppColors.electric.withValues(
                                      alpha: 0.14,
                                    ),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  icon,
                                  color: AppColors.info,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.display.copyWith(
                                      fontSize: isPixel7 ? 22 : 24,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.adminPrimary,
                                    ),
                                  ),
                                  if (subtitle != null) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      subtitle!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.caption.copyWith(
                                        height: 1.4,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (trailing != null) ...[
                              const SizedBox(width: AppSpacing.md),
                              trailing!,
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      filterAndSearchZone,
                      SizedBox(height: contentSpacing),
                    ],
                  ),
                ),
                Expanded(child: dynamicContent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
