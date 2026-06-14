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
  _StaffDetailTab _selectedTab = _StaffDetailTab.info;

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
          onPressed: _closePage,
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
          children: _StaffDetailTab.values
              .map(
                (tab) => Expanded(
                  child: _StaffTabButton(
                    label: tab.label,
                    selected: _selectedTab == tab,
                    onTap: () => setState(() => _selectedTab = tab),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: _selectedTab.alignment,
          child: FractionallySizedBox(
            widthFactor: 1 / _StaffDetailTab.values.length,
            child: Container(height: 3, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _StaffTabContent(tab: _selectedTab, user: user),
      ],
    );
  }
}

enum _StaffDetailTab {
  info('THÔNG TIN', Alignment.centerLeft),
  schedule('LỊCH LÀM VIỆC', Alignment.centerRight);

  const _StaffDetailTab(this.label, this.alignment);

  final String label;
  final Alignment alignment;
}

class _StaffTabButton extends StatelessWidget {
  const _StaffTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _StaffTabContent extends StatelessWidget {
  const _StaffTabContent({required this.tab, required this.user});

  final _StaffDetailTab tab;
  final AdminUserModel user;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      _StaffDetailTab.info => _InfoCard(user: user),
      _StaffDetailTab.schedule => _ScheduleCard(roleName: user.roleName),
    };
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.user});

  final AdminUserModel user;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
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
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.roleName});

  final String roleName;

  @override
  Widget build(BuildContext context) {
    final shifts = roleName == 'DELIVERY_STAFF'
        ? const [
            _ShiftItem('Thứ 2', '08:00 - 12:00', 'Giao khu Quận 1, Quận 3'),
            _ShiftItem('Thứ 4', '13:00 - 18:00', 'Nhận hàng và giao nội thành'),
            _ShiftItem('Thứ 7', '09:00 - 16:00', 'Ca cuối tuần'),
          ]
        : const [
            _ShiftItem('Thứ 2', '08:00 - 12:00', 'Xác nhận đơn hàng'),
            _ShiftItem('Thứ 3', '13:00 - 18:00', 'Đóng gói và kiểm hàng'),
            _ShiftItem('Thứ 6', '08:00 - 17:00', 'Bàn giao cho shipper'),
          ];

    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lịch làm việc tuần này', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Dữ liệu mẫu dùng để admin xem/xếp ca. Khi nối backend sẽ lấy từ API ca làm việc.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...shifts.map(
            (shift) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _ShiftRow(item: shift),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: child,
      ),
    );
  }
}

class _ShiftItem {
  const _ShiftItem(this.day, this.time, this.task);

  final String day;
  final String time;
  final String task;
}

class _ShiftRow extends StatelessWidget {
  const _ShiftRow({required this.item});

  final _ShiftItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: Text(
              item.day,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.time, style: AppTextStyles.subtitle),
              Text(item.task, style: AppTextStyles.caption),
            ],
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
