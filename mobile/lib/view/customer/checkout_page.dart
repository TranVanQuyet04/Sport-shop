import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/hover_effect.dart';
import '../../model/customer/cart_model.dart';
import '../../presenter/customer/checkout_presenter.dart';
import 'widgets/sportshop_logo.dart';

part 'checkout_page_parts/checkout_step_widgets.dart';
part 'checkout_page_parts/checkout_cards.dart';
part 'checkout_page_parts/checkout_summary_widgets.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _noteController = TextEditingController();

  late final CheckoutPresenter _presenter = CheckoutPresenter(
    cartRepository: AppDependencies.instance.cartRepository,
    checkoutRepository: AppDependencies.instance.checkoutRepository,
    paymentRepository: AppDependencies.instance.paymentRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadCheckout();
  }

  @override
  void dispose() {
    _noteController.dispose();
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
    final totalItemsPrice = cart.totalPrice == 0
        ? cart.computedTotalPrice
        : cart.totalPrice;
    const shippingFee = 0;
    const discount = 0;
    final totalPayment = totalItemsPrice + shippingFee - discount;
    final selectedAddress = _presenter.selectedAddress;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _leavePage,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const StrideXLogo(),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _presenter.isLoading ? null : _presenter.loadCheckout,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _presenter.loadCheckout,
        child: _buildBody(
          totalItemsPrice: totalItemsPrice,
          shippingFee: shippingFee,
          discount: discount,
          totalPayment: totalPayment,
        ),
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: selectedAddress == null
                    ? AppButton(
                        label: 'Thêm địa chỉ nhận hàng',
                        icon: Icons.add_location_alt_outlined,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => context.go(AppRoutes.addressBook),
                      )
                    : AppButton(
                        label: 'Xác nhận đặt hàng',
                        icon: Icons.arrow_forward,
                        variant: AppButtonVariant.secondary,
                        isLoading: _presenter.isSubmitting,
                        onPressed: _presenter.isLoading ? null : _submitOrder,
                      ),
              ),
            ),
    );
  }

  Widget _buildBody({
    required int totalItemsPrice,
    required int shippingFee,
    required int discount,
    required int totalPayment,
  }) {
    if (_presenter.isLoading && _presenter.cart.isEmpty) {
      return const AppLoadingState(
        title: 'Đang chuẩn bị thanh toán',
        message: 'StrideX đang tải giỏ hàng và địa chỉ giao hàng.',
      );
    }

    if (_presenter.errorMessage != null && _presenter.cart.isEmpty) {
      return AppErrorState(
        title: 'Không tải được thanh toán',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadCheckout,
      );
    }

    if (_presenter.cart.isEmpty) {
      return AppEmptyState(
        title: 'Chưa có sản phẩm để thanh toán',
        message: 'Hãy thêm sản phẩm vào giỏ hàng trước khi đặt hàng.',
        actionLabel: 'Quay lại mua sắm',
        onAction: () => context.go(AppRoutes.customerHome),
      );
    }

    final selectedAddress = _presenter.selectedAddress;
    final cart = _presenter.cart;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Thanh toán', style: AppTextStyles.display.copyWith(fontSize: 32)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Kiểm tra địa chỉ, phương thức thanh toán và tổng tiền trước khi đặt đơn.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        if (_presenter.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _InlineCheckoutError(message: _presenter.errorMessage!),
        ],
        const SizedBox(height: AppSpacing.xl),
        _CheckoutReviewBanner(
          hasAddress: selectedAddress != null,
          itemCount: cart.items.fold<int>(
            0,
            (sum, item) => sum + item.quantity,
          ),
          paymentMethod: _presenter.paymentMethod,
        ),
        const SizedBox(height: AppSpacing.xl),
        _SectionHeader(
          title: 'Địa chỉ nhận hàng',
          action: selectedAddress == null ? 'THÊM' : 'THAY ĐỔI',
          onTap: () => context.go(AppRoutes.addressBook),
        ),
        const SizedBox(height: AppSpacing.md),
        if (selectedAddress == null)
          _EmptyAddressCard(onTap: () => context.go(AppRoutes.addAddress))
        else
          _AddressCard(
            name: selectedAddress.displayName,
            address: selectedAddress.displayAddress,
          ),
        const SizedBox(height: AppSpacing.xl),
        Text('Tóm tắt đơn hàng', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.md),
        ...cart.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _CheckoutItem(item: item),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Phương thức thanh toán', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.md),
        _PaymentMethod(
          selected: _presenter.paymentMethod == 'COD',
          icon: Icons.local_shipping_outlined,
          title: 'Thanh toán khi nhận hàng (COD)',
          subtitle: 'Trả tiền khi shipper giao hàng tận nơi',
          onTap: () => _presenter.selectPaymentMethod('COD'),
        ),
        const SizedBox(height: AppSpacing.md),
        _PaymentMethod(
          selected: _presenter.paymentMethod == 'VNPAY',
          icon: Icons.account_balance_outlined,
          title: 'VNPay',
          subtitle: 'Thanh toán online qua cổng VNPay',
          onTap: () => _presenter.selectPaymentMethod('VNPAY'),
        ),
        const SizedBox(height: AppSpacing.md),
        _PaymentMethod(
          selected: _presenter.paymentMethod == 'MOMO',
          icon: Icons.account_balance_wallet_outlined,
          title: 'Ví MoMo',
          subtitle: 'Thanh toán online bằng ví MoMo',
          onTap: () => _presenter.selectPaymentMethod('MOMO'),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Ghi chú đơn hàng', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Ghi chú',
          controller: _noteController,
          maxLines: 4,
          hintText: 'Ví dụ: Giao sau giờ hành chính, gọi trước khi đến...',
          prefixIcon: Icons.sticky_note_2_outlined,
        ),
        const SizedBox(height: AppSpacing.xl),
        _PriceSummary(
          totalItemsPrice: totalItemsPrice,
          shippingFee: shippingFee,
          discount: discount,
          totalPayment: totalPayment,
        ),
        const SizedBox(height: 112),
      ],
    );
  }

  Future<void> _submitOrder() async {
    final success = await _presenter.submitOrder(_noteController.text.trim());
    if (!mounted) {
      return;
    }
    if (success) {
      context.go(
        AppRoutes.orderSuccess,
        extra: {
          'order': _presenter.createdOrder,
          'paymentUrl': _presenter.paymentUrl,
        },
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_presenter.errorMessage ?? 'Không thể đặt hàng.')),
    );
  }

  void _leavePage() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.cart);
  }
}
