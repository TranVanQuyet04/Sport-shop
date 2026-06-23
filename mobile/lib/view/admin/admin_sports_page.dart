import 'package:flutter/material.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/common/backend_models.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminSportsPage extends StatefulWidget {
  const AdminSportsPage({super.key});

  @override
  State<AdminSportsPage> createState() => _AdminSportsPageState();
}

class _AdminSportsPageState extends State<AdminSportsPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _controller.loadSports();
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

  Future<void> _openForm([SportModel? sport]) async {
    final result = await showDialog<_SportFormResult>(
      context: context,
      builder: (_) => _SportFormDialog(sport: sport),
    );
    if (result == null) return;
    final success = await _controller.saveSport(
      id: sport?.id,
      name: result.name,
      description: result.description,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đã lưu môn thể thao.' : (_controller.errorMessage ?? ''),
        ),
      ),
    );
  }

  Future<void> _delete(SportModel sport) async {
    final success = await _controller.deleteSport(sport.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đã xóa môn thể thao.' : (_controller.errorMessage ?? ''),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Môn thể thao'),
      actions: [
        IconButton(
          onPressed: _controller.isLoading ? null : _controller.loadSports,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _controller.loadSports,
      child: _buildBody(),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _controller.isSubmitting ? null : () => _openForm(),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    ),
    bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
  );

  Widget _buildBody() {
    if (_controller.isLoading && _controller.sports.isEmpty) {
      return const AppLoadingState(title: 'Đang tải môn thể thao');
    }
    if (_controller.errorMessage != null && _controller.sports.isEmpty) {
      return AppErrorState(
        title: 'Không tải được môn thể thao',
        message: _controller.errorMessage!,
        onAction: _controller.loadSports,
      );
    }
    if (_controller.sports.isEmpty) {
      return PremiumEmptyState(
        icon: Icons.sports_basketball_outlined,
        title: 'Chưa có môn thể thao',
        message:
            'Thêm môn thể thao để phân loại sản phẩm và điều hướng mua sắm.',
        actionLabel: 'Thêm mới ngay',
        onAction: () => _openForm(),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _controller.sports.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final sport = _controller.sports[index];
        return AdminOutlinedSurface(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const AdminIconBadge(icon: Icons.sports_basketball_outlined),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sport.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      sport.description.isEmpty
                          ? 'Chưa có mô tả'
                          : sport.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AdminEntityMenu(
                onEdit: () => _openForm(sport),
                onDelete: () => _delete(sport),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SportFormResult {
  const _SportFormResult({required this.name, required this.description});
  final String name;
  final String description;
}

class _SportFormDialog extends StatefulWidget {
  const _SportFormDialog({this.sport});
  final SportModel? sport;

  @override
  State<_SportFormDialog> createState() => _SportFormDialogState();
}

class _SportFormDialogState extends State<_SportFormDialog> {
  late final _name = TextEditingController(text: widget.sport?.name ?? '');
  late final _description = TextEditingController(
    text: widget.sport?.description ?? '',
  );

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Text(
      widget.sport == null ? 'Thêm môn thể thao' : 'Sửa môn thể thao',
      style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800),
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdminFormField(controller: _name, label: 'Tên', required: true),
        const SizedBox(height: AppSpacing.md),
        AdminFormField(controller: _description, label: 'Mô tả', maxLines: 3),
      ],
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
        onPressed: () => Navigator.pop(
          context,
          _SportFormResult(
            name: _name.text.trim(),
            description: _description.text.trim(),
          ),
        ),
        child: const Text('Lưu'),
      ),
    ],
  );
}
