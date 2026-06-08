import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class ShipperAccountPage extends StatelessWidget {
  const ShipperAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.delivery_dining, size: 42),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Lê Minh Shipper', style: AppTextStyles.title),
                Text('DELIVERY_STAFF • Đang trong ca', style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Row(
            children: [
              Expanded(child: _AccountMetric(label: 'Đã giao', value: '28')),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _AccountMetric(label: 'Thành công', value: '98%')),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _AccountMetric(label: 'COD', value: '4.8tr')),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Ca làm việc', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          const _InfoTile(icon: Icons.schedule, title: 'Ca chiều', subtitle: '13:00 - 21:00 hôm nay'),
          const _InfoTile(icon: Icons.storefront_outlined, title: 'Điểm nhận hàng', subtitle: 'Sportshop Quận 1'),
          const _InfoTile(icon: Icons.map_outlined, title: 'Khu vực phụ trách', subtitle: 'Quận 1, Quận 3, Bình Thạnh'),
          const SizedBox(height: AppSpacing.xl),
          Text('Tài khoản', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          const _InfoTile(icon: Icons.person_outline, title: 'Thông tin cá nhân', subtitle: 'Số điện thoại, CCCD, phương tiện'),
          const _InfoTile(icon: Icons.history, title: 'Lịch sử giao hàng', subtitle: 'Xem các đơn đã xử lý'),
          const _InfoTile(icon: Icons.logout, title: 'Đăng xuất', subtitle: 'Thoát khỏi tài khoản giao hàng', danger: true),
        ],
      ),
      bottomNavigationBar: const DeliveryBottomNav(selectedIndex: 4),
    );
  }
}

class _AccountMetric extends StatelessWidget {
  const _AccountMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.title.copyWith(color: AppColors.secondary)),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.subtitle, this.danger = false});

  final IconData icon;
  final String title;
  final String subtitle;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.surfaceMuted, foregroundColor: color, child: Icon(icon)),
        title: Text(title, style: AppTextStyles.subtitle.copyWith(color: color)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
