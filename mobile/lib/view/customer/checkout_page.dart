import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../controller/customer/checkout_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../model/customer/cart_model.dart';
import 'widgets/sportshop_logo.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _noteController = TextEditingController();

  late final CheckoutController _controller = CheckoutController(
    cartRepository: AppDependencies.instance.cartRepository,
    checkoutRepository: AppDependencies.instance.checkoutRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadCheckout();
  }

  @override
  void dispose() {
    _noteController.dispose();
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
    final totalItemsPrice = cart.totalPrice == 0
        ? cart.computedTotalPrice
        : cart.totalPrice;
    final shippingFee = cart.isEmpty ? 0 : 30000;
    final discount = cart.isEmpty ? 0 : 0;
    final totalPayment = totalItemsPrice + shippingFee - discount;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const SportshopLogo(),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _controller.isLoading ? null : _controller.loadCheckout,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadCheckout,
        child: _buildBody(
          totalItemsPrice: totalItemsPrice,
          shippingFee: shippingFee,
          discount: discount,
          totalPayment: totalPayment,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: AppButton(
            label: 'Xác nhận đặt hàng',
            icon: Icons.arrow_forward,
            variant: AppButtonVariant.secondary,
            isLoading: _controller.isSubmitting,
            onPressed: _controller.isLoading || cart.isEmpty
                ? null
                : _submitOrder,
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
    if (_controller.isLoading && _controller.cart.isEmpty) {
      return const AppLoadingState(
        title: 'Đang chuẩn bị thanh toán',
        message: 'Sportshop đang tải giỏ hàng và địa chỉ giao hàng.',
      );
    }

    if (_controller.errorMessage != null && _controller.cart.isEmpty) {
      return AppErrorState(
        title: 'Không tải được thanh toán',
        message: _controller.errorMessage!,
        onAction: _controller.loadCheckout,
      );
    }

    if (_controller.cart.isEmpty) {
      return AppEmptyState(
        title: 'Chưa có sản phẩm để thanh toán',
        message: 'Hãy thêm sản phẩm vào giỏ hàng trước khi đặt hàng.',
        actionLabel: 'Quay lại mua sắm',
        onAction: () => context.go(AppRoutes.customerHome),
      );
    }

    final selectedAddress = _controller.selectedAddress;
    final cart = _controller.cart;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Thanh toán', style: AppTextStyles.display.copyWith(fontSize: 32)),
        if (_controller.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _InlineCheckoutError(message: _controller.errorMessage!),
        ],
        const SizedBox(height: AppSpacing.xl),
        const _CheckoutStepHeader(),
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
          selected: _controller.paymentMethod == 'COD',
          icon: Icons.local_shipping_outlined,
          title: 'Thanh toán khi nhận hàng (COD)',
          subtitle: 'Trả tiền khi shipper giao hàng tận nơi',
          onTap: () => _controller.selectPaymentMethod('COD'),
        ),
        const SizedBox(height: AppSpacing.md),
        _PaymentMethod(
          selected: _controller.paymentMethod == 'VNPAY',
          icon: Icons.account_balance_outlined,
          title: 'VNPay',
          subtitle: 'Thanh toán online qua cổng VNPay',
          onTap: () => _controller.selectPaymentMethod('VNPAY'),
        ),
        const SizedBox(height: AppSpacing.md),
        _PaymentMethod(
          selected: _controller.paymentMethod == 'MOMO',
          icon: Icons.account_balance_wallet_outlined,
          title: 'Ví MoMo',
          subtitle: 'Thanh toán online bằng ví MoMo',
          onTap: () => _controller.selectPaymentMethod('MOMO'),
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
    final success = await _controller.submitOrder(_noteController.text.trim());
    if (!mounted) {
      return;
    }
    if (success) {
      context.go(AppRoutes.orderSuccess);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_controller.errorMessage ?? 'Không thể đặt hàng.'),
      ),
    );
  }
}

class _CheckoutStepHeader extends StatelessWidget {
  const _CheckoutStepHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            _StepDot(label: '1', active: true),
            const _StepLine(),
            _StepDot(label: '2', active: true),
            const _StepLine(),
            _StepDot(label: '3', active: false),
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: active ? AppColors.secondary : AppColors.surfaceMuted,
      foregroundColor: active ? AppColors.textInverse : AppColors.textPrimary,
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        color: AppColors.textInverse.withValues(alpha: 0.25),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action, this.onTap});

  final String title;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.title)),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineCheckoutError extends StatelessWidget {
  const _InlineCheckoutError({required this.message});

  final String message;

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
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.name, required this.address});

  final String name;
  final String address;

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(address, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAddressCard extends StatelessWidget {
  const _EmptyAddressCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bạn chưa có địa chỉ giao hàng', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Thêm địa chỉ để Sportshop có thể tạo đơn hàng.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Thêm địa chỉ',
            variant: AppButtonVariant.outline,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _CheckoutItem extends StatelessWidget {
  const _CheckoutItem({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(item.subTotal);

    return _WhitePanel(
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imageUrl.isEmpty
                ? const Icon(
                    Icons.directions_run,
                    color: AppColors.secondary,
                    size: 44,
                  )
                : Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.directions_run,
                        color: AppColors.secondary,
                        size: 44,
                      );
                    },
                  ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  item.variantLabel,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$priceTextđ',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Text('x${item.quantity}', style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  const _PaymentMethod({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: onTap,
      child: _WhitePanel(
        borderColor: selected ? AppColors.primary : AppColors.border,
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.secondary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({
    required this.totalItemsPrice,
    required this.shippingFee,
    required this.discount,
    required this.totalPayment,
  });

  final int totalItemsPrice;
  final int shippingFee;
  final int discount;
  final int totalPayment;

  @override
  Widget build(BuildContext context) {
    final totalText = NumberFormat.decimalPattern('vi_VN').format(totalPayment);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _PriceRow(label: 'Tổng tiền hàng', value: _money(totalItemsPrice)),
            _PriceRow(label: 'Phí vận chuyển', value: _money(shippingFee)),
            _PriceRow(
              label: 'Giảm giá',
              value: '-${_money(discount)}',
              valueColor: AppColors.secondary,
            ),
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
                Text(
                  'Tổng thanh toán',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  '$totalTextđ',
                  style: AppTextStyles.display.copyWith(fontSize: 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _money(int value) {
    return '${NumberFormat.decimalPattern('vi_VN').format(value)}đ';
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.body),
          const Spacer(),
          Text(value, style: AppTextStyles.body.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

class _WhitePanel extends StatelessWidget {
  const _WhitePanel({required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}
