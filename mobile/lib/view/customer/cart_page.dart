import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/sportshop_logo.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final total = NumberFormat.decimalPattern('vi_VN').format(4840000);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        title: const SportshopLogo(),
        actions: const [IconButton(onPressed: null, icon: Icon(Icons.notifications_none))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _CartHeader(),
          SizedBox(height: AppSpacing.xl),
          _CartItem(name: 'Nike Air Max Alpha', variant: 'Size: 42 | Đỏ Crimson', price: 2450000, quantity: 1, icon: Icons.directions_run),
          SizedBox(height: AppSpacing.lg),
          _CartItem(name: 'Pro Compression Top', variant: 'Size: L | Đen Nhám', price: 850000, quantity: 2, icon: Icons.checkroom),
          SizedBox(height: AppSpacing.lg),
          _CartItem(name: 'Dri-FIT Elite Shorts', variant: 'Size: M | Xám Titan', price: 690000, quantity: 1, icon: Icons.sports_martial_arts),
        ],
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
                      Text('Tổng tiền tạm tính', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                      const Spacer(),
                      Text('$totalđ', style: AppTextStyles.display.copyWith(fontSize: 28)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Thanh toán ngay  →',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.go(AppRoutes.checkout),
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
}

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Giỏ hàng', style: AppTextStyles.display.copyWith(fontSize: 34)),
        const Spacer(),
        Text('3 sản phẩm', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 18)),
      ],
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.name,
    required this.variant,
    required this.price,
    required this.quantity,
    required this.icon,
  });

  final String name;
  final String variant;
  final int price;
  final int quantity;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.decimalPattern('vi_VN').format(price);

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
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.secondary, size: 48),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(name, style: AppTextStyles.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.delete_outline, color: AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(variant, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(child: Text('$priceTextđ', style: AppTextStyles.subtitle)),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                          child: Text('-   $quantity   +', style: AppTextStyles.subtitle),
                        ),
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
