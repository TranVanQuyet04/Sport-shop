import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../presenter/customer/product_detail_presenter.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../model/customer/product_detail_model.dart';

part 'product_detail_page_parts/product_detail_support_widgets.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedColor = 0;
  int selectedSizeIndex = 0;
  bool _isAddingToCart = false;

  late final ProductDetailPresenter _presenter = ProductDetailPresenter(
    productRepository: AppDependencies.instance.productRepository,
    productId: widget.productId,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadProduct();
  }

  @override
  void dispose() {
    _presenter
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _presenter.product;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.customerHome);
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Chi tiết sản phẩm'),
          centerTitle: true,
        ),
        body: _presenter.isLoading
            ? const AppLoadingState(title: 'Đang tải chi tiết sản phẩm')
            : AppErrorState(
                title: 'Không tải được chi tiết sản phẩm',
                message: _presenter.errorMessage ?? 'Sản phẩm không tồn tại.',
                onAction: _presenter.loadProduct,
              ),
      );
    }

    final colors = product.colors;
    final sizes = product.sizes;
    final currentColorIndex = colors.isEmpty
        ? 0
        : selectedColor.clamp(0, colors.length - 1);
    final currentSizeIndex = sizes.isEmpty
        ? 0
        : selectedSizeIndex.clamp(0, sizes.length - 1);
    final selectedVariant = _findSelectedVariant(
      product,
      selectedSize: sizes.isEmpty ? '' : sizes[currentSizeIndex],
      selectedColor: colors.isEmpty ? '' : colors[currentColorIndex],
    );
    final displayPrice = selectedVariant?.price ?? product.displayPrice;
    final price = NumberFormat.decimalPattern('vi_VN').format(displayPrice);
    final variantImages = selectedVariant?.imageUrls ?? const <String>[];
    final galleryImage = variantImages.isNotEmpty
        ? variantImages.first
        : product.imageUrls.isNotEmpty
        ? product.imageUrls.first
        : '';
    final isOutOfStock =
        selectedVariant == null || selectedVariant.stockQuantity <= 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.customerHome);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Chi tiết sản phẩm'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          if (_presenter.isLoading) const LinearProgressIndicator(minHeight: 3),
          Container(
            height: 420,
            color: const Color(0xFFECEFF1),
            child: InkWell(
              onTap: () =>
                  context.go('/customer/products/${widget.productId}/gallery'),
              child: Center(
                child: galleryImage.isEmpty
                    ? const Icon(
                        Icons.directions_run,
                        size: 160,
                        color: AppColors.secondary,
                      )
                    : Image.network(
                        galleryImage,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.directions_run,
                              size: 160,
                              color: AppColors.secondary,
                            ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        [product.brand, product.sport, product.category]
                            .where((value) => value.isNotEmpty)
                            .join(' • ')
                            .toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: AppColors.surfaceMuted,
                      child: Icon(
                        Icons.favorite_border,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  product.name.toUpperCase(),
                  style: AppTextStyles.display.copyWith(fontSize: 28),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$priceđ',
                  style: AppTextStyles.display.copyWith(fontSize: 30),
                ),
                if (selectedVariant != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (selectedVariant.sku.isNotEmpty)
                        _ProductMetaChip(label: 'SKU ${selectedVariant.sku}'),
                      _ProductMetaChip(
                        label: selectedVariant.stockQuantity > 0
                            ? 'Còn ${selectedVariant.stockQuantity}'
                            : 'Hết hàng',
                        isWarning: selectedVariant.stockQuantity <= 0,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (product.description.isNotEmpty)
                  Text(
                    product.description,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.78),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Màu sắc',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (colors.isEmpty)
                  const AppEmptyState(
                    title: 'Chưa có màu sắc',
                    message: 'Backend chưa trả về biến thể màu sắc.',
                  )
                else
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: List.generate(colors.length, (index) {
                      return _ColorOption(
                        label: colors[index],
                        color: _parseColor(colors[index]),
                        selected: currentColorIndex == index,
                        onTap: () => setState(() => selectedColor = index),
                      );
                    }),
                  ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Text(
                      'Chọn size',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Bảng size',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (sizes.isEmpty)
                  const AppEmptyState(
                    title: 'Chưa có size',
                    message: 'Backend chưa trả về biến thể size.',
                  )
                else
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: List.generate(sizes.length, (index) {
                      final isSelected = currentSizeIndex == index;
                      return ChoiceChip(
                        label: SizedBox(
                          width: 48,
                          child: Center(child: Text(sizes[index])),
                        ),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => selectedSizeIndex = index),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }),
                  ),
                const SizedBox(height: AppSpacing.xl),
                const _InfoTile(title: 'Chính sách vận chuyển'),
                const _InfoTile(title: 'Chính sách đổi trả'),
                const SizedBox(height: 96),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Thêm vào giỏ',
                  backgroundColor: SuperSportsTheme.colorPrimary,
                  isLoading: _isAddingToCart,
                  onPressed: isOutOfStock || _isAddingToCart
                      ? null
                      : () => _addToCart(selectedVariant),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Mua ngay',
                  backgroundColor: SuperSportsTheme.colorPrimary,
                  isLoading: _isAddingToCart,
                  onPressed: isOutOfStock || _isAddingToCart
                      ? null
                      : () => _addToCart(selectedVariant, goToCheckout: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ProductVariantModel? _findSelectedVariant(
    ProductDetailModel product, {
    required String selectedSize,
    required String selectedColor,
  }) {
    if (product.variants.isEmpty) {
      return null;
    }

    for (final variant in product.variants) {
      if (variant.size == selectedSize && variant.color == selectedColor) {
        return variant;
      }
    }
    for (final variant in product.variants) {
      if (variant.size == selectedSize) {
        return variant;
      }
    }
    return product.variants.first;
  }

  Future<void> _addToCart(
    ProductVariantModel? variant, {
    bool goToCheckout = false,
  }) async {
    if (variant == null || variant.id.isEmpty || variant.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biến thể sản phẩm hiện không khả dụng.')),
      );
      return;
    }

    setState(() => _isAddingToCart = true);
    try {
      await AppDependencies.instance.cartRepository.addToCart(
        variantId: variant.id,
        quantity: 1,
      );
      if (!mounted) {
        return;
      }
      context.go(goToCheckout ? AppRoutes.checkout : AppRoutes.cart);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  Color _parseColor(String value) {
    final normalized = value.toLowerCase();
    if (normalized.contains('đỏ') || normalized.contains('red')) {
      return AppColors.error;
    }
    if (normalized.contains('trắng') || normalized.contains('white')) {
      return Colors.white;
    }
    if (normalized.contains('xanh') || normalized.contains('blue')) {
      return AppColors.info;
    }
    if (normalized.contains('đen') || normalized.contains('black')) {
      return Colors.black;
    }
    if (normalized.contains('vàng') || normalized.contains('yellow')) {
      return AppColors.warning;
    }
    return AppColors.primary;
  }
}
