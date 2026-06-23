import 'package:flutter/material.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/collection_model.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminCollectionsPage extends StatefulWidget {
  const AdminCollectionsPage({super.key});

  @override
  State<AdminCollectionsPage> createState() => _AdminCollectionsPageState();
}

class _AdminCollectionsPageState extends State<AdminCollectionsPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _controller.loadCollections();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openForm() async {
    final result = await showDialog<_CollectionFormResult>(
      context: context,
      builder: (_) => const _CollectionFormDialog(),
    );
    if (result == null) return;
    final success = await _controller.createCollection(
      name: result.name,
      slug: result.slug,
      description: result.description,
      imageUrl: result.imageUrl,
      type: result.type,
      isActive: result.isActive,
      startDate: result.startDate,
      endDate: result.endDate,
      variantIds: result.variantIds,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đã tạo bộ sưu tập.' : (_controller.errorMessage ?? ''),
        ),
      ),
    );
  }

  Future<void> _delete(CollectionModel collection) async {
    final success = await _controller.deleteCollection(collection.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đã xóa bộ sưu tập.' : (_controller.errorMessage ?? ''),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Bộ sưu tập'),
      actions: [
        IconButton(
          onPressed: _controller.isLoading ? null : _controller.loadCollections,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _controller.loadCollections,
      child: _buildBody(),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _controller.isSubmitting ? null : _openForm,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    ),
    bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
  );

  Widget _buildBody() {
    if (_controller.isLoading && _controller.collections.isEmpty) {
      return const AppLoadingState(title: 'Đang tải bộ sưu tập');
    }
    if (_controller.errorMessage != null && _controller.collections.isEmpty) {
      return AppErrorState(
        title: 'Không tải được bộ sưu tập',
        message: _controller.errorMessage!,
        onAction: _controller.loadCollections,
      );
    }
    if (_controller.collections.isEmpty) {
      return PremiumEmptyState(
        icon: Icons.collections_bookmark_outlined,
        title: 'Chưa có bộ sưu tập',
        message:
            'Tạo bộ sưu tập để gom sản phẩm theo mùa, chiến dịch hoặc nhóm bán chạy.',
        actionLabel: 'Thêm mới ngay',
        onAction: _openForm,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _controller.collections.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final collection = _controller.collections[index];
        return AdminOutlinedSurface(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const AdminIconBadge(icon: Icons.collections_bookmark_outlined),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${collection.type} • ${collection.variants.length} biến thể',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AdminEntityMenu(
                onEdit: _openForm,
                onDelete: () => _delete(collection),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CollectionFormResult {
  const _CollectionFormResult({
    required this.name,
    required this.slug,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.variantIds,
  });

  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final String type;
  final bool isActive;
  final String? startDate;
  final String? endDate;
  final List<String> variantIds;
}

class _CollectionFormDialog extends StatefulWidget {
  const _CollectionFormDialog();

  @override
  State<_CollectionFormDialog> createState() => _CollectionFormDialogState();
}

class _CollectionFormDialogState extends State<_CollectionFormDialog> {
  final _name = TextEditingController();
  final _slug = TextEditingController();
  final _description = TextEditingController();
  final _imageUrl = TextEditingController();
  final _type = TextEditingController(text: 'SEASONAL');
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();
  final _variantIds = TextEditingController();
  bool _isActive = true;

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    _description.dispose();
    _imageUrl.dispose();
    _type.dispose();
    _startDate.dispose();
    _endDate.dispose();
    _variantIds.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      _CollectionFormResult(
        name: _name.text.trim(),
        slug: _slug.text.trim(),
        description: _description.text.trim(),
        imageUrl: _imageUrl.text.trim(),
        type: _type.text.trim(),
        isActive: _isActive,
        startDate: _startDate.text.trim().isEmpty
            ? null
            : _startDate.text.trim(),
        endDate: _endDate.text.trim().isEmpty ? null : _endDate.text.trim(),
        variantIds: _variantIds.text
            .split(',')
            .map((id) => id.trim())
            .where((id) => id.isNotEmpty)
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Text(
      'Thêm bộ sưu tập',
      style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800),
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdminFormField(controller: _name, label: 'Tên', required: true),
          const SizedBox(height: AppSpacing.md),
          AdminFormField(controller: _slug, label: 'Slug'),
          const SizedBox(height: AppSpacing.md),
          AdminFormField(controller: _description, label: 'Mô tả', maxLines: 3),
          const SizedBox(height: AppSpacing.md),
          AdminFormField(controller: _imageUrl, label: 'URL hình ảnh'),
          const SizedBox(height: AppSpacing.md),
          AdminFormField(controller: _type, label: 'Loại'),
          const SizedBox(height: AppSpacing.md),
          AdminFormField(
            controller: _startDate,
            label: 'Ngày bắt đầu',
            hintText: 'yyyy-MM-dd',
          ),
          const SizedBox(height: AppSpacing.md),
          AdminFormField(
            controller: _endDate,
            label: 'Ngày kết thúc',
            hintText: 'yyyy-MM-dd',
          ),
          const SizedBox(height: AppSpacing.md),
          AdminFormField(
            controller: _variantIds,
            label: 'ID biến thể',
            hintText: 'Cách nhau bằng dấu phẩy',
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _isActive,
            title: const Text('Đang hoạt động'),
            onChanged: (value) => setState(() => _isActive = value),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        onPressed: _submit,
        child: const Text('Lưu'),
      ),
    ],
  );
}
