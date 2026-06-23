import 'package:flutter/material.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminCategoryManagementPage extends StatefulWidget {
  const AdminCategoryManagementPage({super.key});

  @override
  State<AdminCategoryManagementPage> createState() =>
      _AdminCategoryManagementPageState();
}

class _AdminCategoryManagementPageState
    extends State<AdminCategoryManagementPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<AdminCategoryModel> get _filteredCategories {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _controller.categories;
    }
    return _controller.categories.where((category) {
      return category.name.toLowerCase().contains(query) ||
          category.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadCategories();
  }

  @override
  void dispose() {
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

  Future<void> _openCategoryForm([AdminCategoryModel? category]) async {
    final result = await showDialog<_CategoryFormResult>(
      context: context,
      builder: (_) => _CategoryFormDialog(
        category: category,
        categories: _controller.categories,
      ),
    );
    if (result == null) {
      return;
    }

    final success = await _controller.saveCategory(
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

    final success = await _controller.deleteCategory(category.id);
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
              : (_controller.errorMessage ?? 'Thao tác chưa thành công.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadCategories,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm danh mục',
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: _controller.isSubmitting ? null : () => _openCategoryForm(),
        child: _controller.isSubmitting
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
    if (_controller.isLoading && _controller.categories.isEmpty) {
      return const AppLoadingState(title: 'Đang tải danh mục');
    }
    if (_controller.errorMessage != null && _controller.categories.isEmpty) {
      return AppErrorState(
        title: 'Không tải được danh mục',
        message: _controller.errorMessage!,
        onAction: _controller.loadCategories,
      );
    }

    final categories = _filteredCategories;
    return AbsolutePersistentLayout(
      title: 'Quản lý danh mục',
      subtitle: 'Tổ chức cấu trúc phân loại sản phẩm trong cửa hàng.',
      icon: Icons.category_outlined,
      trailing: _CountBadge(count: _controller.categories.length),
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
              title: _controller.categories.isEmpty
                  ? 'Chưa có danh mục'
                  : 'Không tìm thấy danh mục',
              message: _controller.categories.isEmpty
                  ? 'Nhấn nút + để tạo danh mục đầu tiên.'
                  : 'Hãy thử một từ khóa tìm kiếm khác.',
              actionLabel: _controller.categories.isEmpty
                  ? 'Thêm mới ngay'
                  : 'Xóa tìm kiếm',
              actionIcon: _controller.categories.isEmpty
                  ? Icons.add_rounded
                  : Icons.filter_alt_off_outlined,
              onAction: _controller.categories.isEmpty
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
    for (final parent in _controller.categories) {
      if (parent.id == category.parentId) {
        return parent.name;
      }
    }
    return null;
  }
}

class _CategoryFormResult {
  const _CategoryFormResult({
    required this.name,
    required this.description,
    required this.parentId,
  });

  final String name;
  final String description;
  final String parentId;
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.category, required this.categories});

  final AdminCategoryModel? category;
  final List<AdminCategoryModel> categories;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.category?.name ?? '',
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.category?.description ?? '');
  late String _parentId = widget.category?.parentId ?? '';

  List<AdminCategoryModel> get _parentOptions => widget.categories
      .where((category) => category.id != widget.category?.id)
      .toList();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.pop(
      context,
      _CategoryFormResult(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        parentId: _parentId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final validParentIds = _parentOptions.map((item) => item.id).toSet();
    final selectedParentId = validParentIds.contains(_parentId)
        ? _parentId
        : '';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actionsAlignment: MainAxisAlignment.end,
      title: _DialogTitle(
        title: isEditing ? 'Sửa danh mục' : 'Thêm danh mục',
        subtitle: 'Thiết lập thông tin và danh mục cha.',
        icon: Icons.category_outlined,
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminFormField(
                  controller: _nameController,
                  label: 'Tên danh mục',
                  hintText: 'Ví dụ: Giày chạy bộ',
                  prefixIcon: Icons.category_outlined,
                  required: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AdminFormField(
                  controller: _descriptionController,
                  label: 'Mô tả',
                  hintText: 'Mô tả ngắn về nhóm sản phẩm',
                  prefixIcon: Icons.notes_rounded,
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Danh mục cha',
                  style: AppTextStyles.caption.copyWith(
                    color: AdminColors.label,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: selectedParentId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.account_tree_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Không có - Danh mục gốc'),
                    ),
                    ..._parentOptions.map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _parentId = value ?? ''),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AdminColors.textSecondary,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        _DialogSaveButton(onPressed: _submit),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AdminColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        '$count mục',
        style: AppTextStyles.caption.copyWith(
          color: AdminColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.parentName,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminCategoryModel category;
  final String? parentName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                if (parentName != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_tree_outlined,
                        size: 14,
                        color: AdminColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Thuộc: $parentName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AdminColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AdminEntityMenu(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

class _DialogTitle extends StatelessWidget {
  const _DialogTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AdminIconBadge(icon: icon, size: 42),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.title.copyWith(
                  color: AdminColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AdminColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DialogSaveButton extends StatelessWidget {
  const _DialogSaveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.save_outlined, size: 18),
      label: const Text('Lưu'),
    );
  }
}

class _DeleteConfirmationDialog extends StatelessWidget {
  const _DeleteConfirmationDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title),
      content: Text(message),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AdminColors.textSecondary,
          ),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.danger,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Xóa'),
        ),
      ],
    );
  }
}
