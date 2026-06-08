import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminInventoryVariantsPage extends StatelessWidget {
  const AdminInventoryVariantsPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), actions: const [IconButton(onPressed: null, icon: Icon(Icons.notifications_none)), IconButton(onPressed: null, icon: Icon(Icons.search))]),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _Title(),
          SizedBox(height: AppSpacing.xl),
          Row(children: [
            Expanded(child: _StockSummary(title: 'CẢNH BÁO', value: '04', subtitle: 'Biến thể sắp hết hàng', alert: true)),
            SizedBox(width: AppSpacing.lg),
            Expanded(child: _StockSummary(title: 'TỔNG TỒN', value: '1,240', subtitle: 'Sản phẩm hiện có', dark: true)),
          ]),
          SizedBox(height: AppSpacing.xl),
          Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.md, children: [
            _InventoryChip(label: 'Tất cả', active: true),
            _InventoryChip(label: 'Size 40-42'),
            _InventoryChip(label: 'Màu Đen'),
            _InventoryChip(label: 'Màu Đỏ'),
          ]),
          SizedBox(height: AppSpacing.xl),
          _VariantCard(sku: 'PRO-X1-RED-42', detail: 'Màu Đỏ • Size 42', count: 3, alert: true, icon: Icons.directions_run),
          SizedBox(height: AppSpacing.lg),
          _VariantCard(sku: 'PRO-X1-BLK-40', detail: 'Màu Đen • Size 40', count: 48, icon: Icons.directions_run),
          SizedBox(height: AppSpacing.lg),
          _VariantCard(sku: 'PRO-X1-WHT-41', detail: 'Màu Trắng • Size 41', count: 125, icon: Icons.directions_run),
          SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(onPressed: null, icon: Icon(Icons.add_circle_outline), label: Text('Thêm biến thể mới')),
        ],
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, onPressed: () {}, child: const Icon(Icons.save_outlined)),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Quản lý kho hàng', style: AppTextStyles.display.copyWith(fontSize: 36)), const SizedBox(height: AppSpacing.sm), Text('Kiểm soát biến thể và số lượng tồn kho cho sản phẩm Performance Pro X1.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 18))]);
}

class _StockSummary extends StatelessWidget {
  const _StockSummary({required this.title, required this.value, required this.subtitle, this.alert = false, this.dark = false});
  final String title; final String value; final String subtitle; final bool alert; final bool dark;
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(color: dark ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: alert ? const Border(left: BorderSide(color: AppColors.secondary, width: 4)) : null), child: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.caption.copyWith(color: dark ? Colors.white : AppColors.primary, fontWeight: FontWeight.w900)), const SizedBox(height: AppSpacing.md), Text(value, style: AppTextStyles.display.copyWith(fontSize: 42, color: dark ? Colors.white : AppColors.secondary)), const SizedBox(height: AppSpacing.sm), Text(subtitle, style: AppTextStyles.body.copyWith(color: dark ? Colors.white70 : AppColors.primary))])));
}

class _InventoryChip extends StatelessWidget {
  const _InventoryChip({required this.label, this.active = false});
  final String label; final bool active;
  @override
  Widget build(BuildContext context) => Chip(label: Text(label), backgroundColor: active ? AppColors.primary : AppColors.surfaceMuted, labelStyle: TextStyle(color: active ? Colors.white : AppColors.primary, fontWeight: FontWeight.w900));
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({required this.sku, required this.detail, required this.count, required this.icon, this.alert = false});
  final String sku; final String detail; final int count; final IconData icon; final bool alert;
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.border)), child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Row(children: [Container(width: 90, height: 90, decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)), child: Icon(icon, color: alert ? AppColors.secondary : AppColors.primary, size: 48)), const SizedBox(width: AppSpacing.lg), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (alert) Chip(label: const Text('SẮP HẾT'), backgroundColor: const Color(0xFFFCE8EE), labelStyle: const TextStyle(color: AppColors.secondary)), Text('SKU: $sku', style: AppTextStyles.subtitle), Text(detail, style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic)), const SizedBox(height: AppSpacing.md), Row(children: [const _QtyButton(label: '-'), Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md), child: Text('$count', style: AppTextStyles.title)), const _QtyButton(label: '+'), const Spacer(), Text('Còn $count SP', style: AppTextStyles.body.copyWith(color: alert ? AppColors.secondary : AppColors.primary, fontWeight: FontWeight.w900))])])), IconButton(onPressed: () {}, icon: const Icon(Icons.edit_note))])));
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(width: 42, height: 42, decoration: BoxDecoration(color: label == '+' ? AppColors.primary : AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.sm)), child: Center(child: Text(label, style: TextStyle(color: label == '+' ? Colors.white : AppColors.primary, fontSize: 22))));
}
