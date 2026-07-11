import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SportPerformanceHero extends StatelessWidget {
  const SportPerformanceHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.directions_run_rounded,
    this.badges = const [],
    this.trailing,
    this.minHeight = 188,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<SportHeroBadge> badges;
  final Widget? trailing;
  final double minHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: title,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppElevation.glow(AppColors.primary),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: SportSpeedLines()),
            Positioned(
              right: -18,
              top: -20,
              child: Icon(
                icon,
                size: 132,
                color: AppColors.textInverse.withValues(alpha: 0.07),
              ),
            ),
            Positioned(
              right: -28,
              bottom: 24,
              child: Transform.rotate(
                angle: -0.32,
                child: Container(
                  width: 132,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -10,
              bottom: 2,
              child: Transform.rotate(
                angle: -0.32,
                child: Container(
                  width: 82,
                  height: 8,
                  color: AppColors.accent.withValues(alpha: 0.72),
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.textInverse.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: AppColors.textInverse.withValues(
                              alpha: 0.14,
                            ),
                          ),
                        ),
                        child: Icon(icon, color: AppColors.secondary),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (badges.isNotEmpty)
                        Expanded(
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: badges
                                .map((badge) => _SportBadgeView(badge: badge))
                                .toList(growable: false),
                          ),
                        )
                      else
                        const Spacer(),
                      ?trailing,
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      title,
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.textInverse,
                        fontSize: 28,
                        height: 1.08,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Text(
                      subtitle,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textInverse.withValues(alpha: 0.76),
                        height: 1.48,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5,
                color: AppColors.secondary,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(height: 56, color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SportHeroBadge {
  const SportHeroBadge({
    required this.label,
    this.icon,
    this.color = AppColors.secondary,
  });

  final String label;
  final IconData? icon;
  final Color color;
}

class SportIconPanel extends StatelessWidget {
  const SportIconPanel({
    super.key,
    required this.icon,
    this.tone = AppColors.secondary,
    this.width = 150,
    this.height = 112,
  });

  final IconData icon;
  final Color tone;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppElevation.raised,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: SportSpeedLines(opacity: 0.07)),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 5,
              color: AppColors.secondary,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(height: 36, color: AppColors.accent),
              ),
            ),
          ),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(icon, size: 32, color: tone),
          ),
        ],
      ),
    );
  }
}

class _SportBadgeView extends StatelessWidget {
  const _SportBadgeView({required this.badge});

  final SportHeroBadge badge;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: badge.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: badge.color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge.icon != null) ...[
              Icon(badge.icon, size: 14, color: badge.color),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              badge.label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textInverse,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SportSpeedLines extends StatelessWidget {
  const SportSpeedLines({super.key, this.opacity = 0.09});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SportSpeedLinesPainter(opacity: opacity),
      child: const SizedBox.expand(),
    );
  }
}

class _SportSpeedLinesPainter extends CustomPainter {
  const _SportSpeedLinesPainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = AppColors.textInverse.withValues(alpha: opacity)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 7; i++) {
      final start = Offset(-40 + i * 58, size.height * 0.18 + i * 20);
      final end = Offset(size.width * 0.58 + i * 32, -24 + i * 25);
      canvas.drawLine(start, end, basePaint);
    }

    final greenPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.70)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final orangePaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.74)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.10, size.height * 0.78),
      Offset(size.width * 0.44, size.height * 0.64),
      greenPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.64, size.height * 0.30),
      Offset(size.width * 0.92, size.height * 0.20),
      orangePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SportSpeedLinesPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
