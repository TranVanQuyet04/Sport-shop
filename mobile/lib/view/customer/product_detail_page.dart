import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../controller/customer/product_detail_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../model/customer/product_detail_model.dart';

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

  late final ProductDetailController _controller = ProductDetailController(
    productRepository: AppDependencies.instance.productRepository,
    productId: widget.productId,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadProduct();
  }

  @override
  void dispose() {
    _controller
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
    final product = _controller.product;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: context.pop,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Center(child: Text('CHI TIẾT')),
        ),
        body: _controller.isLoading
            ? const AppLoadingState(title: 'Đang tải chi tiết sản phẩm')
            : AppErrorState(
                title: 'Không tải được chi tiết sản phẩm',
                message: _controller.errorMessage ?? 'Sản phẩm không tồn tại.',
                onAction: _controller.loadProduct,
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
    final selectedVariant = product.variants.isEmpty
        ? null
        : _findSelectedVariant(
            product,
            selectedSize: sizes.isEmpty ? '' : sizes[currentSizeIndex],
            selectedColor: colors.isEmpty ? '' : colors[currentColorIndex],
          );
    final displayPrice = product.displayPrice;
    final price = NumberFormat.decimalPattern('vi_VN').format(displayPrice);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Center(child: Text('CHI TIẾT')),
      ),
      body: ListView(
        children: [
          if (_controller.isLoading)
            const LinearProgressIndicator(minHeight: 3),
          Container(
            height: 500,
            color: const Color(0xFFECEFF1),
            child: InkWell(
              onTap: () =>
                  context.go('/customer/products/${widget.productId}/gallery'),
              child: Center(
                child: product.imageUrls.isEmpty
                    ? const Icon(
                        Icons.directions_run,
                        size: 180,
                        color: AppColors.secondary,
                      )
                    : Image.network(
                        product.imageUrls.first,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.directions_run,
                              size: 180,
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
                  'MÀU SẮC',
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
                  Row(
                    children: List.generate(colors.length, (index) {
                      return _ColorDot(
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
                      'CHỌN SIZE (VN)',
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
                      return ChoiceChip(
                        label: SizedBox(
                          width: 48,
                          child: Center(child: Text(sizes[index])),
                        ),
                        selected: currentSizeIndex == index,
                        onSelected: (_) =>
                            setState(() => selectedSizeIndex = index),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: currentSizeIndex == index
                              ? Colors.white
                              : AppColors.primary,
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
                  label: 'THÊM VÀO GIỎ',
                  variant: AppButtonVariant.outline,
                  isLoading: _isAddingToCart,
                  onPressed: selectedVariant == null
                      ? null
                      : () => _addToCart(selectedVariant),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'MUA NGAY',
                  variant: AppButtonVariant.secondary,
                  isLoading: _isAddingToCart,
                  onPressed: selectedVariant == null
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

  ProductVariantModel _findSelectedVariant(
    ProductDetailModel product, {
    required String selectedSize,
    required String selectedColor,
  }) {
    if (product.variants.isEmpty) {
      return const ProductVariantModel(
        id: '',
        sku: '',
        size: '',
        color: '',
        price: 0,
        stockQuantity: 0,
        imageUrls: [],
      );
    }

    return product.variants.firstWhere(
      (variant) =>
          variant.size == selectedSize && variant.color == selectedColor,
      orElse: () => product.variants.firstWhere(
        (variant) => variant.size == selectedSize,
        orElse: () => product.variants.first,
      ),
    );
  }

  Future<void> _addToCart(
    ProductVariantModel variant, {
    bool goToCheckout = false,
  }) async {
    if (variant.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sản phẩm chưa có biến thể hợp lệ.')),
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
      return AppColors.secondary;
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
    return AppColors.primary;
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: color == Colors.white
                ? Border.all(color: AppColors.border)
                : null,
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
      ),
      trailing: Text(
        '›',
        style: AppTextStyles.body.copyWith(color: AppColors.secondary),
      ),
    );
  }
}
