import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../model/admin/admin_lookup_model.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminStaffPage extends StatefulWidget {
  const AdminStaffPage({super.key});

  @override
  State<AdminStaffPage> createState() => _AdminStaffPageState();
}

class _AdminStaffPageState extends State<AdminStaffPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadUsers();
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

  List<AdminUserModel> get _staffUsers {
    return _controller.users.where((user) {
      final role = user.roleName.toUpperCase();
      return role == 'SHOP_STAFF' ||
          role == 'DELIVERY_STAFF' ||
          role == 'SHIPPER' ||
          role == 'STAFF';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadUsers,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: () => context.go(AppRoutes.adminUsers),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody() {
    final staffUsers = _staffUsers;
    if (_controller.isLoading && staffUsers.isEmpty) {
      return const AppLoadingState(title: 'Đang tải nhân viên');
    }
    if (_controller.errorMessage != null && staffUsers.isEmpty) {
      return AppErrorState(
        title: 'Không tải được nhân viên',
        message: _controller.errorMessage!,
        onAction: _controller.loadUsers,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const _StaffHeader(),
        const SizedBox(height: AppSpacing.xl),
        if (_controller.errorMessage != null) ...[
          _StaffDemoBanner(
            message: _controller.errorMessage!,
            onRefresh: _controller.loadUsers,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        const AppTextField(
          label: 'Tìm kiếm',
          prefixIcon: Icons.search,
          hintText: 'Tìm kiếm tên, email hoặc mã nhân viên...',
        ),
        const SizedBox(height: AppSpacing.lg),
        const Row(
          children: [
            _RoleChip(label: 'Bộ lọc', active: true, icon: Icons.filter_list),
            SizedBox(width: AppSpacing.md),
            _RoleChip(label: 'SHOP_STAFF'),
            SizedBox(width: AppSpacing.md),
            _RoleChip(label: 'DELIVERY_STAFF'),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.adminShiftPlanning),
                icon: const Icon(Icons.calendar_month),
                label: const Text('Lịch trực'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.adminStaffPerformance),
                icon: const Icon(Icons.query_stats),
                label: const Text('Hiệu suất'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.adminOrderAssignment),
                icon: const Icon(Icons.assignment_ind),
                label: const Text('Phân công'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.adminLeaveManagement),
                icon: const Icon(Icons.event_busy),
                label: const Text('Nghỉ phép'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        if (staffUsers.isEmpty)
          const AppEmptyState(
            title: 'Chưa có nhân viên',
            message:
                'Tạo user có role SHOP_STAFF hoặc DELIVERY_STAFF để hiển thị tại đây.',
          )
        else
          ...staffUsers.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _StaffCard(
                user: user,
                onTap: () => context.go('/admin/staff/${user.id}'),
              ),
            ),
          ),
      ],
    );
  }
}

class _StaffDemoBanner extends StatelessWidget {
  const _StaffDemoBanner({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.info),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.caption.copyWith(color: AppColors.info),
              ),
            ),
            TextButton(onPressed: onRefresh, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _StaffHeader extends StatelessWidget {
  const _StaffHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quản lý nhân viên',
          style: AppTextStyles.display.copyWith(fontSize: 36),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Danh sách lấy từ tài khoản có vai trò SHOP_STAFF hoặc DELIVERY_STAFF.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, this.active = false, this.icon});

  final String label;
  final bool active;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: active ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.user, this.onTap});

  final AdminUserModel user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDelivery =
        user.roleName.toUpperCase().contains('DELIVERY') ||
        user.roleName.toUpperCase() == 'SHIPPER';
    final accent = isDelivery ? AppColors.primary : AppColors.secondary;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.surfaceMuted,
                foregroundColor: accent,
                child: const Icon(Icons.person, size: 44),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: AppTextStyles.display.copyWith(fontSize: 26),
                    ),
                    Text(
                      user.roleName,
                      style: AppTextStyles.subtitle.copyWith(color: accent),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: user.status
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          user.status ? 'Đang hoạt động' : 'Ngừng hoạt động',
                          style: AppTextStyles.body.copyWith(
                            color: user.status
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
