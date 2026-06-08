import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_spacing.dart';
import '../../app/sportshop_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tìm kiếm sản phẩm, SKU...')),
          SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _FilterButton(icon: Icons.credit_card, label: 'Thương hiệu'),
              _FilterButton(icon: Icons.category_outlined, label: 'Danh mục'),
              _FilterButton(icon: Icons.inventory_outlined, label: 'Tồn kho'),
              _FilterButton(icon: Icons.tune, label: 'Lọc nâng cao', active: true),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: null, icon: Icon(Icons.category), label: Text('Danh mục'))),
            SizedBox(width: AppSpacing.md),
            Expanded(child: OutlinedButton.icon(onPressed: null, icon: Icon(Icons.verified), label: Text('Thương hiệu'))),
          ]),
          SizedBox(height: AppSpacing.xl),
          _ProductAdminCard(name: 'Velocity Pro Runner X', sku: '#SKU-2024-A1', category: 'Giày chạy bộ chuyên nghiệp', price: 3250000, stock: '48 đôi', badge: 'Bán chạy', icon: Icons.directions_run),
          SizedBox(height: AppSpacing.lg),
          _ProductAdminCard(name: 'Apex Smart Performance', sku: '#SKU-9921-W2', category: 'Đồng hồ thể thao thông minh', price: 5800000, stock: '0 cái', badge: 'Hết hàng', icon: Icons.watch_outlined),
          SizedBox(height: AppSpacing.lg),
          _ProductAdminCard(name: 'Compression Gear L1', sku: '#SKU-7732-S9', category: 'Áo nén tập luyện cường độ cao', price: 850000, stock: '125 chiếc', icon: Icons.checkroom),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: () => context.go(AppRoutes.adminAddProduct),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.icon, required this.label, this.active = false});

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(backgroundColor: active ? AppColors.secondary : AppColors.surface, foregroundColor: active ? Colors.white : AppColors.primary),
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _ProductAdminCard extends StatelessWidget {
  const _ProductAdminCard({required this.name, required this.sku, required this.category, required this.price, required this.stock, required this.icon, this.badge});

  final String name;
  final String sku;
  final String category;
  final int price;
  final String stock;
  final IconData icon;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.decimalPattern('vi_VN').format(price);

    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          Container(height: 200, decoration: BoxDecoration(color: AppColors.primary, borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl))), child: Center(child: Icon(icon, color: AppColors.secondary, size: 110))),
          if (badge != null)
            Positioned(top: AppSpacing.md, left: AppSpacing.md, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(AppRadius.sm)), child: Padding(padding: const EdgeInsets.all(AppSpacing.sm), child: Text(badge!, style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w900))))),
        ]),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(name, style: AppTextStyles.title, maxLines: 1, overflow: TextOverflow.ellipsis)), Text(sku, style: AppTextStyles.caption)]),
            Text(category, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.lg),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('GIÁ NIÊM YẾT', style: AppTextStyles.caption), Text('$priceTextđ', style: AppTextStyles.display.copyWith(fontSize: 28))])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('TỒN KHO', style: AppTextStyles.caption), Text(stock, style: AppTextStyles.subtitle.copyWith(color: stock.startsWith('0') ? AppColors.secondary : AppColors.primary))]),
            ]),
            const SizedBox(height: AppSpacing.lg),
            Row(children: [
              Expanded(child: FilledButton.icon(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), backgroundColor: AppColors.primary), onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Chỉnh sửa'))),
              const SizedBox(width: AppSpacing.md),
              IconButton(onPressed: () => context.go('/admin/products/${sku.replaceAll('#', '')}/variants'), icon: const Icon(Icons.inventory_2_outlined)),
            ]),
          ]),
        ),
      ]),
    );
  }
}
