import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminBrandManagementPage extends StatelessWidget {
  const AdminBrandManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _Header(),
          SizedBox(height: AppSpacing.xl),
          TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tìm kiếm thương hiệu...')),
          SizedBox(height: AppSpacing.xl),
          _BrandTile(name: 'Nike', count: '1,240 sản phẩm'),
          _BrandTile(name: 'Adidas', count: '892 sản phẩm'),
          _BrandTile(name: 'Puma', count: '456 sản phẩm'),
          _BrandTile(name: 'Under Armour', count: '312 sản phẩm'),
        ],
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, onPressed: () {}, child: const Icon(Icons.add)),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Quản lý thương hiệu', style: AppTextStyles.display.copyWith(fontSize: 36)), Text('Tùy chỉnh danh mục thương hiệu trong hệ thống của bạn.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 18))]);
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.name, required this.count});
  final String name;
  final String count;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: ListTile(
          minVerticalPadding: AppSpacing.lg,
          leading: Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)), child: Center(child: Text(name.characters.first, style: AppTextStyles.title))),
          title: Text(name, style: AppTextStyles.display.copyWith(fontSize: 28)),
          subtitle: Text(count, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          trailing: const Icon(Icons.edit),
        ),
      );
}
