import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../controller/customer/cart_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../model/customer/cart_model.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/sportshop_logo.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CartController _controller = CartController(
    cartRepository: AppDependencies.instance.cartRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadCart();
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
    final cart = _controller.cart;
    final totalPrice = cart.totalPrice == 0
        ? cart.computedTotalPrice
        : cart.totalPrice;
    final total = NumberFormat.decimalPattern('vi_VN').format(totalPrice);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        title: const SportshopLogo(),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _controller.isLoading ? null : _controller.loadCart,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadCart,
        child: _buildBody(cart),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Tổng tiền tạm tính',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$totalđ',
                        style: AppTextStyles.display.copyWith(fontSize: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Thanh toán ngay',
                    icon: Icons.arrow_forward,
                    variant: AppButtonVariant.secondary,
                    isLoading: _controller.isUpdating,
                    onPressed: cart.isEmpty || _controller.isLoading
                        ? null
                        : () => context.go(AppRoutes.checkout),
                  ),
                ],
              ),
            ),
          ),
          const CustomerBottomNav(selectedIndex: 2),
        ],
      ),
    );
  }

  Widget _buildBody(CartModel cart) {
    if (_controller.isLoading && cart.isEmpty) {
      return const AppLoadingState(
        title: 'Đang tải giỏ hàng',
        message: 'Sportshop đang lấy các sản phẩm bạn đã chọn.',
      );
    }

    if (_controller.errorMessage != null && cart.isEmpty) {
      return AppErrorState(
        title: 'Không tải được giỏ hàng',
        message: _controller.errorMessage!,
        onAction: _controller.loadCart,
      );
    }

    if (cart.isEmpty) {
      return AppEmptyState(
        title: 'Giỏ hàng đang trống',
        message: 'Hãy chọn sản phẩm yêu thích để bắt đầu đơn hàng đầu tiên.',
        actionLabel: 'Tiếp tục mua sắm',
        onAction: () => context.go(AppRoutes.customerHome),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount:
          cart.items.length + 1 + (_controller.errorMessage == null ? 0 : 1),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _CartHeader(
            totalItems: cart.totalItems == 0
                ? cart.items.length
                : cart.totalItems,
          );
        }
        if (index == 1 && _controller.errorMessage != null) {
          return _InlineCartError(
            message: _controller.errorMessage!,
            onRetry: _controller.loadCart,
          );
        }

        final itemIndex = _controller.errorMessage == null
            ? index - 1
            : index - 2;
        final item = cart.items[itemIndex];
        return _CartItem(
          item: item,
          isBusy: _controller.isUpdating,
          onDecrease: () => _controller.decrease(item),
          onIncrease: () => _controller.increase(item),
          onRemove: () => _controller.remove(item.id),
        );
      },
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.totalItems});

  final int totalItems;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Giỏ hàng', style: AppTextStyles.display.copyWith(fontSize: 34)),
        const Spacer(),
        Text(
          '$totalItems sản phẩm',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _InlineCartError extends StatelessWidget {
  const _InlineCartError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.item,
    required this.isBusy,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final CartItemModel item;
  final bool isBusy;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(item.subTotal);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            _ProductImage(imageUrl: item.imageUrl),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: AppTextStyles.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Xóa sản phẩm',
                        onPressed: isBusy ? null : onRemove,
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.variantLabel,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (item.maxStock > 0) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Còn ${item.maxStock} sản phẩm',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$priceTextđ',
                          style: AppTextStyles.subtitle,
                        ),
                      ),
                      _QuantityStepper(
                        quantity: item.quantity,
                        isBusy: isBusy,
                        onDecrease: onDecrease,
                        onIncrease: onIncrease,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? const Icon(
              Icons.directions_run,
              color: AppColors.secondary,
              size: 48,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.directions_run,
                  color: AppColors.secondary,
                  size: 48,
                );
              },
            ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.isBusy,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final bool isBusy;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Giảm số lượng',
            onPressed: isBusy ? null : onDecrease,
            icon: const Icon(Icons.remove, size: 18),
          ),
          SizedBox(
            width: 28,
            child: Center(
              child: Text('$quantity', style: AppTextStyles.subtitle),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Tăng số lượng',
            onPressed: isBusy ? null : onIncrease,
            icon: const Icon(Icons.add, size: 18),
          ),
        ],
      ),
    );
  }
}
