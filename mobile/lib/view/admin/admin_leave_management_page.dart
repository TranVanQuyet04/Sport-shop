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

class AdminLeaveManagementPage extends StatefulWidget {
  const AdminLeaveManagementPage({super.key});

  @override
  State<AdminLeaveManagementPage> createState() =>
      _AdminLeaveManagementPageState();
}

class _AdminLeaveManagementPageState extends State<AdminLeaveManagementPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  final Set<String> _approvedIds = {};
  final Set<String> _rejectedIds = {};

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

  List<_LeaveRequestData> get _requests {
    final reasons = [
      'Nghỉ ốm, cần đi khám và nghỉ ngơi.',
      'Việc gia đình riêng, cần xử lý trong ngày.',
      'Xin nghỉ phép cá nhân theo lịch đã báo trước.',
    ];
    return _staffUsers.take(6).toList().asMap().entries.map((entry) {
      final user = entry.value;
      final date = DateTime.now().add(Duration(days: entry.key + 1));
      return _LeaveRequestData(
        id: user.id,
        name: user.fullName,
        role: user.roleName,
        date: date,
        days: entry.key.isEven ? 1 : 2,
        reason: reasons[entry.key % reasons.length],
      );
    }).toList();
  }

  Future<void> _decideLeave(_LeaveRequestData request, bool approve) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Duyệt nghỉ phép?' : 'Từ chối nghỉ phép?'),
        content: Text(
          '${request.name} xin nghỉ ${request.days} ngày. Xác nhận thao tác này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(approve ? 'Duyệt' : 'Từ chối'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    setState(() {
      if (approve) {
        _approvedIds.add(request.id);
        _rejectedIds.remove(request.id);
      } else {
        _rejectedIds.add(request.id);
        _approvedIds.remove(request.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final requests = _requests;
    final pendingRequests = requests
        .where(
          (request) =>
              !_approvedIds.contains(request.id) &&
              !_rejectedIds.contains(request.id),
        )
        .toList();
    final decidedRequests = requests
        .where(
          (request) =>
              _approvedIds.contains(request.id) ||
              _rejectedIds.contains(request.id),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nghỉ phép'),
        actions: [
          IconButton(
            onPressed: _controller.isLoading ? null : _controller.loadUsers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadUsers,
        child: _buildBody(pendingRequests, decidedRequests),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody(
    List<_LeaveRequestData> pendingRequests,
    List<_LeaveRequestData> decidedRequests,
  ) {
    if (_controller.isLoading && _staffUsers.isEmpty) {
      return const AppLoadingState(title: 'Đang tải nghỉ phép');
    }
    if (_controller.errorMessage != null && _staffUsers.isEmpty) {
      return AppErrorState(
        title: 'Không tải được nhân viên',
        message: _controller.errorMessage!,
        onAction: _controller.loadUsers,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const _Title(),
        const SizedBox(height: AppSpacing.xl),
        if (_controller.errorMessage != null) ...[
          _LeaveDemoBanner(
            message: _controller.errorMessage!,
            onRefresh: _controller.loadUsers,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        _CalendarCard(requests: _requests),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Đang chờ duyệt',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            Chip(label: Text('${pendingRequests.length} yêu cầu')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (pendingRequests.isEmpty)
          const AppEmptyState(
            title: 'Không có yêu cầu chờ duyệt',
            message: 'Các yêu cầu nghỉ phép mới sẽ xuất hiện tại đây.',
          )
        else
          ...pendingRequests.map(
            (request) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _LeaveRequest(
                request: request,
                onApprove: () => _decideLeave(request, true),
                onReject: () => _decideLeave(request, false),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        const Text(
          'Hoạt động gần đây',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        if (decidedRequests.isEmpty)
          Text(
            'Chưa có yêu cầu nào được duyệt hoặc từ chối trong phiên này.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          )
        else
          ...decidedRequests.map(
            (request) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _RecentLeave(
                name: request.name,
                status: _approvedIds.contains(request.id)
                    ? 'Đã duyệt - ${request.dateLabel}'
                    : 'Từ chối - ${request.dateLabel}',
                ok: _approvedIds.contains(request.id),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Ghi chú: backend chưa có API nghỉ phép, nên trạng thái duyệt/từ chối hiện chỉ lưu tạm trên màn hình.',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _LeaveDemoBanner extends StatelessWidget {
  const _LeaveDemoBanner({required this.message, required this.onRefresh});

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

class _LeaveRequestData {
  const _LeaveRequestData({
    required this.id,
    required this.name,
    required this.role,
    required this.date,
    required this.days,
    required this.reason,
  });

  final String id;
  final String name;
  final String role;
  final DateTime date;
  final int days;
  final String reason;

  String get dateLabel => '${date.day}/${date.month}';
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quản lý nghỉ phép',
          style: AppTextStyles.display.copyWith(fontSize: 34),
        ),
        Text(
          'Tháng ${now.month}, ${now.year}',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({required this.requests});

  final List<_LeaveRequestData> requests;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(28, (index) => now.add(Duration(days: index)));
    final requestDays = requests.map((request) => request.date.day).toSet();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Tháng ${now.month}', style: AppTextStyles.title),
                const Spacer(),
                const Icon(Icons.chevron_left),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final active = requestDays.contains(day.day);
                return Center(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: active ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaveRequest extends StatelessWidget {
  const _LeaveRequest({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final _LeaveRequestData request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.name, style: AppTextStyles.subtitle),
                      Text(request.role),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(request.dateLabel, style: AppTextStyles.subtitle),
                    Text(
                      '${request.days} ngày',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Lý do: ${request.reason}'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Từ chối',
                    variant: AppButtonVariant.outline,
                    onPressed: onReject,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Duyệt',
                    variant: AppButtonVariant.secondary,
                    onPressed: onApprove,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentLeave extends StatelessWidget {
  const _RecentLeave({
    required this.name,
    required this.status,
    required this.ok,
  });

  final String name;
  final String status;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: ok ? AppColors.success : AppColors.secondary),
      ),
      child: ListTile(
        leading: Icon(
          ok ? Icons.check_circle_outline : Icons.cancel_outlined,
          color: ok ? AppColors.success : AppColors.secondary,
        ),
        title: Text(name, style: AppTextStyles.subtitle),
        subtitle: Text(status),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
