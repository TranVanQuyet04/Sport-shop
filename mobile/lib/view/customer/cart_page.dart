import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../presenter/customer/cart_presenter.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../model/customer/cart_model.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/sportshop_logo.dart';

part 'cart_page_parts/cart_item_widgets.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CartPresenter _presenter = CartPresenter(
    cartRepository: AppDependencies.instance.cartRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadCart();
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
    final cart = _presenter.cart;
    final totalPrice = cart.totalPrice == 0
        ? cart.computedTotalPrice
        : cart.totalPrice;
    final total = NumberFormat.decimalPattern('vi_VN').format(totalPrice);
    final totalItems = cart.totalItems == 0
        ? cart.items.length
        : cart.totalItems;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.customerHome),
          icon: const Icon(Icons.home_outlined),
        ),
        title: const StrideXLogo(),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _presenter.isLoading ? null : _presenter.loadCart,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Xóa giỏ hàng',
            onPressed: cart.isEmpty || _presenter.isUpdating
                ? null
                : _presenter.clear,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _presenter.loadCart,
        child: _buildBody(cart),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!cart.isEmpty)
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
                          'Tạm tính',
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
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Text(
                          '$totalItems sản phẩm',
                          style: AppTextStyles.caption,
                        ),
                        const Spacer(),
                        Text(
                          'Chưa gồm phí vận chuyển',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Thanh toán ngay',
                      icon: Icons.arrow_forward,
                      variant: AppButtonVariant.secondary,
                      isLoading: _presenter.isUpdating,
                      onPressed: _presenter.isLoading
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
    if (_presenter.isLoading && cart.isEmpty) {
      return const AppLoadingState(
        title: 'Đang tải giỏ hàng',
        message: 'StrideX đang lấy các sản phẩm bạn đã chọn.',
      );
    }

    if (_presenter.errorMessage != null && cart.isEmpty) {
      return AppErrorState(
        title: 'Không tải được giỏ hàng',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadCart,
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        184,
      ),
      itemCount:
          cart.items.length + 1 + (_presenter.errorMessage == null ? 0 : 1),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _CartHeader(
            totalItems: cart.totalItems == 0
                ? cart.items.length
                : cart.totalItems,
          );
        }
        if (index == 1 && _presenter.errorMessage != null) {
          return _InlineCartError(
            message: _presenter.errorMessage!,
            onRetry: _presenter.loadCart,
          );
        }

        final itemIndex = _presenter.errorMessage == null
            ? index - 1
            : index - 2;
        final item = cart.items[itemIndex];
        return _CartItem(
          item: item,
          isBusy: _presenter.isUpdating,
          onDecrease: () => _presenter.decrease(item),
          onIncrease: () => _presenter.increase(item),
          onRemove: () => _presenter.remove(item.id),
        );
      },
    );
  }
}
