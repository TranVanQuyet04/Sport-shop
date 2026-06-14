import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminSystemSettingsPage extends StatelessWidget {
  const AdminSystemSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.notifications_none)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 70,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 70),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Trần Anh Tuấn',
                    style: AppTextStyles.display.copyWith(fontSize: 34),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'admin.tuan@sportswear.vn',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Chip(
                    label: const Text('QUẢN TRỊ VIÊN CAO CẤP'),
                    backgroundColor: AppColors.primary,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'CÀI ĐẶT HỆ THỐNG',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const _SettingTile(
                  icon: Icons.person_outline,
                  title: 'Thông tin cá nhân',
                ),
                const _SettingTile(
                  icon: Icons.lock_outline,
                  title: 'Đổi mật khẩu',
                ),
                const _SettingTile(
                  icon: Icons.notifications_none,
                  title: 'Cài đặt thông báo',
                ),
                const _SettingTile(
                  icon: Icons.language,
                  title: 'Ngôn ngữ',
                  subtitle: 'Tiếng Việt',
                ),
                _SettingTile(
                  icon: Icons.group_outlined,
                  title: 'Quản lý người dùng',
                  route: AppRoutes.adminUsers,
                ),
                _SettingTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Quản lý quyền hạn',
                  route: AppRoutes.adminRoles,
                ),
                _SettingTile(
                  icon: Icons.support_agent,
                  title: 'Hỗ trợ trực tuyến',
                  route: AppRoutes.adminChatRooms,
                ),
                _SettingTile(
                  icon: Icons.category_outlined,
                  title: 'Danh mục',
                  route: AppRoutes.adminCategories,
                ),
                _SettingTile(
                  icon: Icons.verified_outlined,
                  title: 'Thương hiệu',
                  route: AppRoutes.adminBrands,
                ),
                _SettingTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'Giám sát giao hàng',
                  route: AppRoutes.adminDeliveryMonitoring,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
              backgroundColor: AppColors.secondary,
            ),
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'VERSION 4.2.0-ALPHA',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 4),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.route,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? route;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: route == null ? null : () => context.go(route!),
    minVerticalPadding: AppSpacing.lg,
    leading: CircleAvatar(
      backgroundColor: AppColors.surfaceMuted,
      child: Icon(icon, color: AppColors.primary),
    ),
    title: Text(title, style: AppTextStyles.subtitle),
    subtitle: subtitle == null
        ? null
        : Text(
            subtitle!,
            style: AppTextStyles.body.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w900,
            ),
          ),
    trailing: const Icon(Icons.chevron_right),
  );
}
