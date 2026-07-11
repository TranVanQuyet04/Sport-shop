import 'package:flutter/material.dart';

import '../../presenter/admin/admin_catalog_presenter.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/common/backend_models.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

part 'admin_sports_page_parts/sport_card_widgets.dart';
part 'admin_sports_page_parts/sport_form_dialog.dart';
part 'admin_sports_page_parts/sport_skeleton_widgets.dart';

class AdminSportsPage extends StatefulWidget {
  const AdminSportsPage({super.key});

  @override
  State<AdminSportsPage> createState() => _AdminSportsPageState();
}

class _AdminSportsPageState extends State<AdminSportsPage> {
  late final AdminCatalogPresenter _presenter = AdminCatalogPresenter(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onChanged);
    _presenter.loadSports();
  }

  @override
  void dispose() {
    _presenter
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openForm([SportModel? sport]) async {
    final result = await showDialog<_SportFormResult>(
      context: context,
      builder: (_) => _SportFormDialog(sport: sport),
    );
    if (result == null) {
      return;
    }

    final success = await _presenter.saveSport(
      id: sport?.id,
      name: result.name,
      description: result.description,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã lưu môn thể thao.'
              : (_presenter.errorMessage ?? 'Không thể lưu môn thể thao.'),
        ),
      ),
    );
  }

  Future<void> _delete(SportModel sport) async {
    final success = await _presenter.deleteSport(sport.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã xóa môn thể thao.'
              : (_presenter.errorMessage ?? 'Không thể xóa môn thể thao.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý môn thể thao',
          style: AppTextStyles.subtitle.copyWith(
            color: const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _presenter.isLoading ? null : _presenter.loadSports,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AdminColors.primary,
        onRefresh: _presenter.loadSports,
        child: _buildBody(),
      ),
      floatingActionButton: _PremiumAddButton(
        enabled: !_presenter.isSubmitting,
        onPressed: () => _openForm(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildBody() {
    if (_presenter.isLoading && _presenter.sports.isEmpty) {
      return const _SportSkeletonList();
    }
    if (_presenter.errorMessage != null && _presenter.sports.isEmpty) {
      return AppErrorState(
        title: 'Không tải được môn thể thao',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadSports,
      );
    }
    if (_presenter.sports.isEmpty) {
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        104,
      ),
      itemCount: _presenter.sports.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final sport = _presenter.sports[index];
        return _SportCard(
          sport: sport,
          onEdit: () => _openForm(sport),
          onDelete: () => _delete(sport),
        );
      },
    );
  }
}

// Harness dynamic sport icon mapping markers: sports_soccer, sports_tennis, directions_run, pool_outlined
