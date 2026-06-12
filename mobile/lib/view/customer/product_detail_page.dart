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
    final product = _controller.product ?? _fallbackProduct(widget.productId);
    final colors = product.colors.isEmpty
        ? ['Đen', 'Đỏ', 'Trắng']
        : product.colors;
    final sizes = product.sizes.isEmpty
        ? ['38', '39', '40', '41', '42', '43', '44']
        : product.sizes;
    final currentColorIndex = selectedColor.clamp(0, colors.length - 1);
    final currentSizeIndex = selectedSizeIndex.clamp(0, sizes.length - 1);
    final selectedVariant = _findSelectedVariant(
      product,
      selectedSize: sizes[currentSizeIndex],
      selectedColor: colors[currentColorIndex],
    );
    final displayPrice = product.displayPrice == 0
        ? 3500000
        : product.displayPrice;
    final price = NumberFormat.decimalPattern('vi_VN').format(displayPrice);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Center(child: Text('CHI TIẾT')),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.share_outlined)),
        ],
      ),
      body: ListView(
        children: [
          if (_controller.isLoading)
            const LinearProgressIndicator(minHeight: 3),
          if (_controller.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppErrorState(
                title: 'Không tải được chi tiết sản phẩm',
                message:
                    'Đang hiển thị dữ liệu mẫu. Hãy thử lại khi backend sẵn sàng.',
                onAction: _controller.loadProduct,
              ),
            ),
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
                Text(
                  product.description.isEmpty
                      ? 'Sản phẩm thể thao hiệu năng cao, phù hợp cho tập luyện và sử dụng hằng ngày.'
                      : product.description,
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
                const _InfoTile(title: 'Đánh giá (128)', trailing: '☆ 4.8'),
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
                  onPressed: () => _addToCart(selectedVariant),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'MUA NGAY',
                  variant: AppButtonVariant.secondary,
                  isLoading: _isAddingToCart,
                  onPressed: () =>
                      _addToCart(selectedVariant, goToCheckout: true),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đang chuyển tiếp ở chế độ demo vì backend chưa sẵn sàng.',
          ),
        ),
      );
      context.go(goToCheckout ? AppRoutes.checkout : AppRoutes.cart);
      return;
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  ProductDetailModel _fallbackProduct(String productId) {
    return ProductDetailModel(
      id: productId,
      name: 'Nike Air Max 270',
      description:
          'Nike Air Max 270 mang đến phong cách hiện đại kết hợp với đệm Air lớn, tạo cảm giác êm và nổi bật.',
      category: 'Giày chạy bộ',
      brand: 'Nike',
      sport: 'Running',
      variants: const [
        ProductVariantModel(
          id: '1',
          sku: 'NIKE-270-BLK-40',
          size: '40',
          color: 'Đen',
          price: 3500000,
          stockQuantity: 8,
          imageUrls: [],
        ),
        ProductVariantModel(
          id: '2',
          sku: 'NIKE-270-RED-41',
          size: '41',
          color: 'Đỏ',
          price: 3500000,
          stockQuantity: 6,
          imageUrls: [],
        ),
        ProductVariantModel(
          id: '3',
          sku: 'NIKE-270-WHT-42',
          size: '42',
          color: 'Trắng',
          price: 3500000,
          stockQuantity: 4,
          imageUrls: [],
        ),
      ],
    );
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
  const _InfoTile({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
      ),
      trailing: Text(
        trailing ?? '›',
        style: AppTextStyles.body.copyWith(color: AppColors.secondary),
      ),
    );
  }
}
