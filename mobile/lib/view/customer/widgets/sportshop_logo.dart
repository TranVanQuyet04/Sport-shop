import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

class SportshopLogo extends StatelessWidget {
  const SportshopLogo({super.key, this.compact = false, this.inverse = false});

  final bool compact;
  final bool inverse;

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
          Text(
            'SPORTSHOP',
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
