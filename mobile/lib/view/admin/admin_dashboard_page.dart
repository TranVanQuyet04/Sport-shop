import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_stat_card.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('HỆ THỐNG QUẢN TRỊ', style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
          const SizedBox(height: AppSpacing.xs),
          Text('Chào buổi sáng, Admin', style: AppTextStyles.display.copyWith(fontSize: 28)),
          const SizedBox(height: AppSpacing.xl),
          const SizedBox(
            height: 164,
            child: AdminStatCard(
              title: 'Doanh thu hôm nay',
              value: '24.500.000đ',
              subtitle: '↗ +12.5%',
              icon: Icons.payments_outlined,
              dark: true,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(
                child: SizedBox(height: 150, child: AdminStatCard(title: 'Đơn hàng mới', value: '48', subtitle: 'Cần xử lý ngay', icon: Icons.shopping_bag_outlined)),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: SizedBox(height: 150, child: AdminStatCard(title: 'Nhân viên', value: '12', subtitle: 'Đang hoạt động', icon: Icons.badge_outlined)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Thao tác nhanh', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _QuickAction(icon: Icons.add_box_outlined, label: 'Thêm sản phẩm', onTap: () => context.go(AppRoutes.adminProducts)),
              const SizedBox(width: AppSpacing.md),
              _QuickAction(icon: Icons.check_circle_outline, label: 'Duyệt đơn', onTap: () => context.go(AppRoutes.adminOrders)),
              const SizedBox(width: AppSpacing.md),
              _QuickAction(icon: Icons.calendar_month_outlined, label: 'Lịch trực', onTap: () => context.go(AppRoutes.adminStaff)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: Text('Hoạt động gần đây', style: AppTextStyles.title)),
              TextButton(onPressed: () => context.go(AppRoutes.adminOrders), child: const Text('Xem tất cả')),
            ],
          ),
          const _ActivityCard(icon: Icons.local_shipping_outlined, title: 'Đơn hàng #AV-9021 đã được giao', subtitle: 'Sản phẩm: Giày Chạy Apex Velocity Pro v1. Khách hàng: Trần Nam.', accent: AppColors.secondary),
          const _ActivityCard(icon: Icons.person_add_alt, title: 'Nhân viên mới đăng ký', subtitle: 'Lê Minh đã được thêm vào nhóm Staff - Ca sáng.', accent: AppColors.primary),
          const _ActivityCard(icon: Icons.inventory_2_outlined, title: 'Cập nhật kho hàng', subtitle: 'Hết hàng: Áo tập Compression Elite (Size XL - Màu Đen).', accent: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.xl),
          DecoratedBox(
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.lg)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SẢN PHẨM TIÊU BIỂU', style: AppTextStyles.caption.copyWith(color: const Color(0xFFFFD7D7), fontWeight: FontWeight.w900)),
                  const SizedBox(height: AppSpacing.md),
                  Text('Apex\nVelocity Pro\nv1', style: AppTextStyles.display.copyWith(color: Colors.white, fontSize: 28)),
                  const SizedBox(height: AppSpacing.md),
                  Text('Tăng trưởng doanh thu 45% trong tuần này. Cần nhập thêm kho sớm.', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.secondary),
                    onPressed: () => context.go(AppRoutes.adminProducts),
                    child: const Text('Xem chi tiết'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 0),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
            child: Column(
              children: [
                CircleAvatar(backgroundColor: AppColors.surfaceMuted, foregroundColor: AppColors.primary, child: Icon(icon)),
                const SizedBox(height: AppSpacing.md),
                Text(label, textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.icon, required this.title, required this.subtitle, required this.accent});

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.surfaceMuted, foregroundColor: accent, child: Icon(icon)),
        title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: Text('2 phút\ntrước', textAlign: TextAlign.right, style: AppTextStyles.caption),
      ),
    );
  }
}
