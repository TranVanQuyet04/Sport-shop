import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';

class AdminStaffDetailPage extends StatefulWidget {
  const AdminStaffDetailPage({super.key, required this.staffId});

  final String staffId;

  @override
  State<AdminStaffDetailPage> createState() => _AdminStaffDetailPageState();
}

class _AdminStaffDetailPageState extends State<AdminStaffDetailPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadUserDetail(widget.staffId);
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

  Future<void> _toggleStatus(bool status) async {
    final user = _controller.selectedUser;
    if (user == null) {
      return;
    }
    final success = await _controller.saveUser(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      password: '',
      confirmPassword: '',
      roleName: user.roleName,
      status: status,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã cập nhật trạng thái nhân viên.'
              : (_controller.errorMessage ?? 'Chưa cập nhật được trạng thái.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _controller.selectedUser;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('CHI TIẾT NHÂN VIÊN'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _controller.isLoading
                ? null
                : () => _controller.loadUserDetail(widget.staffId),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _controller.loadUserDetail(widget.staffId),
        child: _buildBody(user),
      ),
      bottomNavigationBar: user == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'LÀM MỚI MẬT KHẨU',
                        variant: AppButtonVariant.outline,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Backend chưa có API reset mật khẩu nội bộ.',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        label: _controller.isSubmitting
                            ? 'ĐANG LƯU...'
                            : 'ĐỔI TRẠNG THÁI',
                        variant: AppButtonVariant.secondary,
                        icon: Icons.toggle_on,
                        onPressed: _controller.isSubmitting
                            ? null
                            : () => _toggleStatus(!user.status),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBody(AdminUserModel? user) {
    if (_controller.isLoading && user == null) {
      return const AppLoadingState(title: 'Đang tải nhân viên');
    }
    if (_controller.errorMessage != null && user == null) {
      return AppErrorState(
        title: 'Không tải được nhân viên',
        message: _controller.errorMessage!,
        onAction: () => _controller.loadUserDetail(widget.staffId),
      );
    }
    if (user == null) {
      return const AppEmptyState(title: 'Không có dữ liệu nhân viên');
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Stack(
            children: [
              const CircleAvatar(
                radius: 82,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 90),
              ),
              Positioned(
                right: 4,
                bottom: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: user.status
                        ? AppColors.success
                        : AppColors.textSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(fontSize: 38),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          user.roleName,
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Trạng thái làm việc',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Switch(
                  value: user.status,
                  onChanged: _controller.isSubmitting ? null : _toggleStatus,
                  activeThumbColor: AppColors.secondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['THÔNG TIN', 'LỊCH LÀM VIỆC', 'HIỆU SUẤT']
              .map(
                (label) => Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(height: 3, width: 120, color: AppColors.primary),
        const SizedBox(height: AppSpacing.xl),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                _InfoRow(label: 'MÃ NHÂN VIÊN', value: user.id),
                const Divider(height: AppSpacing.xl),
                _InfoRow(label: 'EMAIL', value: user.email),
                const Divider(height: AppSpacing.xl),
                _InfoRow(
                  label: 'SỐ ĐIỆN THOẠI',
                  value: user.phoneNumber.isEmpty
                      ? 'Chưa cập nhật'
                      : user.phoneNumber,
                ),
                const Divider(height: AppSpacing.xl),
                _InfoRow(
                  label: 'TRẠNG THÁI',
                  value: user.status ? 'Hoạt động' : 'Vô hiệu',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
