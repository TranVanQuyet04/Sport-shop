import 'package:flutter/material.dart';

import '../../controller/customer/customer_home_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/product_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final CustomerHomeController _controller = CustomerHomeController(
    productRepository: AppDependencies.instance.productRepository,
  );
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadHome();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _controller.recommendedProducts.where((product) {
      final keyword = _keyword.trim().toLowerCase();
      if (keyword.isEmpty) {
        return true;
      }
      return product.name.toLowerCase().contains(keyword) ||
          product.brand.toLowerCase().contains(keyword) ||
          product.category.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tim kiem')),
      body: RefreshIndicator(
        onRefresh: _controller.loadHome,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(
              label: 'Tu khoa',
              hintText: 'Tim giay, ao, phu kien...',
              prefixIcon: Icons.search,
              suffixIcon: Icons.tune,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _keyword = value),
              onSubmitted: (value) => setState(() => _keyword = value),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showFilterSheet(context),
                icon: const Icon(Icons.tune),
                label: const Text('Bo loc nang cao'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text('Goi y cho ban', style: AppTextStyles.title),
                ),
                Text(
                  '${products.length} san pham',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_controller.isLoading && products.isEmpty)
              const AppLoadingState(title: 'Dang tai san pham')
            else if (_controller.errorMessage != null && products.isEmpty)
              AppErrorState(
                title: 'Khong tai duoc san pham',
                message: _controller.errorMessage!,
                onAction: _controller.loadHome,
              )
            else if (products.isEmpty)
              const AppEmptyState(
                title: 'Khong co san pham',
                message: 'Thu doi tu khoa tim kiem hoac tai lai danh sach.',
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.xl,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index], index: index);
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 1),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      title: 'Bo loc san pham',
      subtitle: 'Loc tren danh sach san pham lay truc tiep tu backend.',
      child: const _FilterContent(),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Dat lai',
                variant: AppButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: 'Ap dung',
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
        Text('Thuong hieu', style: AppTextStyles.subtitle),
        const SizedBox(height: AppSpacing.md),
        const Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _SelectableChip(label: 'AeroFit', selected: true),
            _SelectableChip(label: 'StrideX'),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Mon the thao', style: AppTextStyles.subtitle),
        const SizedBox(height: AppSpacing.md),
        const Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _SelectableChip(label: 'Running', selected: true),
            _SelectableChip(label: 'Football'),
          ],
        ),
      ],
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
