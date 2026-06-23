import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/hover_effect.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminSystemSettingsPage extends StatelessWidget {
  const AdminSystemSettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cài đặt')),
    body: ListView(
      padding: AdminDesign.pagePadding,
      children: [
        const AdminPageHeader(
          title: 'Cài đặt hệ thống',
          subtitle:
              'Quản lý tài khoản quản trị, module cửa hàng và các kênh tương tác.',
          icon: Icons.settings_outlined,
        ),
        const SizedBox(height: AppSpacing.xl),
        const _AdminProfileCard(),
        const SizedBox(height: AppSpacing.xl),
        const _SettingsSection(
          title: 'TÀI KHOẢN',
          children: [
            _SettingTile(
              icon: Icons.lock_outline,
              title: 'Đổi mật khẩu',
              subtitle: 'Cập nhật mật khẩu đăng nhập quản trị',
              route: AppRoutes.changePassword,
            ),
            _SettingTile(
              icon: Icons.group_outlined,
              title: 'Người dùng',
              subtitle: 'Tài khoản, vai trò và trạng thái truy cập',
              route: AppRoutes.adminUsers,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SettingsSection(
          title: 'QUẢN LÝ CỬA HÀNG',
          children: [
            _SettingTile(
              icon: Icons.category_outlined,
              title: 'Danh mục',
              subtitle: 'Cấu trúc phân loại sản phẩm',
              route: AppRoutes.adminCategories,
            ),
            _SettingTile(
              icon: Icons.verified_outlined,
              title: 'Thương hiệu',
              subtitle: 'Logo và thông tin thương hiệu',
              route: AppRoutes.adminBrands,
            ),
            _SettingTile(
              icon: Icons.sports_basketball_outlined,
              title: 'Môn thể thao',
              subtitle: 'Nhóm thể thao dùng cho điều hướng',
              route: AppRoutes.adminSports,
            ),
            _SettingTile(
              icon: Icons.collections_bookmark_outlined,
              title: 'Bộ sưu tập',
              subtitle: 'Chiến dịch, mùa bán hàng và nhóm nổi bật',
              route: AppRoutes.adminCollections,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SettingsSection(
          title: 'TƯƠNG TÁC & VẬN HÀNH',
          children: [
            _SettingTile(
              icon: Icons.support_agent,
              title: 'Phòng chat',
              subtitle: 'Theo dõi hội thoại hỗ trợ khách hàng',
              route: AppRoutes.adminChatRooms,
            ),
            _SettingTile(
              icon: Icons.local_shipping_outlined,
              title: 'Theo dõi giao hàng',
              subtitle: 'Giám sát tiến trình đơn và shipper',
              route: AppRoutes.adminDeliveryMonitoring,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _LogoutTile(
          onPressed: () async {
            await AppDependencies.instance.authRepository.logout();
            if (context.mounted) {
              context.go(AppRoutes.login);
            }
          },
        ),
      ],
    ),
    bottomNavigationBar: const AdminBottomNav(selectedIndex: 4),
  );
}

class _AdminProfileCard extends StatelessWidget {
  const _AdminProfileCard();

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      hoverEnabled: false,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AdminColors.primarySoft,
            child: Icon(
              Icons.admin_panel_settings_outlined,
              color: AdminColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản trị viên',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Sportshop Admin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Chỉnh sửa hồ sơ',
            onPressed: () => context.go(AppRoutes.adminUsers),
            style: IconButton.styleFrom(
              backgroundColor: AdminColors.surfaceMuted,
              foregroundColor: AdminColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AdminColors.textSecondary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AdminOutlinedSurface(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1)
                  const Divider(indent: 64, endIndent: AppSpacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(route),
        splashColor: AdminColors.primary.withValues(alpha: 0.08),
        highlightColor: AdminColors.primary.withValues(alpha: 0.03),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              AdminIconBadge(icon: icon, size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: AdminColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      scale: 1.01,
      dy: -1,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Material(
        color: AdminColors.dangerSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          splashColor: AdminColors.danger.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const AdminIconBadge(
                  icon: Icons.logout_rounded,
                  color: AdminColors.danger,
                  backgroundColor: Color(0xFFFFF1F2),
                  size: 40,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Đăng xuất',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AdminColors.danger,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
