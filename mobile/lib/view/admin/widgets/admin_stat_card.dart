import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

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
    final foreground = dark ? AppColors.textInverse : AppColors.textPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: dark ? null : Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: AppTextStyles.caption.copyWith(color: foreground.withValues(alpha: 0.74)))),
                Icon(icon, color: dark ? AppColors.secondary : AppColors.primary),
              ],
            ),
            const Spacer(),
            Text(value, style: AppTextStyles.display.copyWith(color: foreground, fontSize: 30)),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: AppTextStyles.caption.copyWith(color: dark ? AppColors.success : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
