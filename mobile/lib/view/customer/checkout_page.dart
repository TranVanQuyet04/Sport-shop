import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/sportshop_logo.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final total = NumberFormat.decimalPattern('vi_VN').format(4930000);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)),
        title: const SportshopLogo(),
        actions: const [IconButton(onPressed: null, icon: Icon(Icons.notifications_none))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Thanh toán', style: AppTextStyles.display.copyWith(fontSize: 32)),
          const SizedBox(height: AppSpacing.xl),
          _SectionHeader(
            title: 'Địa chỉ nhận hàng',
            action: 'THAY ĐỔI',
            onTap: () => context.go(AppRoutes.addressBook),
          ),
          const SizedBox(height: AppSpacing.md),
          const _AddressCard(),
          const SizedBox(height: AppSpacing.xl),
          Text('Tóm tắt đơn hàng', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          const _CheckoutItem(name: 'Nike Air Max 270 React', detail: 'Size: 42 | Màu: Đỏ/Đen', price: 3250000, quantity: 1),
          const SizedBox(height: AppSpacing.md),
          const _CheckoutItem(name: 'Áo Compression Pro Tight', detail: 'Size: L | Màu: Đen', price: 850000, quantity: 2),
          const SizedBox(height: AppSpacing.xl),
          Text('Phương thức thanh toán', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          const _PaymentMethod(selected: true, icon: Icons.local_shipping_outlined, title: 'Thanh toán khi nhận hàng (COD)', subtitle: 'Trả tiền khi shipper giao hàng tận nơi'),
          const SizedBox(height: AppSpacing.md),
          const _PaymentMethod(selected: false, icon: Icons.account_balance_outlined, title: 'Chuyển khoản ngân hàng', subtitle: 'Xác nhận đơn hàng sau khi nhận tiền'),
          const SizedBox(height: AppSpacing.xl),
          Text('Ghi chú đơn hàng', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          const TextField(
            minLines: 3,
            maxLines: 4,
            decoration: InputDecoration(hintText: 'Ví dụ: Giao sau giờ hành chính, gọi trước khi đến...'),
          ),
          const SizedBox(height: AppSpacing.xl),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const _PriceRow(label: 'Tổng tiền hàng', value: '4.950.000đ'),
                  const _PriceRow(label: 'Phí vận chuyển', value: '30.000đ'),
                  _PriceRow(label: 'Giảm giá', value: '-50.000đ', valueColor: AppColors.secondary),
                  const Divider(height: AppSpacing.xl),
                  Row(
                    children: [
                      Text('Tổng thanh toán', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
                      const Spacer(),
                      Text('$totalđ', style: AppTextStyles.display.copyWith(fontSize: 30)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 112),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: AppButton(
            label: 'XÁC NHẬN ĐẶT HÀNG  →',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go(AppRoutes.orderSuccess),
          ),
        ),
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
          child: Text(action, style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard();

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
                Text('Nguyễn Văn A • 090 123 4567', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: AppSpacing.xs),
                Text('123 Đường Lê Lợi, Phường Bến Thành, Quận 1, TP. Hồ Chí Minh', style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutItem extends StatelessWidget {
  const _CheckoutItem({required this.name, required this.detail, required this.price, required this.quantity});

  final String name;
  final String detail;
  final int price;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.decimalPattern('vi_VN').format(price);

    return _WhitePanel(
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: const Icon(Icons.directions_run, color: AppColors.secondary, size: 44),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
                Text(detail, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                Text('$priceTextđ', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Text('x$quantity', style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  const _PaymentMethod({required this.selected, required this.icon, required this.title, required this.subtitle});

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      borderColor: selected ? AppColors.primary : Colors.transparent,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
                Text(subtitle, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
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
      child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: child),
    );
  }
}
