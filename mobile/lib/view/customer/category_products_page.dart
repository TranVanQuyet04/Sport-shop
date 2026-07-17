import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../presenter/customer/category_products_presenter.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/product_card.dart';

class CategoryProductsPage extends StatefulWidget {
  const CategoryProductsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  late final CategoryProductsPresenter _presenter = CategoryProductsPresenter(
    productRepository: AppDependencies.instance.productRepository,
    categoryId: widget.categoryId,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onPresenterChanged);
    _presenter.loadProducts();
  }

  @override
  void dispose() {
    _presenter
      ..removeListener(_onPresenterChanged)
      ..dispose();
    super.dispose();
  }

  void _onPresenterChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _presenter.filteredProducts;
    final title = widget.categoryName.isEmpty
        ? 'Tất cả sản phẩm'
        : widget.categoryName;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Lọc theo màu và giá',
            onPressed: _presenter.isLoading ? null : _showFilterSheet,
            icon: Badge(
              isLabelVisible: _presenter.hasActiveFilters,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _presenter.loadProducts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _CatalogHeader(
              title: title,
              productCount: products.length,
              hasFilters: _presenter.hasActiveFilters,
              selectedProductName: _presenter.selectedProductName,
              selectedColor: _presenter.selectedColor,
              minPrice: _presenter.minPrice,
              maxPrice: _presenter.maxPrice,
              onOpenFilters: _showFilterSheet,
              onClearFilters: _presenter.clearFilters,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_presenter.isLoading && products.isEmpty)
              const AppLoadingState(title: 'Đang tải sản phẩm')
            else if (_presenter.errorMessage != null && products.isEmpty)
              AppErrorState(
                title: 'Không tải được sản phẩm',
                message: _presenter.errorMessage!,
                onAction: _presenter.loadProducts,
              )
            else if (products.isEmpty)
              AppEmptyState(
                title: 'Không có sản phẩm phù hợp',
                message: _presenter.hasActiveFilters
                    ? 'Hãy thử đổi màu hoặc khoảng giá.'
                    : 'Danh mục này hiện chưa có sản phẩm.',
                actionLabel: _presenter.hasActiveFilters ? 'Xóa bộ lọc' : null,
                onAction: _presenter.hasActiveFilters
                    ? _presenter.clearFilters
                    : null,
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
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) =>
                    ProductCard(product: products[index], index: index),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 1),
    );
  }

  void _showFilterSheet() {
    var productId = _presenter.selectedProductId;
    var color = _presenter.selectedColor;
    var range = RangeValues(
      _presenter.minPrice.toDouble(),
      _presenter.maxPrice.toDouble(),
    );
    final minimum = _presenter.catalogMinPrice.toDouble();
    final maximum = _presenter.catalogMaxPrice.toDouble();

    showAppBottomSheet<void>(
      context: context,
      title: 'Bộ lọc sản phẩm',
      subtitle: 'Chọn màu biến thể và khoảng giá bạn muốn.',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sản phẩm', style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: productId,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  labelText: 'Chọn sản phẩm',
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Tất cả sản phẩm'),
                  ),
                  for (final product in _presenter.availableProducts)
                    DropdownMenuItem(
                      value: product.id,
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) =>
                    setSheetState(() => productId = value ?? ''),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Màu sắc', style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.md),
              if (_presenter.availableColors.isEmpty)
                Text(
                  'Chưa có thông tin màu từ sản phẩm.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    FilterChip(
                      label: const Text('Tất cả'),
                      selected: color.isEmpty,
                      onSelected: (_) => setSheetState(() => color = ''),
                    ),
                    for (final option in _presenter.availableColors)
                      FilterChip(
                        label: Text(option),
                        selected: color == option,
                        onSelected: (_) => setSheetState(() => color = option),
                      ),
                  ],
                ),
              const SizedBox(height: AppSpacing.xl),
              Text('Khoảng giá', style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: Text(_formatPrice(range.start.round()))),
                  Text(
                    _formatPrice(range.end.round()),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              if (maximum > minimum)
                RangeSlider(
                  min: minimum,
                  max: maximum,
                  values: range,
                  labels: RangeLabels(
                    _formatPrice(range.start.round()),
                    _formatPrice(range.end.round()),
                  ),
                  onChanged: (value) => setSheetState(() => range = value),
                ),
            ],
          );
        },
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Đặt lại',
                variant: AppButtonVariant.outline,
                onPressed: () {
                  _presenter.clearFilters();
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: 'Áp dụng',
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  _presenter.applyFilters(
                    productId: productId,
                    color: color,
                    minPrice: range.start.round(),
                    maxPrice: range.end.round(),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatPrice(int value) =>
      '${NumberFormat.decimalPattern('vi_VN').format(value)}đ';
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({
    required this.title,
    required this.productCount,
    required this.hasFilters,
    required this.selectedProductName,
    required this.selectedColor,
    required this.minPrice,
    required this.maxPrice,
    required this.onOpenFilters,
    required this.onClearFilters,
  });

  final String title;
  final int productCount;
  final bool hasFilters;
  final String selectedProductName;
  final String selectedColor;
  final int minPrice;
  final int maxPrice;
  final VoidCallback onOpenFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.decimalPattern('vi_VN');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$productCount sản phẩm',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onOpenFilters,
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: Text(hasFilters ? 'Đang lọc' : 'Màu & giá'),
            ),
            if (hasFilters) ...[
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  [
                    if (selectedProductName.isNotEmpty) selectedProductName,
                    if (selectedColor.isNotEmpty) selectedColor,
                    '${priceFormat.format(minPrice)}đ – ${priceFormat.format(maxPrice)}đ',
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ),
              IconButton(
                tooltip: 'Xóa bộ lọc',
                onPressed: onClearFilters,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
