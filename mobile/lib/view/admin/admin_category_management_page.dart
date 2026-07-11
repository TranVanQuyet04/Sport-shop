import 'package:flutter/material.dart';

import '../../presenter/admin/admin_catalog_presenter.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

part 'admin_category_management_page_parts/category_form_dialog.dart';
part 'admin_category_management_page_parts/category_tile_and_dialogs.dart';

class AdminCategoryManagementPage extends StatefulWidget {
  const AdminCategoryManagementPage({super.key});

  @override
  State<AdminCategoryManagementPage> createState() =>
      _AdminCategoryManagementPageState();
}

class _AdminCategoryManagementPageState
    extends State<AdminCategoryManagementPage> {
  late final AdminCatalogPresenter _presenter = AdminCatalogPresenter(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<AdminCategoryModel> get _filteredCategories {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _presenter.categories;
    }
    return _presenter.categories.where((category) {
      return category.name.toLowerCase().contains(query) ||
          category.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadCategories();
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

  Future<void> _openCategoryForm([AdminCategoryModel? category]) async {
    final result = await showDialog<_CategoryFormResult>(
      context: context,
      builder: (_) => _CategoryFormDialog(
        category: category,
        categories: _presenter.categories,
      ),
    );
    if (result == null) {
      return;
    }

    final success = await _presenter.saveCategory(
      id: category?.id,
      name: result.name,
      description: result.description,
      parentId: result.parentId,
    );
    if (!mounted) {
      return;
    }
    _showSubmitResult(
      success,
      category == null ? 'Đã thêm danh mục.' : 'Đã cập nhật danh mục.',
    );
  }

  Future<void> _deleteCategory(AdminCategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        title: 'Xóa danh mục?',
        message: 'Bạn có chắc muốn xóa "${category.name}" không?',
      ),
    );
    if (confirmed != true) {
      return;
    }

    final success = await _presenter.deleteCategory(category.id);
    if (!mounted) {
      return;
    }
    _showSubmitResult(success, 'Đã xóa danh mục.');
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
        onRefresh: _presenter.loadCategories,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm danh mục',
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: _presenter.isSubmitting ? null : () => _openCategoryForm(),
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
    if (_presenter.isLoading && _presenter.categories.isEmpty) {
      return const AppLoadingState(title: 'Đang tải danh mục');
    }
    if (_presenter.errorMessage != null && _presenter.categories.isEmpty) {
      return AppErrorState(
        title: 'Không tải được danh mục',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadCategories,
      );
    }

    final categories = _filteredCategories;
    return AbsolutePersistentLayout(
      title: 'Quản lý danh mục',
      subtitle: 'Tổ chức cấu trúc phân loại sản phẩm trong cửa hàng.',
      icon: Icons.category_outlined,
      trailing: _CountBadge(count: _presenter.categories.length),
      filterAndSearchZone: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search_rounded),
          hintText: 'Tìm kiếm danh mục...',
        ),
      ),
      dynamicContent: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
        children: [
          if (categories.isEmpty)
            PremiumEmptyState(
              icon: Icons.category_outlined,
              title: _presenter.categories.isEmpty
                  ? 'Chưa có danh mục'
                  : 'Không tìm thấy danh mục',
              message: _presenter.categories.isEmpty
                  ? 'Nhấn nút + để tạo danh mục đầu tiên.'
                  : 'Hãy thử một từ khóa tìm kiếm khác.',
              actionLabel: _presenter.categories.isEmpty
                  ? 'Thêm mới ngay'
                  : 'Xóa tìm kiếm',
              actionIcon: _presenter.categories.isEmpty
                  ? Icons.add_rounded
                  : Icons.filter_alt_off_outlined,
              onAction: _presenter.categories.isEmpty
                  ? () => _openCategoryForm()
                  : () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
            )
          else
            ...categories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _CategoryTile(
                  category: category,
                  parentName: _parentNameFor(category),
                  onEdit: () => _openCategoryForm(category),
                  onDelete: () => _deleteCategory(category),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _parentNameFor(AdminCategoryModel category) {
    if (category.parentId.isEmpty) {
      return null;
    }
    for (final parent in _presenter.categories) {
      if (parent.id == category.parentId) {
        return parent.name;
      }
    }
    return null;
  }
}
