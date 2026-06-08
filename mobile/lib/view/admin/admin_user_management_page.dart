import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminUserManagementPage extends StatelessWidget {
  const AdminUserManagementPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard'), actions: const [IconButton(onPressed: null, icon: Icon(Icons.notifications_none))]),
        body: ListView(padding: const EdgeInsets.all(AppSpacing.lg), children: const [
          Text('Quản lý người dùng', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
          SizedBox(height: AppSpacing.lg),
          TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tìm tên, email...')),
          SizedBox(height: AppSpacing.md),
          Wrap(spacing: AppSpacing.md, children: [_RoleChip(label: 'Tất cả', active: true), _RoleChip(label: 'Admin'), _RoleChip(label: 'Staff'), _RoleChip(label: 'Customer')]),
          SizedBox(height: AppSpacing.xl),
          _UserCard(name: 'Nguyễn Văn A', email: 'anguyen@sportswear.com', role: 'Admin', active: true),
          _UserCard(name: 'Trần Thị B', email: 'btran@outlook.com', role: 'Customer', active: true),
          _UserCard(name: 'Lê Văn C', email: 'clevan@internal.vn', role: 'Staff', active: false),
          _UserCard(name: 'Phạm Minh D', email: 'dpham@gmail.com', role: 'Customer', active: true),
        ]),
        floatingActionButton: FloatingActionButton(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, onPressed: null, child: Icon(Icons.person_add_alt)),
        bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
      );
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Chip(label: Text(label), backgroundColor: active ? AppColors.primary : AppColors.surfaceMuted, labelStyle: TextStyle(color: active ? Colors.white : AppColors.primary, fontWeight: FontWeight.w900));
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.name, required this.email, required this.role, required this.active});
  final String name;
  final String email;
  final String role;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const CircleAvatar(radius: 36, child: Icon(Icons.person)), const SizedBox(width: AppSpacing.lg), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: AppTextStyles.title), Text(email)])), const Icon(Icons.more_vert)]),
            const SizedBox(height: AppSpacing.lg),
            Row(children: [Expanded(child: Text('VAI TRÒ\n$role', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900))), Text('TRẠNG THÁI\n${active ? '● Hoạt động' : '● Vô hiệu'}', textAlign: TextAlign.right, style: AppTextStyles.body.copyWith(color: active ? AppColors.success : AppColors.secondary, fontWeight: FontWeight.w900))]),
          ]),
        ),
      );
}
