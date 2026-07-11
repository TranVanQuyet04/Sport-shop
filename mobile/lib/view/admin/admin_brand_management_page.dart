import 'package:flutter/material.dart';

import '../../presenter/admin/admin_catalog_presenter.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/brand_logo_url_validator.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

part 'admin_brand_management_page_parts/brand_form_dialog.dart';
part 'admin_brand_management_page_parts/brand_tile_widgets.dart';
part 'admin_brand_management_page_parts/brand_dialog_widgets.dart';

class AdminBrandManagementPage extends StatefulWidget {
  const AdminBrandManagementPage({super.key});

  @override
  State<AdminBrandManagementPage> createState() =>
      _AdminBrandManagementPageState();
}

class _AdminBrandManagementPageState extends State<AdminBrandManagementPage> {
  late final AdminCatalogPresenter _presenter = AdminCatalogPresenter(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<AdminBrandModel> get _filteredBrands {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _presenter.brands;
    }
    return _presenter.brands.where((brand) {
      return brand.name.toLowerCase().contains(query) ||
          brand.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadBrands();
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  Future<void> _openBrandForm([AdminBrandModel? brand]) async {
    final result = await showDialog<_BrandFormResult>(
      context: context,
      builder: (_) => _BrandFormDialog(brand: brand),
    );
    if (result == null) {
      return;
    }

    final success = await _presenter.saveBrand(
      id: brand?.id,
      name: result.name,
      description: result.description,
      logo: result.logo,
      isActive: result.isActive,
    );
    if (!mounted) {
      return;
    }
    _showSubmitResult(
      success,
      brand == null ? 'Đã thêm thương hiệu.' : 'Đã cập nhật thương hiệu.',
    );
  }

  Future<void> _deleteBrand(AdminBrandModel brand) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        title: 'Xóa thương hiệu?',
        message: 'Bạn có chắc muốn xóa "${brand.name}" không?',
      ),
    );
    if (confirmed != true) {
      return;
    }

    final success = await _presenter.deleteBrand(brand.id);
    if (!mounted) {
      return;
    }
    _showSubmitResult(success, 'Đã xóa thương hiệu.');
  }

  void _showSubmitResult(bool success, String successMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? successMessage
              : (_presenter.errorMessage ?? 'Thao tác chưa thành công.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _presenter.loadBrands,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm thương hiệu',
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: _presenter.isSubmitting ? null : () => _openBrandForm(),
        child: _presenter.isSubmitting
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildBody() {
    if (_presenter.isLoading && _presenter.brands.isEmpty) {
      return const AppLoadingState(title: 'Đang tải thương hiệu');
    }
    if (_presenter.errorMessage != null && _presenter.brands.isEmpty) {
      return AppErrorState(
        title: 'Không tải được thương hiệu',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadBrands,
      );
    }

    final brands = _filteredBrands;
    return AbsolutePersistentLayout(
      title: 'Quản lý thương hiệu',
      subtitle: 'Quản lý nhận diện và trạng thái thương hiệu sản phẩm.',
      icon: Icons.verified_outlined,
      trailing: _CountBadge(count: _presenter.brands.length),
      filterAndSearchZone: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search_rounded),
          hintText: 'Tìm kiếm thương hiệu...',
        ),
      ),
      dynamicContent: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
        children: [
          if (brands.isEmpty)
            PremiumEmptyState(
              icon: Icons.verified_outlined,
              title: _presenter.brands.isEmpty
                  ? 'Chưa có thương hiệu'
                  : 'Không tìm thấy thương hiệu',
              message: _presenter.brands.isEmpty
                  ? 'Nhấn nút + để tạo thương hiệu đầu tiên.'
                  : 'Hãy thử một từ khóa tìm kiếm khác.',
              actionLabel: _presenter.brands.isEmpty
                  ? 'Thêm mới ngay'
                  : 'Xóa tìm kiếm',
              actionIcon: _presenter.brands.isEmpty
                  ? Icons.add_rounded
                  : Icons.filter_alt_off_outlined,
              onAction: _presenter.brands.isEmpty
                  ? () => _openBrandForm()
                  : () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
            )
          else
            ...brands.map(
              (brand) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _BrandTile(
                  brand: brand,
                  onEdit: () => _openBrandForm(brand),
                  onDelete: () => _deleteBrand(brand),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
