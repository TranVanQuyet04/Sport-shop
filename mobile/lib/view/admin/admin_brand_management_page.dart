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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<AdminBrandModel> get _filteredBrands {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _controller.brands;
    }
    return _controller.brands.where((brand) {
      return brand.name.toLowerCase().contains(query) ||
          brand.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadBrands();
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
      builder: (context) => _DeleteConfirmationDialog(
        title: 'Xóa thương hiệu?',
        message: 'Bạn có chắc muốn xóa "${brand.name}" không?',
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
        tooltip: 'Thêm thương hiệu',
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: _controller.isSubmitting ? null : () => _openBrandForm(),
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

    final brands = _filteredBrands;
    return AbsolutePersistentLayout(
      title: 'Quản lý thương hiệu',
      subtitle: 'Quản lý nhận diện và trạng thái thương hiệu sản phẩm.',
      icon: Icons.verified_outlined,
      trailing: _CountBadge(count: _controller.brands.length),
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
              title: _controller.brands.isEmpty
                  ? 'Chưa có thương hiệu'
                  : 'Không tìm thấy thương hiệu',
              message: _controller.brands.isEmpty
                  ? 'Nhấn nút + để tạo thương hiệu đầu tiên.'
                  : 'Hãy thử một từ khóa tìm kiếm khác.',
              actionLabel: _controller.brands.isEmpty
                  ? 'Thêm mới ngay'
                  : 'Xóa tìm kiếm',
              actionIcon: _controller.brands.isEmpty
                  ? Icons.add_rounded
                  : Icons.filter_alt_off_outlined,
              onAction: _controller.brands.isEmpty
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actionsAlignment: MainAxisAlignment.end,
      title: _DialogTitle(
        title: isEditing ? 'Sửa thương hiệu' : 'Thêm thương hiệu',
        subtitle: 'Cập nhật thông tin nhận diện thương hiệu.',
        icon: Icons.verified_outlined,
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminFormField(
                  controller: _nameController,
                  label: 'Tên thương hiệu',
                  hintText: 'Ví dụ: Nike',
                  prefixIcon: Icons.verified_outlined,
                  required: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AdminFormField(
                  controller: _descriptionController,
                  label: 'Mô tả',
                  hintText: 'Mô tả ngắn về thương hiệu',
                  prefixIcon: Icons.notes_rounded,
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpacing.lg),
                AdminFormField(
                  controller: _logoController,
                  label: 'URL logo',
                  hintText: 'https://...',
                  prefixIcon: Icons.image_outlined,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: AdminColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    value: _isActive,
                    activeTrackColor: AdminColors.primary,
                    title: Text(
                      'Đang hoạt động',
                      style: AppTextStyles.body.copyWith(
                        color: AdminColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Cho phép thương hiệu xuất hiện trong danh mục.',
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
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
        '$count hãng',
        style: AppTextStyles.caption.copyWith(
          color: AdminColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    return AdminOutlinedSurface(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _BrandLogo(logoUrl: brand.logo),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        brand.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle.copyWith(
                          color: AdminColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatusPill(isActive: brand.isActive),
                  ],
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
          AdminEntityMenu(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.logoUrl});

  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AdminColors.surfaceMuted,
        border: Border.all(color: AdminColors.inputBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl.trim().isEmpty
          ? const _LogoFallback()
          : Image.network(
              logoUrl,
              fit: BoxFit.contain,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (_, _, _) => const _LogoFallback(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return const Center(
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: AdminColors.textSecondary,
        size: 23,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AdminColors.success : AdminColors.textSecondary;
    final background = isActive
        ? AdminColors.successSoft
        : AdminColors.surfaceMuted;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Hoạt động' : 'Đã tắt',
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
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
