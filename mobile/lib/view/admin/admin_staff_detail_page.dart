import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import 'widgets/admin_design_system.dart';

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

  void _closePage() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.adminStaff);
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
              ? 'Đã cập nhật trạng thái nhân sự.'
              : (_controller.errorMessage ??
                    'Không thể cập nhật trạng thái nhân sự.'),
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
          onPressed: _closePage,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Chi tiết nhân sự'),
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
                child: AppButton(
                  label: _controller.isSubmitting
                      ? 'Đang lưu...'
                      : (user.status ? 'Khóa tài khoản' : 'Mở tài khoản'),
                  variant: user.status
                      ? AppButtonVariant.danger
                      : AppButtonVariant.primary,
                  backgroundColor: user.status
                      ? AdminColors.danger
                      : AdminColors.primary,
                  icon: Icons.toggle_on,
                  isLoading: _controller.isSubmitting,
                  onPressed: _controller.isSubmitting
                      ? null
                      : () => _toggleStatus(!user.status),
                ),
              ),
            ),
    );
  }

  Widget _buildBody(AdminUserModel? user) {
    if (_controller.isLoading && user == null) {
      return const AppLoadingState(title: 'Đang tải nhân sự');
    }
    if (_controller.errorMessage != null && user == null) {
      return AppErrorState(
        title: 'Không tải được nhân sự',
        message: _controller.errorMessage!,
        onAction: () => _controller.loadUserDetail(widget.staffId),
      );
    }
    if (user == null) {
      return PremiumEmptyState(
        icon: Icons.person_off_outlined,
        title: 'Không có dữ liệu nhân sự',
        message:
            'Không tìm thấy hồ sơ nhân sự hoặc dữ liệu chưa được tải xong.',
        actionLabel: 'Tải lại dữ liệu',
        onAction: () => _controller.loadUserDetail(widget.staffId),
      );
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
                backgroundColor: AdminColors.primary,
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
                        : AdminColors.textSecondary,
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
            color: AdminColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _PanelCard(
          child: Column(
            children: [
              _InfoRow(label: 'Mã nhân sự', value: user.id),
              const Divider(height: AppSpacing.xl),
              _InfoRow(label: 'Email', value: user.email),
              const Divider(height: AppSpacing.xl),
              _InfoRow(
                label: 'Số điện thoại',
                value: user.phoneNumber.isEmpty
                    ? 'Chưa cập nhật'
                    : user.phoneNumber,
              ),
              const Divider(height: AppSpacing.xl),
              _InfoRow(
                label: 'Trạng thái',
                value: user.status ? 'Đang hoạt động' : 'Đã khóa',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: child,
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
              color: AdminColors.textSecondary,
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
