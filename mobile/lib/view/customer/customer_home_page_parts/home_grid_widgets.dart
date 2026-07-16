part of '../customer_home_page.dart';

class _BrandGrid extends StatelessWidget {
  const _BrandGrid({required this.brands, required this.onTap});

  final List<BrandModel> brands;
  final ValueChanged<BrandModel> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: brands.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, index) {
        final brand = brands[index];
        return HoverLift(
          interactive: true,
          scale: 1.018,
          dy: -3,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Material(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onTap(brand),
              child: Stack(
              fit: StackFit.expand,
              children: [
                if (brand.banner.isNotEmpty || brand.logo.isNotEmpty)
                  Image.network(
                    brand.banner.isNotEmpty ? brand.banner : brand.logo,
                    fit: BoxFit.cover,
                    webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        'GIẢM 50%',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Mua ngay',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.controller});

  final CustomerHomePresenter controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.recommendedProducts.isEmpty) {
      return const AppLoadingState(title: 'Đang tải sản phẩm');
    }
    if (controller.errorMessage != null &&
        controller.recommendedProducts.isEmpty) {
      return AppErrorState(
        title: 'Không tải được sản phẩm',
        message: controller.errorMessage!,
        onAction: controller.loadHome,
      );
    }
    if (controller.recommendedProducts.isEmpty) {
      return const AppEmptyState(
        title: 'Chưa có sản phẩm',
        message: 'Backend chưa trả về sản phẩm hiển thị.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.xl,
        childAspectRatio: 0.68,
      ),
      itemCount: controller.recommendedProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: controller.recommendedProducts[index],
          index: index,
        );
      },
    );
  }
}
