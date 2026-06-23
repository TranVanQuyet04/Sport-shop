import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../model/customer/product_summary_model.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, required this.index});

  final ProductSummaryModel product;
  final int index;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final price = NumberFormat.decimalPattern('vi_VN').format(product.price);
    final swatch = switch (widget.index % 4) {
      0 => AppColors.secondary,
      1 => const Color(0xFF0F172A),
      2 => const Color(0xFF2563EB),
      _ => const Color(0xFF16A34A),
    };

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.025 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: () => context.go('/customer/products/${product.id}'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: _hovered ? AppColors.secondary : AppColors.border,
                width: _hovered ? 1.2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: _hovered ? 0.13 : 0.06,
                  ),
                  blurRadius: _hovered ? 22 : 16,
                  offset: Offset(0, _hovered ? 12 : 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: swatch.withValues(alpha: 0.12)),
                        if (product.imageUrl.isNotEmpty)
                          Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.prefer,
                            errorBuilder: (_, _, _) => _ProductFallbackImage(
                              index: widget.index,
                              color: swatch,
                            ),
                          )
                        else
                          _ProductFallbackImage(
                            index: widget.index,
                            color: swatch,
                          ),
                        Positioned(
                          top: AppSpacing.sm,
                          left: AppSpacing.sm,
                          child: _SaleBadge(index: widget.index),
                        ),
                        Positioned(
                          top: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _hovered
                                  ? AppColors.secondary
                                  : AppColors.surfaceElevated,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.10,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              color: _hovered
                                  ? Colors.white
                                  : AppColors.primary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brand.isEmpty ? 'SPORTSHOP' : product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$priceđ',
                              style: AppTextStyles.subtitle.copyWith(
                                color: AppColors.primary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (product.hasRating) ...[
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.warning,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaleBadge extends StatelessWidget {
  const _SaleBadge({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: index.isEven ? AppColors.secondary : AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          index.isEven ? 'Ưu đãi' : 'Mới',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ProductFallbackImage extends StatelessWidget {
  const _ProductFallbackImage({required this.index, required this.color});

  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        index.isEven ? Icons.directions_run : Icons.checkroom,
        size: 76,
        color: color,
      ),
    );
  }
}
