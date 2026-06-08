import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/customer_bottom_nav.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Tìm giày, áo, phụ kiện...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () => _showFilterSheet(context),
                icon: const Icon(Icons.tune),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Tìm kiếm gần đây', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.md),
          const _RecentKeyword(label: 'Nike Air Max'),
          const _RecentKeyword(label: 'Áo chạy bộ'),
          const _RecentKeyword(label: 'Giày training nam'),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 1),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bộ lọc sản phẩm', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.lg),
              Text('Thương hiệu', style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  FilterChip(label: Text('Nike'), selected: true, onSelected: null),
                  FilterChip(label: Text('Adidas'), selected: false, onSelected: null),
                  FilterChip(label: Text('Puma'), selected: false, onSelected: null),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Khoảng giá', style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.md),
              RangeSlider(
                values: const RangeValues(450000, 3500000),
                min: 0,
                max: 5000000,
                onChanged: null,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Áp dụng lọc'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentKeyword extends StatelessWidget {
  const _RecentKeyword({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history),
      title: Text(label),
      trailing: const Icon(Icons.north_west, size: 18),
    );
  }
}
