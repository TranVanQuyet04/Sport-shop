import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/device_profiles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/hover_effect.dart';
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
      0 => SuperSportsTheme.colorPrimary,
      1 => SuperSportsTheme.colorAccent,
      2 => SuperSportsTheme.colorEnergy,
      _ => SuperSportsTheme.colorAction,
    };

    final enableHover = !AppDeviceProfiles.isPixel7WidthOrNarrower(context);
    final card = HoverLift(
      interactive: true,
      scale: 1.014,
      dy: -2,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfaceElevated,
                swatch.withValues(alpha: _hovered ? 0.10 : 0.045),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _hovered ? SuperSportsTheme.colorAction : AppColors.border,
              width: _hovered ? 1.2 : 0.6,
            ),
            boxShadow: _hovered ? AppElevation.role(swatch) : AppElevation.soft,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            splashColor: swatch.withValues(alpha: 0.12),
            highlightColor: swatch.withValues(alpha: 0.05),
            onTap: () => context.go('/customer/products/${product.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.lg),
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
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            clipBehavior: Clip.antiAlias,
                            child: Ink(
                              decoration: BoxDecoration(
                                color: _hovered
                                    ? SuperSportsTheme.colorAction
                                    : AppColors.surfaceElevated,
                                borderRadius: SuperSportsTheme.borderRadius,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                                boxShadow: AppElevation.glow(swatch),
                              ),
                              child: InkWell(
                                onTap: () => context.go(
                                  '/customer/products/${product.id}',
                                ),
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Icon(
                                    Icons.favorite_border,
                                    color: _hovered
                                        ? Colors.white
                                        : SuperSportsTheme.colorPrimary,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondary,
                                  swatch,
                                  AppColors.accent,
                                ],
                              ),
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
                        product.brand.isEmpty ? 'StrideX' : product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: SuperSportsTheme.colorAction,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$priceđ',
                              style: AppTextStyles.subtitle.copyWith(
                                color: SuperSportsTheme.colorPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
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
                                color: SuperSportsTheme.colorPrimary,
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

    if (!enableHover) {
      return card;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: card,
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
        color: index.isEven ? AppColors.accentSoft : AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: index.isEven
              ? AppColors.warningBorder
              : AppColors.successBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          index.isEven ? 'ƯU ĐÃI' : 'MỚI',
          style: TextStyle(
            color: index.isEven
                ? SuperSportsTheme.colorEnergy
                : SuperSportsTheme.colorAccent,
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
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _SportLinesPainter(color: color)),
        Center(
          child: Icon(
            index.isEven ? Icons.directions_run : Icons.checkroom,
            size: 76,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SportLinesPainter extends CustomPainter {
  const _SportLinesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.24 + i * 0.17);
      canvas.drawLine(Offset(-12, y), Offset(size.width + 24, y - 34), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SportLinesPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
