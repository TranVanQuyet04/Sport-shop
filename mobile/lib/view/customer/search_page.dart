import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../model/common/backend_models.dart';
import '../../model/customer/product_summary_model.dart';
import '../../presenter/customer/customer_home_presenter.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/product_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final CustomerHomePresenter _presenter = CustomerHomePresenter(
    productRepository: AppDependencies.instance.productRepository,
    navigationRepository: AppDependencies.instance.navigationRepository,
  );

  String _keyword = '';
  String _selectedBrand = '';
  String _selectedCategory = '';
  String _selectedSport = '';

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadHome();
  }

  @override
  void dispose() {
    _presenter
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
    final products = _filteredProducts();
    final hasFilters =
        _selectedBrand.isNotEmpty ||
        _selectedCategory.isNotEmpty ||
        _selectedSport.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      body: RefreshIndicator(
        onRefresh: _presenter.loadHome,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(
              label: 'Từ khóa',
              hintText: 'Tìm giày, áo, phụ kiện...',
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
                label: Text(hasFilters ? 'Đang lọc' : 'Bộ lọc'),
              ),
            ),
            if (hasFilters) ...[
              _ActiveFilters(
                brand: _selectedBrand,
                category: _selectedCategory,
                sport: _selectedSport,
                onClear: _clearFilters,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text('Sản phẩm phù hợp', style: AppTextStyles.title),
                ),
                Text(
                  '${products.length} sản phẩm',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_presenter.isLoading && products.isEmpty)
              const AppLoadingState(title: 'Đang tải sản phẩm')
            else if (_presenter.errorMessage != null && products.isEmpty)
              AppErrorState(
                title: 'Không tải được sản phẩm',
                message: _presenter.errorMessage!,
                onAction: _presenter.loadHome,
              )
            else if (products.isEmpty)
              const AppEmptyState(
                title: 'Không có sản phẩm',
                message: 'Thử đổi từ khóa hoặc bộ lọc.',
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

  List<ProductSummaryModel> _filteredProducts() {
    final keyword = _normalize(_keyword);
    return _presenter.recommendedProducts.where((product) {
      final matchesKeyword =
          keyword.isEmpty ||
          _normalize(product.name).contains(keyword) ||
          _normalize(product.brand).contains(keyword) ||
          _normalize(product.category).contains(keyword) ||
          _normalize(product.sport).contains(keyword);
      final matchesBrand =
          _selectedBrand.isEmpty || product.brand == _selectedBrand;
      final matchesCategory =
          _selectedCategory.isEmpty || product.category == _selectedCategory;
      final matchesSport =
          _selectedSport.isEmpty || product.sport == _selectedSport;
      return matchesKeyword && matchesBrand && matchesCategory && matchesSport;
    }).toList();
  }

  List<String> get _categoryOptions {
    final fromNavigation = _flattenCategories(
      _presenter.categories,
    ).map((category) => category.name).where((name) => name.isNotEmpty).toSet();
    final fromProducts = _presenter.recommendedProducts
        .map((product) => product.category)
        .where((name) => name.isNotEmpty)
        .toSet();
    return {...fromNavigation, ...fromProducts}.toList()..sort();
  }

  List<String> get _brandOptions {
    final fromBrandEndpoint = _presenter.brands
        .map((brand) => brand.name)
        .where((name) => name.isNotEmpty)
        .toSet();
    final fromProducts = _presenter.recommendedProducts
        .map((product) => product.brand)
        .where((name) => name.isNotEmpty)
        .toSet();
    return {...fromBrandEndpoint, ...fromProducts}.toList()..sort();
  }

  List<String> get _sportOptions {
    return _presenter.recommendedProducts
        .map((product) => product.sport)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<NavigationCategoryModel> _flattenCategories(
    List<NavigationCategoryModel> categories,
  ) {
    final result = <NavigationCategoryModel>[];
    for (final category in categories) {
      if (category.name.isNotEmpty) {
        result.add(category);
      }
      result.addAll(_flattenCategories(category.children));
    }
    return result;
  }

  void _showFilterSheet(BuildContext context) {
    var brand = _selectedBrand;
    var category = _selectedCategory;
    var sport = _selectedSport;

    showAppBottomSheet<void>(
      context: context,
      title: 'Bộ lọc sản phẩm',
      subtitle: 'Dữ liệu lấy từ backend sản phẩm, thương hiệu và danh mục.',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FilterSection(
                title: 'Thương hiệu',
                options: _brandOptions,
                selected: brand,
                onSelected: (value) => setSheetState(() => brand = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              _FilterSection(
                title: 'Danh mục',
                options: _categoryOptions,
                selected: category,
                onSelected: (value) => setSheetState(() => category = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              _FilterSection(
                title: 'Môn thể thao',
                options: _sportOptions,
                selected: sport,
                onSelected: (value) => setSheetState(() => sport = value),
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
                  setState(_clearFilters);
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
                  setState(() {
                    _selectedBrand = brand;
                    _selectedCategory = category;
                    _selectedSport = sport;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _clearFilters() {
    _selectedBrand = '';
    _selectedCategory = '';
    _selectedSport = '';
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp('[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp('[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp('[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp('[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp('[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp('[ỳýỵỷỹ]'), 'y')
        .replaceAll('đ', 'd');
  }
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({
    required this.brand,
    required this.category,
    required this.sport,
    required this.onClear,
  });

  final String brand;
  final String category;
  final String sport;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final labels = [
      if (brand.isNotEmpty) brand,
      if (category.isNotEmpty) category,
      if (sport.isNotEmpty) sport,
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final label in labels)
          Chip(
            label: Text(label),
            backgroundColor: AppColors.surfaceMuted,
            side: const BorderSide(color: AppColors.border),
          ),
        TextButton(onPressed: onClear, child: const Text('Xóa lọc')),
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.subtitle),
        const SizedBox(height: AppSpacing.md),
        if (options.isEmpty)
          Text(
            'Chưa có dữ liệu',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _SelectableChip(
                label: 'Tất cả',
                selected: selected.isEmpty,
                onSelected: () => onSelected(''),
              ),
              for (final option in options)
                _SelectableChip(
                  label: option,
                  selected: selected == option,
                  onSelected: () => onSelected(option),
                ),
            ],
          ),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textInverse,
      labelStyle: AppTextStyles.caption.copyWith(
        color: selected ? AppColors.textInverse : AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
