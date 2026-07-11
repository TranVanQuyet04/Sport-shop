import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/sport_performance_hero.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: Text(
                            'Bỏ qua',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textInverse.withValues(
                                alpha: 0.78,
                              ),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const _GearShowcase(),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Gear sẵn sàng cho mọi nhịp vận động',
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.textInverse,
                          fontSize: 34,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Khám phá giày, trang phục và phụ kiện thể thao chính hãng với trải nghiệm mua sắm tối ưu trên di động.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textInverse.withValues(alpha: 0.78),
                          fontSize: 16,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const Row(
                        children: [
                          _StatPill(value: '24h', label: 'giao nhanh'),
                          SizedBox(width: AppSpacing.sm),
                          _StatPill(value: '100%', label: 'chính hãng'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const Row(children: [_Dot(active: true), _Dot(), _Dot()]),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: 'Tiếp tục',
                        icon: Icons.arrow_forward_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => context.go(AppRoutes.login),
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

class _GearShowcase extends StatelessWidget {
  const _GearShowcase();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.surface.withValues(alpha: 0.14)),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: SportSpeedLines(opacity: 0.07)),
            Positioned(
              left: -32,
              top: 68,
              child: _PerformanceBand(
                width: 190,
                height: 18,
                color: AppColors.secondary.withValues(alpha: 0.22),
              ),
            ),
            Positioned(
              right: -52,
              bottom: 58,
              child: _PerformanceBand(
                width: 220,
                height: 14,
                color: AppColors.accent.withValues(alpha: 0.20),
              ),
            ),
            Center(
              child: Container(
                width: 188,
                height: 188,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sports_gymnastics_rounded,
                  color: AppColors.primary,
                  size: 112,
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: _Tag(label: 'RUN', color: AppColors.secondary),
            ),
            Positioned(
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              child: _Tag(label: 'GYM', color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceBand extends StatelessWidget {
  const _PerformanceBand({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.34,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

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
            color: AppColors.textInverse,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surface.withValues(alpha: 0.14)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textInverse.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w700,
                ),
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
        color: active
            ? AppColors.secondary
            : AppColors.surface.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
