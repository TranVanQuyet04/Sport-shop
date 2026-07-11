import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

class StrideXLogo extends StatelessWidget {
  const StrideXLogo({super.key, this.compact = false, this.inverse = false});

  final bool compact;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final markForeground = inverse ? AppColors.primary : AppColors.textInverse;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 32 : 36,
          height: compact ? 28 : 30,
          decoration: BoxDecoration(
            color: inverse ? AppColors.surface : AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: inverse
                  ? AppColors.textInverse.withValues(alpha: 0.20)
                  : AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 5,
                top: 8,
                child: _SpeedSlash(color: AppColors.secondary),
              ),
              Positioned(
                right: 5,
                bottom: 8,
                child: _SpeedSlash(color: AppColors.accent, width: 12),
              ),
              Text(
                'S',
                style: TextStyle(
                  color: markForeground,
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            'StrideX',
            style: TextStyle(
              color: inverse ? Colors.white : AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class _SpeedSlash extends StatelessWidget {
  const _SpeedSlash({required this.color, this.width = 15});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.42,
      child: Container(
        width: width,
        height: 3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
