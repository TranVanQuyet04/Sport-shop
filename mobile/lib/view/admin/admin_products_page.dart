import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  final TextEditingController _searchController = TextEditingController();
  _ManagementTab _selectedTab = _ManagementTab.all;
  Timer? _tabSwitchTimer;
  bool _isSwitchingTab = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _loadManagementData();
  }

  @override
  void dispose() {
    _tabSwitchTimer?.cancel();
    _searchController.dispose();
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

  void _selectTab(_ManagementTab tab) {
    if (_selectedTab == tab) {
      return;
    }
    _tabSwitchTimer?.cancel();
    setState(() {
      _selectedTab = tab;
      _isSwitchingTab = true;
    });
    _tabSwitchTimer = Timer(const Duration(milliseconds: 240), () {
      if (mounted) {
        setState(() => _isSwitchingTab = false);
      }
    });
  }

  List<ProductSummaryModel> get _visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    final cleanProducts = _controller.products
        .where((product) => product.id.trim().isNotEmpty)
        .toList(growable: false);
    if (query.isEmpty) {
      return cleanProducts;
    }
    return cleanProducts.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.id.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query);
    }).toList();
  }

  List<AdminCategoryModel> get _visibleCategories {
    final query = _searchController.text.trim().toLowerCase();
    final cleanCategories = _controller.categories
        .where((category) => category.id.trim().isNotEmpty)
        .toList(growable: false);
    if (query.isEmpty) {
      return cleanCategories;
    }
    return cleanCategories.where((category) {
      return category.name.toLowerCase().contains(query) ||
          category.description.toLowerCase().contains(query) ||
          category.id.toLowerCase().contains(query);
    }).toList();
  }

  List<AdminBrandModel> get _visibleBrands {
    final query = _searchController.text.trim().toLowerCase();
    final cleanBrands = _controller.brands
        .where((brand) => brand.id.trim().isNotEmpty)
        .toList(growable: false);
    if (query.isEmpty) {
      return cleanBrands;
    }
    return cleanBrands.where((brand) {
      return brand.name.toLowerCase().contains(query) ||
          brand.description.toLowerCase().contains(query) ||
          brand.id.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _loadManagementData() async {
    await _controller.loadProducts();
    await _controller.loadCategories();
    await _controller.loadBrands();
  }

  Future<void> _editProduct(ProductSummaryModel product) async {
    await _controller.loadProductDetail(product.id);
    if (!mounted) {
      return;
    }

    final detail = _controller.selectedProduct;
    if (detail == null) {
      _showResult(false, 'Không tải được chi tiết sản phẩm.');
      return;
    }

    final result = await showDialog<_ProductFormResult>(
      context: context,
      builder: (_) => _ProductFormDialog(product: detail),
    );
    if (result == null) {
      return;
    }

    final success = await _controller.saveProduct(
      id: detail.id,
      name: result.name,
      description: result.description,
      categoryName: result.categoryName,
      brandName: result.brandName,
      sportName: result.sportName,
      variants: detail.variants.map(_variantPayload).toList(),
    );
    if (!mounted) {
      return;
    }
    _showResult(success, 'Đã cập nhật sản phẩm.');
  }

  Future<void> _deleteProduct(ProductSummaryModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: Text('Bạn có chắc muốn xóa "${product.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    final success = await _controller.deleteProduct(product.id);
    if (!mounted) {
      return;
    }
    _showResult(success, 'Đã xóa sản phẩm.');
  }

  void _showResult(bool success, String successMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? successMessage
              : (_controller.errorMessage ?? 'Thao tác chưa thành công.'),
        ),
      ),
    );
  }

  Map<String, dynamic> _variantPayload(ProductVariantModel variant) {
    return {
      'id': int.tryParse(variant.id),
      'size': variant.size,
      'color': variant.color,
      'price': variant.price,
      'stockQuantity': variant.stockQuantity,
      'sku': variant.sku,
      'imageUrls': variant.imageUrls,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadManagementData,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () => context.go(AppRoutes.adminAddProduct),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm mới'),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildBody() {
    final hasAnyData =
        _controller.products.isNotEmpty ||
        _controller.categories.isNotEmpty ||
        _controller.brands.isNotEmpty;
    if (_controller.isLoading && !hasAnyData) {
      return const PremiumShimmerList(itemCount: 3, itemHeight: 152);
    }
    if (_controller.errorMessage != null && !hasAnyData) {
      return AppErrorState(
        title: 'Không tải được dữ liệu quản lý',
        message: _controller.errorMessage!,
        onAction: _loadManagementData,
      );
    }
    if (!hasAnyData) {
      return PremiumEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Chưa có dữ liệu quản lý',
        message:
            'Sản phẩm, danh mục và thương hiệu sẽ xuất hiện tại đây sau khi đồng bộ backend.',
        actionLabel: 'Thêm mới ngay',
        actionIcon: Icons.add_rounded,
        onAction: () => context.go(AppRoutes.adminAddProduct),
      );
    }
    final products = _visibleProducts;
    final categories = _visibleCategories;
    final brands = _visibleBrands;
    final visibleCount = switch (_selectedTab) {
      _ManagementTab.all => products.length,
      _ManagementTab.categories => categories.length,
      _ManagementTab.brands => brands.length,
    };
    final totalCount = switch (_selectedTab) {
      _ManagementTab.all => _controller.products.length,
      _ManagementTab.categories => _controller.categories.length,
      _ManagementTab.brands => _controller.brands.length,
    };
    final sectionTitle = switch (_selectedTab) {
      _ManagementTab.all => 'Danh sách sản phẩm',
      _ManagementTab.categories => 'Danh sách danh mục',
      _ManagementTab.brands => 'Danh sách thương hiệu',
    };
    final sectionSubtitle = switch (_selectedTab) {
      _ManagementTab.all => '$visibleCount sản phẩm phù hợp',
      _ManagementTab.categories => '$visibleCount danh mục phù hợp',
      _ManagementTab.brands => '$visibleCount thương hiệu phù hợp',
    };
    final dynamicContent = _isSwitchingTab
        ? PremiumShimmerList(
            itemCount: 3,
            itemHeight: _selectedTab == _ManagementTab.all ? 152 : 92,
            showThumbnail: true,
          )
        : visibleCount == 0
        ? _buildEmptyState()
        : _buildManagementList(
            sectionTitle: sectionTitle,
            sectionSubtitle: sectionSubtitle,
            products: products,
            categories: categories,
            brands: brands,
          );
    return AbsolutePersistentLayout(
      title: 'Quản lý sản phẩm',
      subtitle: 'Theo dõi danh mục, giá bán và dữ liệu kho sản phẩm.',
      icon: Icons.inventory_2_outlined,
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AdminColors.primarySoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '$visibleCount/$totalCount',
          style: AppTextStyles.caption.copyWith(
            color: AdminColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      filterAndSearchZone: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_controller.errorMessage != null) ...[
            _ProductErrorBanner(
              message: _controller.errorMessage!,
              onRefresh: _loadManagementData,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _ProductToolbar(
            controller: _searchController,
            selectedTab: _selectedTab,
            onSearchChanged: (_) => setState(() {}),
            onTabChanged: _selectTab,
          ),
        ],
      ),
      dynamicContent: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: KeyedSubtree(
          key: ValueKey(
            'products-$_selectedTab-${_searchController.text}-${_isSwitchingTab ? 'loading' : visibleCount}',
          ),
          child: dynamicContent,
        ),
      ),
    );
  }

  Widget _buildManagementList({
    required String sectionTitle,
    required String sectionSubtitle,
    required List<ProductSummaryModel> products,
    required List<AdminCategoryModel> categories,
    required List<AdminBrandModel> brands,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
      children: [
        AdminSectionTitle(
          title: sectionTitle,
          subtitle: sectionSubtitle,
          trailing: IconButton(
            tooltip: 'Làm mới',
            onPressed: _controller.isLoading ? null : _loadManagementData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_selectedTab == _ManagementTab.all)
          ...products
              .where((product) => product.id.trim().isNotEmpty)
              .map(
                (product) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ProductListItemWidget(
                    product: product,
                    onTap: () =>
                        context.go('/admin/products/${product.id}/variants'),
                    onEdit: () => _editProduct(product),
                    onVariants: () =>
                        context.go('/admin/products/${product.id}/variants'),
                    onDelete: () => _deleteProduct(product),
                  ),
                ),
              )
        else if (_selectedTab == _ManagementTab.categories)
          ...categories
              .where((category) => category.id.trim().isNotEmpty)
              .map(
                (category) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _CategoryLookupItem(category: category),
                ),
              )
        else
          ...brands
              .where((brand) => brand.id.trim().isNotEmpty)
              .map(
                (brand) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _BrandLookupItem(brand: brand),
                ),
              ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildEmptyState() {
    return PremiumEmptyState(
      icon: _emptyPresentation.icon,
      title: _emptyPresentation.title,
      message: _emptyPresentation.message,
      actionLabel: _searchController.text.trim().isEmpty
          ? _emptyPresentation.refreshLabel
          : 'Xóa tìm kiếm',
      actionIcon: _searchController.text.trim().isEmpty
          ? Icons.refresh_rounded
          : Icons.filter_alt_off_outlined,
      onAction: _searchController.text.trim().isEmpty
          ? _loadManagementData
          : () {
              _searchController.clear();
              setState(() {});
            },
    );
  }

  _ManagementEmptyPresentation get _emptyPresentation {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    if (hasSearch) {
      return switch (_selectedTab) {
        _ManagementTab.all => const _ManagementEmptyPresentation(
          icon: Icons.search_off_rounded,
          title: 'Không tìm thấy sản phẩm',
          message:
              'Không có sản phẩm nào khớp với từ khóa hiện tại. Từ khóa sẽ vẫn được giữ khi đổi tab.',
        ),
        _ManagementTab.categories => const _ManagementEmptyPresentation(
          icon: Icons.search_off_rounded,
          title: 'Không tìm thấy danh mục',
          message:
              'Không có danh mục nào khớp với từ khóa hiện tại. Bạn có thể đổi tab mà không mất nội dung tìm kiếm.',
        ),
        _ManagementTab.brands => const _ManagementEmptyPresentation(
          icon: Icons.search_off_rounded,
          title: 'Không tìm thấy thương hiệu',
          message:
              'Không có thương hiệu nào khớp với từ khóa hiện tại. Hãy thử nhập tên khác.',
        ),
      };
    }
    return switch (_selectedTab) {
      _ManagementTab.all => const _ManagementEmptyPresentation(
        icon: Icons.inventory_2_outlined,
        title: 'Chưa có sản phẩm',
        message:
            'Danh mục sản phẩm đang trống. Hãy tạo sản phẩm đầu tiên để bắt đầu quản lý kho.',
        refreshLabel: 'Tải lại sản phẩm',
      ),
      _ManagementTab.categories => const _ManagementEmptyPresentation(
        icon: Icons.category_outlined,
        title: 'Chưa có danh mục',
        message:
            'Backend chưa trả về danh mục sản phẩm nào. Danh mục mới sẽ giúp phân loại sản phẩm rõ ràng hơn.',
        refreshLabel: 'Tải lại danh mục',
      ),
      _ManagementTab.brands => const _ManagementEmptyPresentation(
        icon: Icons.verified_outlined,
        title: 'Chưa có thương hiệu',
        message:
            'Backend chưa trả về thương hiệu nào. Thương hiệu giúp Admin kiểm soát nhận diện sản phẩm.',
        refreshLabel: 'Tải lại thương hiệu',
      ),
    };
  }
}

class _ManagementEmptyPresentation {
  const _ManagementEmptyPresentation({
    required this.icon,
    required this.title,
    required this.message,
    this.refreshLabel = 'Tải lại dữ liệu',
  });

  final IconData icon;
  final String title;
  final String message;
  final String refreshLabel;
}

enum _ManagementTab {
  all('Tất cả', Icons.inventory_2_outlined),
  categories('Danh mục', Icons.category_outlined),
  brands('Thương hiệu', Icons.verified_outlined);

  const _ManagementTab(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _ProductToolbar extends StatelessWidget {
  const _ProductToolbar({
    required this.controller,
    required this.selectedTab,
    required this.onSearchChanged,
    required this.onTabChanged,
  });

  final TextEditingController controller;
  final _ManagementTab selectedTab;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_ManagementTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tìm tên, mã, danh mục hoặc thương hiệu...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final tab in _ManagementTab.values) ...[
                  ChoiceChip(
                    avatar: Icon(
                      tab.icon,
                      size: 18,
                      color: selectedTab == tab
                          ? Colors.white
                          : AdminColors.textSecondary,
                    ),
                    label: Text(tab.label),
                    selected: selectedTab == tab,
                    showCheckmark: false,
                    onSelected: (_) => onTabChanged(tab),
                    selectedColor: AdminColors.primary,
                    backgroundColor: AdminColors.surfaceMuted,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                      color: selectedTab == tab
                          ? Colors.white
                          : AdminColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryLookupItem extends StatelessWidget {
  const _CategoryLookupItem({required this.category});

  final AdminCategoryModel category;

  @override
  Widget build(BuildContext context) {
    return AdminOutlinedSurface(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const AdminIconBadge(icon: Icons.category_outlined, size: 44),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  category.description.isEmpty
                      ? 'Không có mô tả'
                      : category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandLookupItem extends StatelessWidget {
  const _BrandLookupItem({required this.brand});

  final AdminBrandModel brand;

  @override
  Widget build(BuildContext context) {
    return AdminOutlinedSurface(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AdminColors.surfaceMuted,
              border: Border.all(color: AdminColors.inputBorder),
            ),
            child: brand.logo.trim().isEmpty
                ? const Icon(
                    Icons.broken_image_outlined,
                    color: AdminColors.textSecondary,
                    size: 20,
                  )
                : Image.network(
                    brand.logo,
                    fit: BoxFit.contain,
                    webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      color: AdminColors.textSecondary,
                      size: 20,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  brand.description.isEmpty
                      ? 'Không có mô tả'
                      : brand.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _BrandStatePill(isActive: brand.isActive),
        ],
      ),
    );
  }
}

class _BrandStatePill extends StatelessWidget {
  const _BrandStatePill({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isActive ? AdminColors.successSoft : AdminColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Hoạt động' : 'Đã tắt',
        style: AppTextStyles.caption.copyWith(
          color: isActive ? AdminColors.success : AdminColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProductErrorBanner extends StatelessWidget {
  const _ProductErrorBanner({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return AdminInlineBanner(
      message: message,
      onRefresh: onRefresh,
      isError: true,
    );
  }
}

class _ProductFormResult {
  const _ProductFormResult({
    required this.name,
    required this.description,
    required this.categoryName,
    required this.brandName,
    required this.sportName,
  });

  final String name;
  final String description;
  final String categoryName;
  final String brandName;
  final String sportName;
}

class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({required this.product});

  final ProductDetailModel product;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.product.name,
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.product.description);
  late final TextEditingController _categoryController = TextEditingController(
    text: widget.product.category,
  );
  late final TextEditingController _brandController = TextEditingController(
    text: widget.product.brand,
  );
  late final TextEditingController _sportController = TextEditingController(
    text: widget.product.sport,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _sportController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.pop(
      context,
      _ProductFormResult(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryName: _categoryController.text.trim(),
        brandName: _brandController.text.trim(),
        sportName: _sportController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sửa thông tin sản phẩm'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(
                controller: _nameController,
                label: 'Tên sản phẩm',
                required: true,
              ),
              _DialogField(
                controller: _descriptionController,
                label: 'Mô tả',
                minLines: 3,
              ),
              _DialogField(
                controller: _categoryController,
                label: 'Danh mục',
                required: true,
              ),
              _DialogField(
                controller: _brandController,
                label: 'Thương hiệu',
                required: true,
              ),
              _DialogField(controller: _sportController, label: 'Môn thể thao'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    this.minLines = 1,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final int minLines;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines == 1 ? 1 : 5,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'Vui lòng nhập $label.';
          }
          return null;
        },
      ),
    );
  }
}

class ProductListItemWidget extends StatelessWidget {
  const ProductListItemWidget({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onVariants,
    required this.onDelete,
  });

  final ProductSummaryModel product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onVariants;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(product.price);
    final classification = [
      if (product.category.isNotEmpty) product.category,
      if (product.brand.isNotEmpty) product.brand.toUpperCase(),
    ].join(' • ');

    return AdminSurface(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 440;
          final thumbnail = _ProductThumbnail(product: product);
          final information = _ProductInformation(
            product: product,
            classification: classification,
          );
          final controls = _ProductPriceAndActions(
            price: '$priceTextđ',
            onEdit: onEdit,
            onVariants: onVariants,
            onDelete: onDelete,
            showMenu: !compact,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    thumbnail,
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: information),
                    _ProductMenu(
                      onEdit: onEdit,
                      onVariants: onVariants,
                      onDelete: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1, color: AdminColors.border),
                const SizedBox(height: AppSpacing.md),
                controls,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              thumbnail,
              const SizedBox(width: AppSpacing.md),
              Expanded(child: information),
              const SizedBox(width: AppSpacing.lg),
              controls,
            ],
          );
        },
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.product});

  final ProductSummaryModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AdminColors.inputBorder),
      ),
      child: product.imageUrl.isEmpty
          ? const Icon(
              Icons.checkroom_outlined,
              color: Color(0xFF94A3B8),
              size: 32,
            )
          : Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (_, _, _) => const Icon(
                Icons.broken_image_outlined,
                color: Color(0xFF94A3B8),
                size: 28,
              ),
            ),
    );
  }
}

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({
    required this.product,
    required this.classification,
  });

  final ProductSummaryModel product;
  final String classification;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          classification.isEmpty ? 'Chưa phân loại' : classification,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(
            color: AdminColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            _AdminMetadata(
              icon: Icons.qr_code_2_outlined,
              label: 'SKU',
              value: 'Xem biến thể',
            ),
            const _AdminMetadata(
              icon: Icons.warehouse_outlined,
              label: 'Tồn kho',
              value: 'Xem chi tiết',
            ),
            _AdminMetadata(
              icon: Icons.tag_outlined,
              label: 'Mã SP',
              value: '#${product.id}',
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminMetadata extends StatelessWidget {
  const _AdminMetadata({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AdminColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$label: ',
          style: AppTextStyles.caption.copyWith(
            color: AdminColors.textSecondary,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: AdminColors.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProductPriceAndActions extends StatelessWidget {
  const _ProductPriceAndActions({
    required this.price,
    required this.onEdit,
    required this.onVariants,
    required this.onDelete,
    this.showMenu = true,
  });

  final String price;
  final VoidCallback onEdit;
  final VoidCallback onVariants;
  final VoidCallback onDelete;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              price,
              style: AppTextStyles.subtitle.copyWith(
                color: AdminColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const _ProductStatusBadge(),
          ],
        ),
        if (showMenu) ...[
          const SizedBox(width: AppSpacing.sm),
          _ProductMenu(
            onEdit: onEdit,
            onVariants: onVariants,
            onDelete: onDelete,
          ),
        ],
      ],
    );
  }
}

class _ProductStatusBadge extends StatelessWidget {
  const _ProductStatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AdminColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Chưa đồng bộ',
        style: AppTextStyles.caption.copyWith(
          color: AdminColors.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProductMenu extends StatelessWidget {
  const _ProductMenu({
    required this.onEdit,
    required this.onVariants,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onVariants;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Thao tác',
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'variants') {
          onVariants();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'edit', child: Text('Sửa thông tin')),
        PopupMenuItem(value: 'variants', child: Text('Biến thể / kho')),
        PopupMenuItem(value: 'delete', child: Text('Xóa')),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
