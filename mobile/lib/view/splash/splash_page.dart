import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'SPORTSHOP',
                style: AppTextStyles.display.copyWith(color: AppColors.textInverse),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Trang phục, giày thể thao và phụ kiện cho mọi chuyển động.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textInverse.withValues(alpha: 0.78),
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Bắt đầu',
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go(AppRoutes.onboarding),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
