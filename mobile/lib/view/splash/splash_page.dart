import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/sport_performance_hero.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _BrandMark(),
                      const SizedBox(height: AppSpacing.xl),
                      const _PerformanceHero(),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'StrideX',
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.textInverse,
                          fontSize: 36,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Trang phục, giày thể thao và phụ kiện cho mọi chuyển động.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textInverse.withValues(alpha: 0.78),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _ValueBadge(
                            icon: Icons.verified_outlined,
                            label: 'Chính hãng',
                          ),
                          _ValueBadge(
                            icon: Icons.local_shipping_outlined,
                            label: 'Giao nhanh',
                          ),
                          _ValueBadge(
                            icon: Icons.bolt_outlined,
                            label: 'Sẵn sàng vận động',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
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
          },
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Center(
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
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'Performance gear',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textInverse.withValues(alpha: 0.72),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _PerformanceHero extends StatelessWidget {
  const _PerformanceHero();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.06,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.surface.withValues(alpha: 0.14)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              const Positioned.fill(child: SportSpeedLines()),
              Positioned(
                left: AppSpacing.lg,
                top: AppSpacing.lg,
                child: _HeroChip(
                  label: 'RUN',
                  color: AppColors.secondary,
                  foreground: AppColors.textInverse,
                ),
              ),
              Positioned(
                right: AppSpacing.lg,
                top: 72,
                child: _HeroChip(
                  label: 'TRAIN',
                  color: AppColors.accent,
                  foreground: AppColors.textInverse,
                ),
              ),
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: 78,
                bottom: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 42,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.directions_run_rounded,
                        size: 122,
                        color: AppColors.primary,
                      ),
                      Positioned(
                        right: AppSpacing.lg,
                        bottom: AppSpacing.lg,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.secondarySoft,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 6,
                            ),
                            child: Text(
                              'NEW DROP',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fit cho chạy bộ, gym và lifestyle.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textInverse.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
    required this.color,
    required this.foreground,
  });

  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: foreground,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ValueBadge extends StatelessWidget {
  const _ValueBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.surface.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.secondary),
            const SizedBox(width: AppSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 172),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textInverse.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
