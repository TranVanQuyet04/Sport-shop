import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/mock/customer_demo_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/product_card.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppTextField(
            label: 'Từ khóa',
            hintText: 'Tìm giày, áo, phụ kiện...',
            prefixIcon: Icons.search,
            suffixIcon: Icons.tune,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {},
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showFilterSheet(context),
              icon: const Icon(Icons.tune),
              label: const Text('Bộ lọc nâng cao'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Tìm kiếm gần đây', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.md),
          const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _KeywordChip(label: 'Nike Air Max'),
              _KeywordChip(label: 'Áo chạy bộ'),
              _KeywordChip(label: 'Giày training nam'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Danh mục phổ biến', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Expanded(
                child: _CategoryShortcut(
                  icon: Icons.directions_run,
                  label: 'Running',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CategoryShortcut(
                  icon: Icons.fitness_center,
                  label: 'Training',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CategoryShortcut(
                  icon: Icons.sports_basketball,
                  label: 'Phụ kiện',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text('Gợi ý cho bạn', style: AppTextStyles.title),
              ),
              Text(
                '${CustomerDemoData.products.length} sản phẩm',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: CustomerDemoData.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.xl,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              return ProductCard(
                product: CustomerDemoData.products[index],
                index: index,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 1),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      title: 'Bộ lọc sản phẩm',
      subtitle: 'Thu hẹp kết quả theo thương hiệu, môn thể thao và ngân sách.',
      child: const _FilterContent(),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Đặt lại',
                variant: AppButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: 'Áp dụng',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterContent extends StatelessWidget {
  const _FilterContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thương hiệu', style: AppTextStyles.subtitle),
        const SizedBox(height: AppSpacing.md),
        const Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _SelectableChip(label: 'Nike', selected: true),
            _SelectableChip(label: 'Adidas'),
            _SelectableChip(label: 'Puma'),
            _SelectableChip(label: 'Under Armour'),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Môn thể thao', style: AppTextStyles.subtitle),
        const SizedBox(height: AppSpacing.md),
        const Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _SelectableChip(label: 'Running', selected: true),
            _SelectableChip(label: 'Gym'),
            _SelectableChip(label: 'Football'),
            _SelectableChip(label: 'Yoga'),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Khoảng giá', style: AppTextStyles.subtitle),
        const SizedBox(height: AppSpacing.md),
        RangeSlider(
          values: const RangeValues(450000, 3500000),
          min: 0,
          max: 5000000,
          divisions: 10,
          labels: const RangeLabels('450k', '3.5tr'),
          onChanged: (_) {},
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Text('0đ', style: AppTextStyles.caption),
            const Spacer(),
            Text('5.000.000đ', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.history, size: 18),
      label: Text(label),
      onPressed: () {},
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) {},
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textInverse,
      labelStyle: AppTextStyles.caption.copyWith(
        color: selected ? AppColors.textInverse : AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  const _CategoryShortcut({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.secondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
