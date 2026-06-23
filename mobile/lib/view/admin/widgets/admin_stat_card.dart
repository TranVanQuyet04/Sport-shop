import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/hover_effect.dart';
import 'admin_design_system.dart';

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.dark = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? AppColors.textInverse : AdminColors.textPrimary;
    final iconBackground = dark
        ? AdminColors.accent.withValues(alpha: 0.18)
        : AdminColors.primarySoft;

    return HoverLift(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? AdminColors.textPrimary : AdminColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: dark
              ? [
                  BoxShadow(
                    color: AdminColors.primary.withValues(alpha: 0.2),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ]
              : AdminDesign.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.caption.copyWith(
                        color: foreground.withValues(alpha: 0.74),
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Icon(icon, color: AdminColors.primary, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                value,
                style: AppTextStyles.display.copyWith(
                  color: foreground,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: dark ? AppColors.success : AdminColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
