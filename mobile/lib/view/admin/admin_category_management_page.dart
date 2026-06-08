import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminCategoryManagementPage extends StatelessWidget {
  const AdminCategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), actions: const [IconButton(onPressed: null, icon: Icon(Icons.notifications_none))]),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tìm kiếm danh mục...')),
          SizedBox(height: AppSpacing.xl),
          _Title(title: 'Quản lý Danh mục', subtitle: 'Phân loại sản phẩm của bạn'),
          SizedBox(height: AppSpacing.lg),
          _FeaturedCategory(),
          SizedBox(height: AppSpacing.lg),
          Row(children: [
            Expanded(child: _CategoryTile(icon: Icons.checkroom, title: 'Áo', subtitle: '4 danh mục con', count: '856 SP')),
            SizedBox(width: AppSpacing.md),
            Expanded(child: _CategoryTile(icon: Icons.inventory_2_outlined, title: 'Quần', subtitle: 'Shorts, Tights, Jogger', count: '542 SP')),
          ]),
          SizedBox(height: AppSpacing.md),
          _WideCategory(),
          SizedBox(height: AppSpacing.xl),
          Text('CẤU TRÚC ĐA CẤP TIÊU BIỂU', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppButton(label: 'Thêm Danh mục Mới', variant: AppButtonVariant.secondary, icon: Icons.add_circle_outline, onPressed: null),
          ),
          const AdminBottomNav(selectedIndex: 1),
        ]),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.display.copyWith(fontSize: 34)), Text(subtitle, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 18))]);
}

class _FeaturedCategory extends StatelessWidget {
  const _FeaturedCategory();
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.border)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const CircleAvatar(radius: 32, backgroundColor: AppColors.primary, foregroundColor: Colors.white, child: Icon(Icons.directions_run)), const Spacer(), Chip(label: const Text('1,240 SP'), backgroundColor: AppColors.secondary, labelStyle: const TextStyle(color: Colors.white))]),
            const SizedBox(height: AppSpacing.xxl),
            Text('Giày', style: AppTextStyles.display.copyWith(fontSize: 28)),
            Text('Chạy bộ, Training, Lifestyle', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          ]),
        ),
      );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.icon, required this.title, required this.subtitle, required this.count});
  final IconData icon;
  final String title;
  final String subtitle;
  final String count;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [CircleAvatar(backgroundColor: AppColors.surfaceMuted, child: Icon(icon)), const Spacer(), Text(count, style: AppTextStyles.subtitle)]),
            const SizedBox(height: AppSpacing.xxl),
            Text(title, style: AppTextStyles.display.copyWith(fontSize: 28)),
            Text(subtitle, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          ]),
        ),
      );
}

class _WideCategory extends StatelessWidget {
  const _WideCategory();
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)),
        child: ListTile(minVerticalPadding: AppSpacing.lg, leading: const CircleAvatar(child: Icon(Icons.watch_outlined)), title: Text('Phụ kiện', style: AppTextStyles.title), subtitle: const Text('Tất, Băng đô, Túi tập'), trailing: const Text('128 SP  ›')),
      );
}
