import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../model/customer/product_summary_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.index,
  });

  final ProductSummaryModel product;
  final int index;

  @override
  Widget build(BuildContext context) {
    final price = NumberFormat.decimalPattern('vi_VN').format(product.price);
    final swatch = switch (index % 4) {
      0 => AppColors.secondary,
      1 => AppColors.primary,
      2 => const Color(0xFFE7E4FF),
      _ => const Color(0xFFECEFF1),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () => context.go('/customer/products/${product.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: swatch.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      index.isEven ? Icons.directions_run : Icons.checkroom,
                      size: 76,
                      color: swatch,
                    ),
                  ),
                  if (product.isNew)
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'MỚI',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.surface,
                      child: Icon(Icons.favorite_border, color: AppColors.primary, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(fontSize: 15),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$priceđ',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 16),
                ),
              ),
              const Icon(Icons.star_border, color: AppColors.secondary, size: 16),
              const SizedBox(width: 2),
              Text(product.rating.toStringAsFixed(1), style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
