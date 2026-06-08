import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

class SportshopLogo extends StatelessWidget {
  const SportshopLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const SizedBox(width: 26, height: 18),
        ),
        if (!compact) ...[
          const SizedBox(width: AppSpacing.sm),
          const Text(
            'SPORTSWEAR',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ],
    );
  }
}
