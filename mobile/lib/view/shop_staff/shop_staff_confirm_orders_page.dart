import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../admin/widgets/admin_app_bar.dart';
import '../admin/widgets/admin_bottom_nav.dart';

class ShopStaffConfirmOrdersPage extends StatelessWidget {
  const ShopStaffConfirmOrdersPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const AdminAppBar(),
        body: ListView(padding: const EdgeInsets.all(AppSpacing.lg), children: [
          const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tìm đơn hàng hoặc khách hàng...')),
          const SizedBox(height: AppSpacing.xl),
          Row(children: [Expanded(child: _TabLabel(label: 'Chờ xác nhận (12)', active: true)), Expanded(child: _TabLabel(label: 'Đã xác nhận'))]),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: 'Xác nhận hàng loạt', icon: Icons.done_all, onPressed: () {}),
          const SizedBox(height: AppSpacing.xl),
          _ConfirmCard(code: '#AV-92834', customer: 'Nguyễn Văn An', items: '2 sản phẩm', price: 2450000, urgent: true, onDetail: () => context.go('/shop-staff/orders/AV-92834/timeline')),
          _ConfirmCard(code: '#AV-92835', customer: 'Trần Thị Bích', items: '1 sản phẩm', price: 890000, onDetail: () => context.go('/shop-staff/orders/AV-92835/timeline')),
          _ConfirmCard(code: '#AV-92836', customer: 'Lê Hoàng Nam', items: '3 sản phẩm', price: 3120000, onDetail: () => context.go('/shop-staff/orders/AV-92836/timeline')),
        ]),
        bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
      );
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Column(children: [Text(label, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900, color: active ? AppColors.primary : AppColors.textSecondary)), const SizedBox(height: AppSpacing.sm), Container(height: 3, color: active ? AppColors.secondary : Colors.transparent)]);
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({required this.code, required this.customer, required this.items, required this.price, required this.onDetail, this.urgent = false});
  final String code;
  final String customer;
  final String items;
  final int price;
  final VoidCallback onDetail;
  final bool urgent;
  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.decimalPattern('vi_VN').format(price);
    return Container(margin: const EdgeInsets.only(bottom: AppSpacing.lg), padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text('Mã đơn: $code', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 18))), Chip(label: Text(urgent ? 'HỎA TỐC' : 'TIÊU CHUẨN'))]),
      Text(customer, style: AppTextStyles.subtitle),
      const SizedBox(height: AppSpacing.lg),
      Row(children: [Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)), child: const Icon(Icons.directions_run, color: AppColors.secondary)), const SizedBox(width: AppSpacing.lg), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(items, style: AppTextStyles.body), Text('$priceTextđ', style: AppTextStyles.title.copyWith(color: AppColors.secondary))]))]),
      const SizedBox(height: AppSpacing.lg),
      Row(children: [Expanded(child: AppButton(label: 'Chi tiết', variant: AppButtonVariant.outline, onPressed: onDetail)), const SizedBox(width: AppSpacing.md), Expanded(child: AppButton(label: 'Xác nhận', variant: AppButtonVariant.secondary, onPressed: () {}))]),
    ]));
  }
}
