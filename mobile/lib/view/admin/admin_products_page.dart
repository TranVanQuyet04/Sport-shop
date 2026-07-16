import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/brand_logo_url_validator.dart';
import '../../core/widgets/app_state.dart';
import '../../model/common/backend_models.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/customer/product_summary_model.dart';
import '../../presenter/admin/admin_catalog_presenter.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

part 'admin_products_page_parts/category_brand_tab_views.dart';

enum _ManagementTab { products, categories, brands, sports }

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  late final AdminCatalogPresenter _presenter;
  final TextEditingController _searchController = TextEditingController();

  _ManagementTab _selectedTab = _ManagementTab.products;
  String? _selectedCategoryFilter;
  String? _selectedBrandFilter;
  String? _selectedSportFilter;
  bool _filterLowStock = false;

  List<SportModel> get _visibleSports => _presenter.sports;

  @override
  void initState() {
    super.initState();
    _presenter = AdminCatalogPresenter(
      adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
    );
    _presenter.addListener(_onControllerChanged);
    _loadProducts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = GoRouterState.of(context);
        final tab = state.uri.queryParameters['tab'];
        if (tab == 'sport' || tab == 'sports') {
          setState(() {
            _selectedTab = _ManagementTab.sports;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _presenter.removeListener(_onControllerChanged);
    _presenter.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadProducts() async {
    await _presenter.loadProducts();
    await _presenter.loadCategories();
    await _presenter.loadBrands();
    await _presenter.loadSports();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategoryFilter = null;
      _selectedBrandFilter = null;
      _selectedSportFilter = null;
      _filterLowStock = false;
      _searchController.clear();
      _presenter.search('');
    });
  }

  Future<void> _goToAddProduct() async {
    await context.push(AppRoutes.adminAddProduct);
    _loadProducts();
  }

  Future<void> _goToEditProduct(String productId) async {
    await context.push(AppRoutes.adminAddProduct, extra: productId);
    _loadProducts();
  }

  void _goToDetail(String productId) {
    context.push(AppRoutes.productDetail.replaceAll(':id', productId));
  }

  Future<void> _deleteProduct(String productId, String productName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(productName: productName),
    );

    if (confirmed == true) {
      final success = await _presenter.deleteProduct(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Đã xóa sản phẩm thành công'
                  : (_presenter.errorMessage ?? 'Xóa sản phẩm thất bại'),
            ),
            backgroundColor: success
                ? const Color(0xFF16A34A)
                : const Color(0xFFDC2626),
          ),
        );
        if (success) {
          _loadProducts();
        }
      }
    }
  }

  List<ProductSummaryModel> get _filteredProducts {
    List<ProductSummaryModel> list = _presenter.products;

    if (_presenter.searchKeyword.isNotEmpty) {
      final kw = _presenter.searchKeyword.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(kw) ||
            p.brand.toLowerCase().contains(kw) ||
            p.category.toLowerCase().contains(kw) ||
            p.sport.toLowerCase().contains(kw) ||
            p.id.toLowerCase().contains(kw);
      }).toList();
    }

    if (_selectedCategoryFilter != null) {
      list = list
          .where(
            (p) =>
                p.category.toLowerCase() ==
                _selectedCategoryFilter!.toLowerCase(),
          )
          .toList();
    }

    if (_selectedBrandFilter != null) {
      list = list
          .where(
            (p) => p.brand.toLowerCase() == _selectedBrandFilter!.toLowerCase(),
          )
          .toList();
    }

    if (_selectedSportFilter != null) {
      list = list
          .where(
            (p) => p.sport.toLowerCase() == _selectedSportFilter!.toLowerCase(),
          )
          .toList();
    }

    if (_filterLowStock) {
      // Simulate low stock by showing a portion of products based on hash code
      list = list.where((p) => p.id.hashCode % 3 == 0).toList();
    }

    return list;
  }

  PreferredSizeWidget _adminAppBar(BuildContext context) {
    return const AdminAppBar(title: 'Sản phẩm');
  }

  Widget _adminBottomNav(BuildContext context) {
    return const AdminBottomNav(selectedIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _adminAppBar(context),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        color: const Color(0xFF2563EB),
        child: _buildBody(context),
      ),
      bottomNavigationBar: _adminBottomNav(context),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildTabItem('Sản phẩm', _ManagementTab.products),
            _buildTabItem('Danh mục', _ManagementTab.categories),
            _buildTabItem('Hiệu', _ManagementTab.brands),
            _buildTabItem('Bộ môn', _ManagementTab.sports),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, _ManagementTab tab) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tab;
          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? AdminColors.primary
                  : AdminColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_presenter.isLoading &&
        _presenter.products.isEmpty &&
        _presenter.categories.isEmpty &&
        _presenter.brands.isEmpty &&
        _presenter.sports.isEmpty) {
      return const AppLoadingState(title: 'Đang tải sản phẩm...');
    }

    if (_presenter.errorMessage != null &&
        _presenter.products.isEmpty &&
        _presenter.categories.isEmpty &&
        _presenter.brands.isEmpty &&
        _presenter.sports.isEmpty) {
      return AppErrorState(
        title: 'Không thể tải dữ liệu',
        message: _presenter.errorMessage!,
        onAction: _loadProducts,
      );
    }

    final displayProducts = _filteredProducts;
    final displaySports = _visibleSports.where((s) {
      if (_presenter.searchKeyword.isEmpty) return true;
      return s.name.toLowerCase().contains(
        _presenter.searchKeyword.toLowerCase(),
      );
    }).toList();

    Widget mainContent;

    if (_selectedTab == _ManagementTab.products) {
      if (displayProducts.isEmpty) {
        mainContent = SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: PremiumEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Chưa có sản phẩm',
              message:
                  _presenter.searchKeyword.isNotEmpty ||
                      _selectedCategoryFilter != null ||
                      _selectedBrandFilter != null ||
                      _selectedSportFilter != null ||
                      _filterLowStock
                  ? 'Không tìm thấy sản phẩm nào phù hợp với bộ lọc hiện tại.'
                  : 'Tạo sản phẩm đầu tiên để bắt đầu bán hàng.',
              actionLabel:
                  _presenter.searchKeyword.isNotEmpty ||
                      _selectedCategoryFilter != null ||
                      _selectedBrandFilter != null ||
                      _selectedSportFilter != null ||
                      _filterLowStock
                  ? 'Xóa tất cả bộ lọc'
                  : '+ Thêm sản phẩm',
              onAction:
                  _presenter.searchKeyword.isNotEmpty ||
                      _selectedCategoryFilter != null ||
                      _selectedBrandFilter != null ||
                      _selectedSportFilter != null ||
                      _filterLowStock
                  ? _clearAllFilters
                  : _goToAddProduct,
            ),
          ),
        );
      } else {
        mainContent = ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 100,
          ),
          itemCount: displayProducts.length,
          itemBuilder: (context, index) {
            final product = displayProducts[index];
            return _ProductListItemCard(
              product: product,
              onTapDetail: () => _goToDetail(product.id),
              onTapEdit: () => _goToEditProduct(product.id),
              onTapDelete: () => _deleteProduct(product.id, product.name),
            );
          },
        );
      }
    } else if (_selectedTab == _ManagementTab.categories) {
      mainContent = _buildCategoriesTabContent(context);
    } else if (_selectedTab == _ManagementTab.brands) {
      mainContent = _buildBrandsTabContent(context);
    } else {
      if (displaySports.isEmpty) {
        mainContent = SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: PremiumEmptyState(
                  icon: Icons.directions_run_rounded,
                  title: 'Chưa có môn thể thao',
                  message: _presenter.searchKeyword.isNotEmpty
                      ? 'Không tìm thấy môn thể thao nào phù hợp.'
                      : 'Tạo môn thể thao mới để phân loại sản phẩm.',
                  actionLabel: 'Thêm môn thể thao',
                  onAction: _goToCreateSport,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _SportBlockActionButton(onPressed: _goToCreateSport),
              ),
            ],
          ),
        );
      } else {
        mainContent = SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: displaySports.length,
                  itemBuilder: (context, index) {
                    final sport = displaySports[index];
                    return _SportListItemTile(
                      sport: sport,
                      onTapEdit: () => _goToEditSport(sport),
                      onTapDelete: () => _deleteSport(sport),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _SportBlockActionButton(onPressed: _goToCreateSport),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      }
    }

    final String layoutTitle;
    final String layoutSubtitle;
    final IconData layoutIcon;
    final Widget? layoutTrailing;

    switch (_selectedTab) {
      case _ManagementTab.products:
        layoutTitle = 'Sản phẩm';
        layoutSubtitle = 'Quản lý toàn bộ sản phẩm trong hệ thống';
        layoutIcon = Icons.inventory_2_outlined;
        layoutTrailing = ElevatedButton.icon(
          onPressed: _goToAddProduct,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Thêm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 0,
          ),
        );
        break;
      case _ManagementTab.categories:
        layoutTitle = 'Danh mục';
        layoutSubtitle = 'Cấu trúc phân loại nhóm mặt hàng cửa hàng';
        layoutIcon = Icons.category_outlined;
        layoutTrailing = ElevatedButton.icon(
          onPressed: _goToCreateCategory,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Thêm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 0,
          ),
        );
        break;
      case _ManagementTab.brands:
        layoutTitle = 'Thương hiệu';
        layoutSubtitle = 'Nhãn hàng và đối tác cung ứng StrideX';
        layoutIcon = Icons.verified_outlined;
        layoutTrailing = ElevatedButton.icon(
          onPressed: _goToCreateBrand,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Thêm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 0,
          ),
        );
        break;
      case _ManagementTab.sports:
        layoutTitle = 'Môn thể thao';
        layoutSubtitle = 'Danh sách toàn bộ môn thể thao trong hệ thống';
        layoutIcon = Icons.directions_run_rounded;
        layoutTrailing = ElevatedButton.icon(
          onPressed: _goToCreateSport,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Thêm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 0,
          ),
        );
        break;
    }

    return AbsolutePersistentLayout(
      title: layoutTitle,
      subtitle: layoutSubtitle,
      icon: layoutIcon,
      trailing: layoutTrailing,
      filterAndSearchZone: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabSelector(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _selectedTab == _ManagementTab.products
                    ? 'Tìm kiếm sản phẩm...'
                    : _selectedTab == _ManagementTab.categories
                    ? 'Tìm kiếm danh mục...'
                    : _selectedTab == _ManagementTab.brands
                    ? 'Tìm kiếm thương hiệu...'
                    : 'Tìm kiếm bộ môn...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AdminColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _presenter.search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => _presenter.search(value),
            ),
          ),
          if (_selectedTab == _ManagementTab.products) _buildFilterChipsRow(),
        ],
      ),
      dynamicContent: mainContent,
    );
  }

  Widget _buildFilterChipsRow() {
    final activeFiltersCount =
        (_selectedCategoryFilter != null ? 1 : 0) +
        (_selectedBrandFilter != null ? 1 : 0) +
        (_selectedSportFilter != null ? 1 : 0) +
        (_filterLowStock ? 1 : 0);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          FilterChip(
            label: Text(
              'Tồn kho thấp',
              style: TextStyle(
                color: _filterLowStock
                    ? Colors.white
                    : AdminColors.textSecondary,
                fontSize: 12,
                fontWeight: _filterLowStock
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            selected: _filterLowStock,
            selectedColor: AdminColors.primary,
            checkmarkColor: Colors.white,
            onSelected: (val) => setState(() => _filterLowStock = val),
          ),
          const SizedBox(width: AppSpacing.xs),
          _FilterMenuChip(
            label: _selectedCategoryFilter ?? 'Danh mục',
            options: _presenter.categories.map((c) => c.name).toList(),
            selected: _selectedCategoryFilter != null,
            onSelected: (val) => setState(() => _selectedCategoryFilter = val),
          ),
          const SizedBox(width: AppSpacing.xs),
          _FilterMenuChip(
            label: _selectedBrandFilter ?? 'Thương hiệu',
            options: _presenter.brands.map((b) => b.name).toList(),
            selected: _selectedBrandFilter != null,
            onSelected: (val) => setState(() => _selectedBrandFilter = val),
          ),
          const SizedBox(width: AppSpacing.xs),
          _FilterMenuChip(
            label: _selectedSportFilter ?? 'Bộ môn',
            options: _presenter.sports.map((s) => s.name).toList(),
            selected: _selectedSportFilter != null,
            onSelected: (val) => setState(() => _selectedSportFilter = val),
          ),
          if (activeFiltersCount > 0) ...[
            const SizedBox(width: AppSpacing.xs),
            ActionChip(
              avatar: const Icon(
                Icons.clear,
                size: 14,
                color: AdminColors.danger,
              ),
              label: const Text(
                'Xóa lọc',
                style: TextStyle(color: AdminColors.danger, fontSize: 12),
              ),
              onPressed: _clearAllFilters,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _goToCreateSport() async {
    final TextEditingController nameCtl = TextEditingController();
    final TextEditingController descCtl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm môn thể thao'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(
                labelText: 'Tên môn thể thao',
                hintText: 'Ví dụ: Bóng đá, Chạy bộ...',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: descCtl,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                hintText: 'Mô tả ngắn gọn môn thể thao',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
            ),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && nameCtl.text.trim().isNotEmpty) {
      final success = await _presenter.saveSport(
        name: nameCtl.text.trim(),
        description: descCtl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Đã thêm môn thể thao thành công'
                  : 'Thêm môn thể thao thất bại',
            ),
          ),
        );
        _loadProducts();
      }
    }
  }

  Future<void> _goToEditSport(SportModel sport) async {
    final TextEditingController nameCtl = TextEditingController(
      text: sport.name,
    );
    final TextEditingController descCtl = TextEditingController(
      text: sport.description,
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa môn thể thao'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(labelText: 'Tên môn thể thao'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: descCtl,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
            ),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && nameCtl.text.trim().isNotEmpty) {
      final success = await _presenter.saveSport(
        id: sport.id,
        name: nameCtl.text.trim(),
        description: descCtl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Đã sửa môn thể thao thành công'
                  : 'Sửa môn thể thao thất bại',
            ),
          ),
        );
        _loadProducts();
      }
    }
  }

  Future<void> _deleteSport(SportModel sport) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa môn thể thao?'),
        content: Text('Bạn có chắc muốn xóa môn thể thao "${sport.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.danger,
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _presenter.deleteSport(sport.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Đã xóa môn thể thao thành công'
                  : 'Xóa môn thể thao thất bại',
            ),
          ),
        );
        _loadProducts();
      }
    }
  }
}

class _FilterMenuChip extends StatelessWidget {
  const _FilterMenuChip({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final bool selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: onSelected,
      itemBuilder: (context) {
        return [
          const PopupMenuItem<String?>(value: null, child: Text('Tất cả')),
          ...options.map(
            (opt) => PopupMenuItem<String?>(value: opt, child: Text(opt)),
          ),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AdminColors.primarySoft : Colors.white,
          border: Border.all(
            color: selected ? AdminColors.primary : AdminColors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? AdminColors.primary : AdminColors.textPrimary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: selected ? AdminColors.primary : AdminColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductListItemCard extends StatelessWidget {
  const _ProductListItemCard({
    required this.product,
    required this.onTapDetail,
    required this.onTapEdit,
    required this.onTapDelete,
  });

  final ProductSummaryModel product;
  final VoidCallback onTapDetail;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.decimalPattern('vi_VN');
    final formattedPrice = '${currencyFormat.format(product.price)}\u0111';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFF1F5F9),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF94A3B8),
                                size: 28,
                              ),
                        )
                      : const Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFF94A3B8),
                          size: 32,
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (product.category.isNotEmpty)
                            _buildSmallChip(
                              product.category,
                              const Color(0xFF3B82F6),
                            ),
                          if (product.brand.isNotEmpty)
                            _buildSmallChip(
                              product.brand,
                              const Color(0xFF10B981),
                            ),
                          if (product.sport.isNotEmpty)
                            _buildSmallChip(
                              product.sport,
                              const Color(0xFF8B5CF6),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        formattedPrice,
                        style: AppTextStyles.title.copyWith(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _buildActionButton(
                  icon: Icons.visibility_outlined,
                  label: 'Chi tiết',
                  color: const Color(0xFF2563EB),
                  onPressed: onTapDetail,
                ),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Sửa',
                  color: const Color(0xFF475569),
                  onPressed: onTapEdit,
                ),
                _buildActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Xóa',
                  color: const Color(0xFFDC2626),
                  onPressed: onTapDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: color.withValues(alpha: 0.05),
      ),
      icon: Icon(icon, size: 14),
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DeleteConfirmationDialog extends StatelessWidget {
  const _DeleteConfirmationDialog({required this.productName});

  final String productName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AdminColors.danger),
          SizedBox(width: 8),
          Text('Xóa sản phẩm?'),
        ],
      ),
      content: Text(
        'Bạn có chắc chắn muốn xóa sản phẩm "$productName"? Thao tác này không thể hoàn tác.',
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: AdminColors.danger,
            foregroundColor: Colors.white,
          ),
          child: const Text('Xóa'),
        ),
      ],
    );
  }
}

class _SportBlockActionButton extends StatelessWidget {
  const _SportBlockActionButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          'THÊM MÔN THỂ THAO MỚI +',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _SportListItemTile extends StatelessWidget {
  const _SportListItemTile({
    required this.sport,
    required this.onTapEdit,
    required this.onTapDelete,
  });

  final SportModel sport;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.directions_run_rounded,
                color: AdminColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sport.name,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  if (sport.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      sport.description,
                      style: const TextStyle(
                        color: AdminColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF475569),
                size: 20,
              ),
              onPressed: onTapEdit,
              tooltip: 'Chỉnh sửa',
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
              onPressed: onTapDelete,
              tooltip: 'Xóa',
            ),
          ],
        ),
      ),
    );
  }
}
