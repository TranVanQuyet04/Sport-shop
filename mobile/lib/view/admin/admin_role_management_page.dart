import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminRoleManagementPage extends StatelessWidget {
  const AdminRoleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)),
        title: const Text('Quản lý quyền hạn'),
        actions: const [IconButton(onPressed: null, icon: Icon(Icons.notifications_none)), CircleAvatar(child: Icon(Icons.person))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          Row(children: [Expanded(child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tìm kiếm vai trò...'))), SizedBox(width: AppSpacing.md), _AddButton()]),
          SizedBox(height: AppSpacing.xl),
          Row(children: [Expanded(child: Text('DANH SÁCH VAI TRÒ (4)', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w900))), Text('Cập nhật nhanh', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900))]),
          SizedBox(height: AppSpacing.lg),
          _RoleTile(icon: Icons.admin_panel_settings_outlined, name: 'ADMIN', members: '02 thành viên', active: true),
          _RoleTile(icon: Icons.storefront_outlined, name: 'SHOP_STAFF', members: '12 thành viên'),
          _RoleTile(icon: Icons.local_shipping_outlined, name: 'DELIVERY_STAFF', members: '08 thành viên'),
          _RoleTile(icon: Icons.person_outline, name: 'CUSTOMER', members: '1,240 thành viên'),
          SizedBox(height: AppSpacing.xl),
          _SecurityNote(),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();
  @override
  Widget build(BuildContext context) => Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.md)), child: const Icon(Icons.add, color: Colors.white));
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({required this.icon, required this.name, required this.members, this.active = false});
  final IconData icon;
  final String name;
  final String members;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.border)),
        child: ListTile(
          minVerticalPadding: AppSpacing.lg,
          leading: CircleAvatar(radius: 34, backgroundColor: active ? AppColors.primary : AppColors.surfaceMuted, foregroundColor: active ? Colors.white : AppColors.primary, child: Icon(icon)),
          title: Text(name, style: AppTextStyles.title),
          subtitle: Text(members, style: AppTextStyles.body),
          trailing: const Icon(Icons.edit),
        ),
      );
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: const Color(0xFFFFE2E7), border: const Border(left: BorderSide(color: AppColors.secondary, width: 4)), borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.info_outline, color: AppColors.secondary), const SizedBox(width: AppSpacing.md), Expanded(child: Text('Lưu ý bảo mật\nViệc thay đổi quyền của ADMIN có thể ảnh hưởng đến khả năng truy cập hệ thống của toàn bộ quản trị viên.', style: AppTextStyles.body.copyWith(color: AppColors.secondary)))]),
        ),
      );
}
