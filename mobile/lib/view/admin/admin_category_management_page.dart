import 'package:flutter/material.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import 'widgets/admin_bottom_nav.dart';

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

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadCategories();
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

  Future<void> _openCategoryForm([AdminCategoryModel? category]) async {
    final result = await showDialog<_CategoryFormResult>(
      context: context,
      builder: (_) => _CategoryFormDialog(category: category),
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
      builder: (context) => AlertDialog(
        title: const Text('Xóa danh mục?'),
        content: Text('Bạn có chắc muốn xóa "${category.name}" không?'),
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
      appBar: AppBar(
        title: const Text('Quản lý danh mục'),
        actions: [
          IconButton(
            onPressed: _controller.isLoading
                ? null
                : _controller.loadCategories,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadCategories,
        child: _buildBody(),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                label: _controller.isSubmitting
                    ? 'Đang xử lý...'
                    : 'Thêm danh mục mới',
                variant: AppButtonVariant.secondary,
                icon: Icons.add_circle_outline,
                onPressed: _controller.isSubmitting
                    ? null
                    : () => _openCategoryForm(),
              ),
            ),
            const AdminBottomNav(selectedIndex: 1),
          ],
        ),
      ),
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
    if (_controller.categories.isEmpty) {
      return const AppEmptyState(title: 'Chưa có danh mục');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _controller.categories.length + 2,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm kiếm danh mục...',
            ),
          );
        }
        if (index == 1) {
          return const _Title(
            title: 'Quản lý danh mục',
            subtitle: 'Thêm, sửa hoặc xóa danh mục sản phẩm.',
          );
        }
        final category = _controller.categories[index - 2];
        return _CategoryTile(
          category: category,
          onEdit: () => _openCategoryForm(category),
          onDelete: () => _deleteCategory(category),
        );
      },
    );
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
  const _CategoryFormDialog({this.category});

  final AdminCategoryModel? category;

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
  late final TextEditingController _parentIdController = TextEditingController(
    text: widget.category?.parentId ?? '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _parentIdController.dispose();
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
        parentId: _parentIdController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    return AlertDialog(
      title: Text(isEditing ? 'Sửa danh mục' : 'Thêm danh mục'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên danh mục'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên danh mục.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _parentIdController,
                decoration: const InputDecoration(
                  labelText: 'Parent ID',
                  hintText: 'Để trống nếu là danh mục gốc',
                ),
                keyboardType: TextInputType.number,
              ),
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

class _Title extends StatelessWidget {
  const _Title({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyles.display.copyWith(fontSize: 34)),
      Text(
        subtitle,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
      ),
    ],
  );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminCategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.border),
    ),
    child: ListTile(
      minVerticalPadding: AppSpacing.lg,
      leading: const CircleAvatar(child: Icon(Icons.category_outlined)),
      title: Text(category.name, style: AppTextStyles.title),
      subtitle: Text(
        category.description.isEmpty ? 'Không có mô tả' : category.description,
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            onEdit();
          } else if (value == 'delete') {
            onDelete();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Sửa')),
          PopupMenuItem(value: 'delete', child: Text('Xóa')),
        ],
      ),
    ),
  );
}
