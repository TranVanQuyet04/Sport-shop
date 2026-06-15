import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminLeaveManagementPage extends StatefulWidget {
  const AdminLeaveManagementPage({super.key});

  @override
  State<AdminLeaveManagementPage> createState() =>
      _AdminLeaveManagementPageState();
}

class _AdminLeaveManagementPageState extends State<AdminLeaveManagementPage> {
  final List<_LeaveRequestData> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  Future<void> _loadLeaves() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await AppDependencies.instance.apiClient.getJson(
        '/admin/leave-requests',
      );
      final data = response['data'];
      final requests = data is List
          ? data
              .whereType<Map>()
              .map((json) => _LeaveRequestData.fromJson(json))
              .toList()
          : <_LeaveRequestData>[];
      if (mounted) {
        setState(() {
          _requests
            ..clear()
            ..addAll(requests);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _decideLeave(_LeaveRequestData request, bool approve) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Duyet nghi phep?' : 'Tu choi nghi phep?'),
        content: Text(
          '${request.name} xin nghi ${request.days} ngay. Xac nhan thao tac nay?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(approve ? 'Duyet' : 'Tu choi'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    try {
      await AppDependencies.instance.apiClient.patchJson(
        '/admin/leave-requests/${request.id}/decision',
        data: {'status': approve ? 'APPROVED' : 'REJECTED'},
      );
      await _loadLeaves();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequests = _requests
        .where((request) => request.status.toUpperCase() == 'PENDING')
        .toList();
    final decidedRequests = _requests
        .where((request) => request.status.toUpperCase() != 'PENDING')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quan ly nghi phep'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadLeaves,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLeaves,
        child: _buildBody(pendingRequests, decidedRequests),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody(
    List<_LeaveRequestData> pendingRequests,
    List<_LeaveRequestData> decidedRequests,
  ) {
    if (_isLoading && _requests.isEmpty) {
      return const AppLoadingState(title: 'Dang tai nghi phep');
    }
    if (_errorMessage != null && _requests.isEmpty) {
      return AppErrorState(
        title: 'Khong tai duoc nghi phep',
        message: _errorMessage!,
        onAction: _loadLeaves,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const _Title(),
        const SizedBox(height: AppSpacing.xl),
        if (_errorMessage != null) ...[
          _LeaveErrorBanner(message: _errorMessage!, onRefresh: _loadLeaves),
          const SizedBox(height: AppSpacing.lg),
        ],
        Row(
          children: [
            const Expanded(
              child: Text(
                'Dang cho duyet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            Chip(label: Text('${pendingRequests.length} yeu cau')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (pendingRequests.isEmpty)
          const AppEmptyState(
            title: 'Khong co yeu cau cho duyet',
            message: 'Cac yeu cau nghi phep moi se hien thi tai day.',
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
          'Hoat dong gan day',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        if (decidedRequests.isEmpty)
          Text(
            'Chua co yeu cau nao duoc duyet hoac tu choi.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          )
        else
          ...decidedRequests.map(
            (request) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _RecentLeave(
                name: request.name,
                status: '${request.statusLabel} - ${request.dateLabel}',
                ok: request.status.toUpperCase() == 'APPROVED',
              ),
            ),
          ),
      ],
    );
  }
}

class _LeaveErrorBanner extends StatelessWidget {
  const _LeaveErrorBanner({required this.message, required this.onRefresh});

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
            TextButton(onPressed: onRefresh, child: const Text('Thu lai')),
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
    required this.status,
  });

  final String id;
  final String name;
  final String role;
  final DateTime date;
  final int days;
  final String reason;
  final String status;

  factory _LeaveRequestData.fromJson(Map json) {
    return _LeaveRequestData(
      id: json['id']?.toString() ?? '',
      name: json['fullName']?.toString() ?? 'Nhan vien',
      role: json['roleName']?.toString() ?? '',
      date: DateTime.tryParse(json['startDate']?.toString() ?? '') ??
          DateTime.now(),
      days: int.tryParse(json['days']?.toString() ?? '') ?? 1,
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
    );
  }

  String get dateLabel => '${date.day}/${date.month}';

  String get statusLabel {
    final normalized = status.toUpperCase();
    if (normalized == 'APPROVED') {
      return 'Da duyet';
    }
    if (normalized == 'REJECTED') {
      return 'Tu choi';
    }
    return 'Dang cho';
  }
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
          'Quan ly nghi phep',
          style: AppTextStyles.display.copyWith(fontSize: 34),
        ),
        Text(
          'Thang ${now.month}, ${now.year}',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
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
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.name, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${request.role} - ${request.days} ngay - ${request.dateLabel}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(request.reason, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Tu choi',
                    onPressed: onReject,
                    variant: AppButtonVariant.secondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Duyet',
                    onPressed: onApprove,
                    variant: AppButtonVariant.primary,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        leading: Icon(
          ok ? Icons.check_circle : Icons.cancel,
          color: ok ? AppColors.success : AppColors.error,
        ),
        title: Text(name, style: AppTextStyles.body),
        subtitle: Text(status),
      ),
    );
  }
}
