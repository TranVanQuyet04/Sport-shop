import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(largeLogo: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _AdminTitle(title: 'Quản lý đơn hàng', count: '128'),
          SizedBox(height: AppSpacing.lg),
          TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tìm kiếm mã đơn, tên khách hàng...')),
          SizedBox(height: AppSpacing.lg),
          _OrderTabs(),
          SizedBox(height: AppSpacing.lg),
          _AdminOrderCard(code: '#AV-98421', customer: 'Nguyễn Minh Hoàng', product: 'Velocity Pro Run 2.0', price: 2450000, status: 'CHỜ XÁC NHẬN', action: 'Xác nhận', actionDark: true),
          SizedBox(height: AppSpacing.lg),
          _AdminOrderCard(code: '#AV-98415', customer: 'Trần Thị Thu Hà', product: 'Apex Court Master', price: 3100000, status: 'ĐANG GIAO', delivery: 'Giao bởi: J&T Express', action: 'Theo dõi'),
          SizedBox(height: AppSpacing.lg),
          _AdminOrderCard(code: '#AV-98399', customer: 'Lê Quốc Khánh', product: 'Air Max Performance', price: 1890000, status: 'HOÀN THÀNH', action: 'Xem chi tiết', disabled: true),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
    );
  }
}

class _AdminTitle extends StatelessWidget {
  const _AdminTitle({required this.title, this.count});

  final String title;
  final String? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.display.copyWith(fontSize: 32))),
        if (count != null)
          DecoratedBox(
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Text(count!, style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ),
      ],
    );
  }
}

class _OrderTabs extends StatelessWidget {
  const _OrderTabs();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ['Tất cả', 'Chờ xác nhận', 'Đang đóng gói', 'Đang giao', 'Hoàn thành']
            .map(
              (tab) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                child: Text(tab, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900, color: tab == 'Tất cả' ? AppColors.primary : AppColors.textSecondary)),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({
    required this.code,
    required this.customer,
    required this.product,
    required this.price,
    required this.status,
    required this.action,
    this.delivery,
    this.actionDark = false,
    this.disabled = false,
  });

  final String code;
  final String customer;
  final String product;
  final int price;
  final String status;
  final String action;
  final String? delivery;
  final bool actionDark;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.decimalPattern('vi_VN').format(price);

    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(code, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900))),
            Text(status, style: AppTextStyles.body.copyWith(backgroundColor: status == 'ĐANG GIAO' ? AppColors.secondary : AppColors.surfaceMuted, color: status == 'ĐANG GIAO' ? Colors.white : AppColors.primary)),
          ]),
          Text(customer, style: AppTextStyles.title),
          if (delivery != null) Text(delivery!, style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            Container(width: 96, height: 96, decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)), child: const Icon(Icons.directions_run, color: AppColors.secondary, size: 48)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product, style: AppTextStyles.subtitle),
              Text('Size: 42 | Màu: Đỏ/Đen', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              Text('SL: 01', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
            ])),
          ]),
          const Divider(height: AppSpacing.xl),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tổng thanh toán', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              Text('$priceTextđ', style: AppTextStyles.title.copyWith(color: disabled ? AppColors.textSecondary : AppColors.secondary)),
            ])),
            SizedBox(width: 150, child: AppButton(label: action, variant: actionDark ? AppButtonVariant.primary : AppButtonVariant.outline, onPressed: disabled ? null : () {})),
          ]),
        ]),
      ),
    );
  }
}
