import 'package:flutter/material.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminBrandManagementPage extends StatefulWidget {
  const AdminBrandManagementPage({super.key});

  @override
  State<AdminBrandManagementPage> createState() =>
      _AdminBrandManagementPageState();
}

class _AdminBrandManagementPageState extends State<AdminBrandManagementPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadBrands();
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

  Future<void> _openBrandForm([AdminBrandModel? brand]) async {
    final result = await showDialog<_BrandFormResult>(
      context: context,
      builder: (_) => _BrandFormDialog(brand: brand),
    );
    if (result == null) {
      return;
    }

    final success = await _controller.saveBrand(
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
      builder: (context) => AlertDialog(
        title: const Text('Xóa thương hiệu?'),
        content: Text('Bạn có chắc muốn xóa "${brand.name}" không?'),
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

    final success = await _controller.deleteBrand(brand.id);
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
        onRefresh: _controller.loadBrands,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: _controller.isSubmitting ? null : () => _openBrandForm(),
        child: _controller.isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.brands.isEmpty) {
      return const AppLoadingState(title: 'Đang tải thương hiệu');
    }
    if (_controller.errorMessage != null && _controller.brands.isEmpty) {
      return AppErrorState(
        title: 'Không tải được thương hiệu',
        message: _controller.errorMessage!,
        onAction: _controller.loadBrands,
      );
    }
    if (_controller.brands.isEmpty) {
      return const AppEmptyState(title: 'Chưa có thương hiệu');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _controller.brands.length + 2,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _Header();
        }
        if (index == 1) {
          return const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm kiếm thương hiệu...',
            ),
          );
        }
        final brand = _controller.brands[index - 2];
        return _BrandTile(
          brand: brand,
          onEdit: () => _openBrandForm(brand),
          onDelete: () => _deleteBrand(brand),
        );
      },
    );
  }
}

class _BrandFormResult {
  const _BrandFormResult({
    required this.name,
    required this.description,
    required this.logo,
    required this.isActive,
  });

  final String name;
  final String description;
  final String logo;
  final bool isActive;
}

class _BrandFormDialog extends StatefulWidget {
  const _BrandFormDialog({this.brand});

  final AdminBrandModel? brand;

  @override
  State<_BrandFormDialog> createState() => _BrandFormDialogState();
}

class _BrandFormDialogState extends State<_BrandFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.brand?.name ?? '',
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.brand?.description ?? '');
  late final TextEditingController _logoController = TextEditingController(
    text: widget.brand?.logo ?? '',
  );
  late bool _isActive = widget.brand?.isActive ?? true;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.pop(
      context,
      _BrandFormResult(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        logo: _logoController.text.trim(),
        isActive: _isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.brand != null;
    return AlertDialog(
      title: Text(isEditing ? 'Sửa thương hiệu' : 'Thêm thương hiệu'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên thương hiệu'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên thương hiệu.';
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
                controller: _logoController,
                decoration: const InputDecoration(
                  labelText: 'Logo URL',
                  hintText: 'Có thể để trống',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                title: const Text('Đang hoạt động'),
                onChanged: (value) => setState(() => _isActive = value),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Quản lý thương hiệu',
        style: AppTextStyles.display.copyWith(fontSize: 36),
      ),
      Text(
        'Thêm, sửa hoặc xóa thương hiệu sản phẩm.',
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
      ),
    ],
  );
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({
    required this.brand,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminBrandModel brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.xl),
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      minVerticalPadding: AppSpacing.lg,
      leading: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: Text(
            brand.name.isEmpty ? '?' : brand.name.characters.first,
            style: AppTextStyles.title,
          ),
        ),
      ),
      title: Text(
        brand.name,
        style: AppTextStyles.display.copyWith(fontSize: 28),
      ),
      subtitle: Text(
        brand.description.isEmpty
            ? (brand.isActive ? 'Đang hoạt động' : 'Đã tắt')
            : brand.description,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
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
