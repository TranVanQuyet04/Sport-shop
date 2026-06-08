import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Bỏ qua'),
                ),
              ),
              const Spacer(),
              Container(
                height: 310,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(Icons.directions_run, color: AppColors.secondary, size: 150),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Trải nghiệm thể thao đỉnh cao',
                style: AppTextStyles.display.copyWith(color: AppColors.textInverse, fontSize: 34),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Khám phá giày, trang phục và phụ kiện thể thao chính hãng với trải nghiệm mua sắm tối ưu trên di động.',
                style: AppTextStyles.body.copyWith(color: AppColors.textInverse.withValues(alpha: 0.78), fontSize: 17),
              ),
              const Spacer(),
              Row(
                children: const [
                  _Dot(active: true),
                  _Dot(),
                  _Dot(),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Tiếp tục  →',
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 28 : 8,
      height: 8,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      decoration: BoxDecoration(
        color: active ? AppColors.secondary : AppColors.surface.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
