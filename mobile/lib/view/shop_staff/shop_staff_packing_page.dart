import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/common/order_status.dart';

class ShopStaffPackingPage extends StatelessWidget {
  const ShopStaffPackingPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)), title: const Text('APEX VELOCITY'), actions: const [IconButton(onPressed: null, icon: Icon(Icons.notifications_none))]),
        body: ListView(padding: const EdgeInsets.all(AppSpacing.lg), children: [
          Text('ĐƠN HÀNG $orderId', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w900)),
          Row(children: [Expanded(child: Text('Chi tiết đóng gói', style: AppTextStyles.display.copyWith(fontSize: 36))), const OrderStatusBadge(status: OrderStatus.confirmed)]),
          const SizedBox(height: AppSpacing.lg),
          DecoratedBox(decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.xl), border: const Border(left: BorderSide(color: AppColors.secondary, width: 4))), child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Text('!  GHI CHÚ KHÁCH HÀNG\n"Vui lòng bọc kỹ phần hộp giày, tôi mua làm quà tặng. Cảm ơn shop!" - Trần Hoàng Long', style: AppTextStyles.body.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)))),
          const SizedBox(height: AppSpacing.xl),
          Row(children: [Expanded(child: Text('Danh sách sản phẩm (3)', style: AppTextStyles.title)), Text('0/3 ĐÃ SOẠN', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w900))]),
          const SizedBox(height: AppSpacing.md),
          const _PackItem(name: 'Pro-Swift Elite Runner', size: '42', color: 'Crimson', qty: '01', icon: Icons.directions_run),
          const _PackItem(name: 'Aero-Dry Training Tee', size: 'L', color: 'Black', qty: '02', icon: Icons.checkroom),
          const _PackItem(name: 'Velocity Tech Shorts', size: 'XL', color: 'Charcoal', qty: '01', icon: Icons.sports_martial_arts),
          const SizedBox(height: AppSpacing.xl),
          Text('Hướng dẫn đóng gói', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          const Row(children: [Expanded(child: _GuideBox(icon: Icons.inventory_2_outlined, label: 'Hộp Size M')), SizedBox(width: AppSpacing.md), Expanded(child: _GuideBox(icon: Icons.crop_7_5, label: 'Dán 2 Tem Seal'))]),
          const SizedBox(height: 120),
        ]),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppButton(label: 'HOÀN TẤT ĐÓNG GÓI', icon: Icons.inventory_2_outlined, onPressed: () => context.go('/shop-staff/orders/$orderId/timeline')),
          ),
        ),
      );
}

class _PackItem extends StatelessWidget {
  const _PackItem({required this.name, required this.size, required this.color, required this.qty, required this.icon});
  final String name; final String size; final String color; final String qty; final IconData icon;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: AppSpacing.md), padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)), child: Row(children: [Container(width: 92, height: 92, decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)), child: Icon(icon, color: AppColors.secondary, size: 48)), const SizedBox(width: AppSpacing.lg), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: AppTextStyles.subtitle), Text('Size: $size   Màu: $color', style: AppTextStyles.body), Text('SL: $qty', style: AppTextStyles.body.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w900))])), const CircleAvatar(backgroundColor: Colors.transparent, child: Icon(Icons.radio_button_unchecked, color: AppColors.border, size: 42))]));
}

class _GuideBox extends StatelessWidget {
  const _GuideBox({required this.icon, required this.label});
  final IconData icon; final String label;
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)), child: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(children: [Icon(icon, size: 34), const SizedBox(height: AppSpacing.md), Text(label, style: AppTextStyles.subtitle)])));
}
