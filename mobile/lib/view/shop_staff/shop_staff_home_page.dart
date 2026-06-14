import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../admin/widgets/admin_app_bar.dart';
import '../admin/widgets/admin_bottom_nav.dart';

class ShopStaffHomePage extends StatelessWidget {
  const ShopStaffHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Chào buổi sáng, Nam',
            style: AppTextStyles.display.copyWith(fontSize: 34),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hôm nay có 24 đơn hàng cần xử lý.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _MainWorkCard(
            title: 'CHỜ XÁC NHẬN',
            value: '12',
            icon: Icons.assignment_late_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(
                child: _SmallWorkCard(
                  title: 'ĐANG ĐÓNG GÓI',
                  value: '08',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _SmallWorkCard(
                  title: 'ĐÃ BÀN GIAO',
                  value: '04',
                  icon: Icons.local_shipping_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Thao tác nhanh', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Quét mã đơn hàng',
            icon: Icons.qr_code_scanner,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Xử lý đơn gấp (03)',
            variant: AppButtonVariant.secondary,
            icon: Icons.priority_high,
            onPressed: () => context.go(AppRoutes.shopStaffConfirmOrders),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text('Công việc sắp tới', style: AppTextStyles.title),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.shopStaffConfirmOrders),
                child: const Text('XEM TẤT CẢ'),
              ),
            ],
          ),
          _TaskTile(
            code: '#AV-8842 - Đóng gói',
            subtitle: 'Apex Swift Runner • Size 42',
            icon: Icons.directions_run,
            onTap: () => context.go('/shop-staff/orders/AV-8842/packing'),
          ),
          _TaskTile(
            code: '#AV-8843 - Xác nhận',
            subtitle: 'Elite Pro Tee • Size L',
            icon: Icons.checkroom,
            onTap: () => context.go(AppRoutes.shopStaffConfirmOrders),
          ),
          _TaskTile(
            code: '#AV-8844 - Bàn giao',
            subtitle: 'Performance Crew • Pack of 3',
            icon: Icons.inventory_2_outlined,
            onTap: () => context.go(AppRoutes.shopStaffHandover),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }
}

class _MainWorkCard extends StatelessWidget {
  const _MainWorkCard({
    required this.title,
    required this.value,
    required this.icon,
  });
  final String title;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    height: 150,
    padding: const EdgeInsets.all(AppSpacing.xl),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(value, style: AppTextStyles.display.copyWith(fontSize: 40)),
            ],
          ),
        ),
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.surfaceMuted,
          child: Icon(icon, color: AppColors.primary),
        ),
      ],
    ),
  );
}

class _SmallWorkCard extends StatelessWidget {
  const _SmallWorkCard({
    required this.title,
    required this.value,
    required this.icon,
  });
  final String title;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    height: 160,
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
          ),
        ),
        Text(value, style: AppTextStyles.display.copyWith(fontSize: 36)),
      ],
    ),
  );
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.code,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final String code;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceMuted,
          foregroundColor: AppColors.secondary,
          child: Icon(icon),
        ),
        title: Text(code, style: AppTextStyles.subtitle),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    ),
  );
}
