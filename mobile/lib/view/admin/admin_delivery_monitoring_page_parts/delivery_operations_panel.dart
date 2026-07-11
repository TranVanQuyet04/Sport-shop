part of '../admin_delivery_monitoring_page.dart';

class _DeliveryOperationsPanel extends StatelessWidget {
  const _DeliveryOperationsPanel({
    required this.assignments,
    required this.reports,
    required this.staffUsers,
    required this.canAddAssignment,
    required this.isLoading,
    required this.isSaving,
    required this.errorMessage,
    required this.onRefresh,
    required this.onAddAssignment,
    required this.onEditAssignment,
    required this.onDeleteAssignment,
    required this.onEditReport,
    required this.onDeleteReport,
  });

  final List<DeliveryAssignmentModel> assignments;
  final List<DeliveryReportModel> reports;
  final List<AdminUserModel> staffUsers;
  final bool canAddAssignment;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final VoidCallback onAddAssignment;
  final ValueChanged<DeliveryAssignmentModel> onEditAssignment;
  final ValueChanged<DeliveryAssignmentModel> onDeleteAssignment;
  final ValueChanged<DeliveryReportModel> onEditReport;
  final ValueChanged<DeliveryReportModel> onDeleteReport;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AdminColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.hub_outlined,
                  color: AdminColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Điều phối giao hàng',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AdminColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${assignments.length} đơn đã gán · ${reports.length} báo cáo',
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tải lại điều phối',
                onPressed: isLoading ? null : onRefresh,
                icon: isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            _DeliveryOpsNotice(message: errorMessage!),
          ],
          const SizedBox(height: AppSpacing.md),
          _DeliveryOpsSection(
            icon: Icons.assignment_ind_outlined,
            title: 'Phân công giao hàng',
            actionLabel: canAddAssignment ? 'Gán shipper' : 'Đã gán hết',
            onAction: isSaving || !canAddAssignment ? null : onAddAssignment,
            emptyText: 'Chưa có đơn nào được phân công.',
            children: assignments
                .map(
                  (assignment) => _AssignmentTile(
                    assignment: assignment,
                    onEdit: isSaving
                        ? null
                        : () => onEditAssignment(assignment),
                    onDelete: isSaving
                        ? null
                        : () => onDeleteAssignment(assignment),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          _DeliveryOpsSection(
            icon: Icons.report_problem_outlined,
            title: 'Báo cáo giao hàng',
            actionLabel: null,
            onAction: null,
            emptyText: 'Chưa có báo cáo thất bại hoặc hoàn trả.',
            children: reports
                .map(
                  (report) => _ReportTile(
                    report: report,
                    onEdit: isSaving ? null : () => onEditReport(report),
                    onDelete: isSaving ? null : () => onDeleteReport(report),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DeliveryOpsNotice extends StatelessWidget {
  const _DeliveryOpsNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        message,
        style: AppTextStyles.caption.copyWith(
          color: const Color(0xFF9A3412),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DeliveryOpsSection extends StatelessWidget {
  const _DeliveryOpsSection({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.emptyText,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String emptyText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AdminColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AdminColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (actionLabel != null)
                TextButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(actionLabel!),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                emptyText,
                style: AppTextStyles.caption.copyWith(
                  color: AdminColors.textSecondary,
                ),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({
    required this.assignment,
    required this.onEdit,
    required this.onDelete,
  });

  final DeliveryAssignmentModel assignment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return _OperationTile(
      icon: Icons.local_shipping_outlined,
      title: 'Đơn #${assignment.orderId}',
      subtitle: assignment.staffName.isEmpty
          ? 'Shipper #${assignment.staffId}'
          : assignment.staffName,
      meta: assignment.note.isEmpty ? 'Không có ghi chú' : assignment.note,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.report,
    required this.onEdit,
    required this.onDelete,
  });

  final DeliveryReportModel report;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return _OperationTile(
      icon: report.status.toUpperCase() == 'RETURNED'
          ? Icons.assignment_return_outlined
          : Icons.error_outline_rounded,
      title: '${report.status} · Đơn #${report.orderId}',
      subtitle: report.reason.isEmpty ? 'Chưa có lý do' : report.reason,
      meta: report.reportedByName.isEmpty
          ? 'Người báo cáo #${report.reportedById}'
          : report.reportedByName,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class _OperationTile extends StatelessWidget {
  const _OperationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.onEdit,
    required this.onDelete,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String meta;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AdminColors.textSecondary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AdminColors.textSecondary,
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sửa',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Xóa',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _AssignmentFormResult {
  const _AssignmentFormResult({
    required this.orderId,
    required this.staffId,
    required this.note,
  });

  final String orderId;
  final String staffId;
  final String note;
}

class _AssignmentFormSheet extends StatefulWidget {
  const _AssignmentFormSheet({
    required this.orders,
    required this.assignments,
    required this.staffUsers,
    this.assignment,
    this.initialOrderId,
  });

  final List<OrderModel> orders;
  final List<DeliveryAssignmentModel> assignments;
  final List<AdminUserModel> staffUsers;
  final DeliveryAssignmentModel? assignment;
  final String? initialOrderId;

  @override
  State<_AssignmentFormSheet> createState() => _AssignmentFormSheetState();
}

class _AssignmentFormSheetState extends State<_AssignmentFormSheet> {
  final TextEditingController _noteController = TextEditingController();
  String _orderId = '';
  String _staffId = '';

  List<OrderModel> get _availableOrders {
    final assignedOrderIds = widget.assignments
        .map((assignment) => assignment.orderId)
        .toSet();
    return widget.orders
        .where((order) {
          if (widget.assignment != null &&
              order.id == widget.assignment!.orderId) {
            return true;
          }
          return !assignedOrderIds.contains(order.id);
        })
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    final availableOrders = _availableOrders;
    if (widget.assignment != null) {
      _orderId = widget.assignment!.orderId;
      _staffId = widget.assignment!.staffId.isEmpty
          ? (widget.staffUsers.isEmpty ? '' : widget.staffUsers.first.id)
          : widget.assignment!.staffId;
      _noteController.text = widget.assignment?.note ?? '';
      return;
    }
    final requestedOrderId = widget.initialOrderId;
    final canUseRequestedOrder =
        requestedOrderId != null &&
        availableOrders.any((order) => order.id == requestedOrderId);
    _orderId = canUseRequestedOrder
        ? requestedOrderId
        : (availableOrders.isEmpty ? '' : availableOrders.first.id);
    _staffId = widget.staffUsers.isEmpty ? '' : widget.staffUsers.first.id;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final availableOrders = _availableOrders;
    final isEditing = widget.assignment != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        bottomInset + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Sửa phân công' : 'Gán shipper',
              style: AppTextStyles.subtitle.copyWith(
                color: AdminColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!isEditing && availableOrders.isEmpty) ...[
              _DeliveryOpsNotice(
                message:
                    'Tất cả đơn đang giao đã có shipper. Hãy bấm Sửa trên một phân công hiện có nếu muốn đổi shipper.',
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (isEditing)
              AppTextField(
                label: 'Đơn hàng',
                initialValue: '#$_orderId',
                prefixIcon: Icons.receipt_long_outlined,
                enabled: false,
                helperText:
                    'Đơn đã có phân công, chỉ đổi shipper hoặc ghi chú.',
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _orderId.isEmpty ? null : _orderId,
                decoration: const InputDecoration(
                  labelText: 'Đơn hàng chưa gán',
                  prefixIcon: Icon(Icons.receipt_long_outlined),
                ),
                items: availableOrders
                    .map(
                      (order) => DropdownMenuItem(
                        value: order.id,
                        child: Text('#${order.id} · ${order.recipientName}'),
                      ),
                    )
                    .toList(),
                onChanged: availableOrders.isEmpty
                    ? null
                    : (value) => setState(() => _orderId = value ?? ''),
              ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _staffId.isEmpty ? null : _staffId,
              decoration: const InputDecoration(
                labelText: 'Shipper',
                prefixIcon: Icon(Icons.person_pin_circle_outlined),
              ),
              items: widget.staffUsers
                  .map(
                    (user) => DropdownMenuItem(
                      value: user.id,
                      child: Text(
                        user.fullName.isEmpty ? user.email : user.fullName,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _staffId = value ?? ''),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Ghi chú',
              controller: _noteController,
              prefixIcon: Icons.notes_outlined,
              hintText: 'Ví dụ: giao ca chiều, ưu tiên gọi trước...',
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _orderId.isEmpty || _staffId.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(
                        _AssignmentFormResult(
                          orderId: _orderId,
                          staffId: _staffId,
                          note: _noteController.text.trim(),
                        ),
                      ),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Lưu phân công'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportFormResult {
  const _ReportFormResult({
    required this.status,
    required this.reason,
    required this.note,
    required this.evidenceImageUrl,
  });

  final String status;
  final String reason;
  final String note;
  final String evidenceImageUrl;
}

class _ReportFormSheet extends StatefulWidget {
  const _ReportFormSheet({required this.report});

  final DeliveryReportModel report;

  @override
  State<_ReportFormSheet> createState() => _ReportFormSheetState();
}

class _ReportFormSheetState extends State<_ReportFormSheet> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _evidenceController = TextEditingController();
  String _status = 'FAILED';

  @override
  void initState() {
    super.initState();
    _status = widget.report.status.toUpperCase() == 'RETURNED'
        ? 'RETURNED'
        : 'FAILED';
    _reasonController.text = widget.report.reason;
    _noteController.text = widget.report.note;
    _evidenceController.text = widget.report.evidenceImageUrl;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _noteController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        bottomInset + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sửa báo cáo giao hàng',
              style: AppTextStyles.subtitle.copyWith(
                color: AdminColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'FAILED', child: Text('FAILED')),
                DropdownMenuItem(value: 'RETURNED', child: Text('RETURNED')),
              ],
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Lý do',
              controller: _reasonController,
              prefixIcon: Icons.report_problem_outlined,
              hintText: 'Nhập lý do thất bại hoặc hoàn trả',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Ghi chú',
              controller: _noteController,
              prefixIcon: Icons.notes_outlined,
              hintText: 'Thông tin bổ sung',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Ảnh bằng chứng',
              controller: _evidenceController,
              prefixIcon: Icons.image_outlined,
              hintText: 'URL ảnh bằng chứng nếu có',
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _reasonController.text.trim().isEmpty
                    ? null
                    : () => Navigator.of(context).pop(
                        _ReportFormResult(
                          status: _status,
                          reason: _reasonController.text.trim(),
                          note: _noteController.text.trim(),
                          evidenceImageUrl: _evidenceController.text.trim(),
                        ),
                      ),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Lưu báo cáo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
