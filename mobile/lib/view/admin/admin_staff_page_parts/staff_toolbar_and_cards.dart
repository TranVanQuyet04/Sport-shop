part of '../admin_staff_page.dart';

class _StaffSummaryPill extends StatelessWidget {
  const _StaffSummaryPill({
    required this.total,
    required this.active,
    required this.shippers,
  });

  final int total;
  final int active;
  final int shippers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AdminColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        '$total tổng · $active hoạt động · $shippers shipper',
        style: AppTextStyles.caption.copyWith(
          color: AdminColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StaffToolbar extends StatelessWidget {
  const _StaffToolbar({
    required this.controller,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final _StaffFilter selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_StaffFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final hasFilter = selectedFilter != _StaffFilter.all;
    return AdminSurface(
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tìm theo tên, email, số điện thoại hoặc mã...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterIndicator(active: hasFilter),
                const SizedBox(width: AppSpacing.sm),
                for (final filter in _StaffFilter.values) ...[
                  ChoiceChip(
                    label: Text(filter.label),
                    selected: selectedFilter == filter,
                    showCheckmark: false,
                    onSelected: (_) => onFilterChanged(filter),
                    selectedColor: AdminColors.primary,
                    backgroundColor: AdminColors.surfaceMuted,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    labelStyle: AppTextStyles.caption.copyWith(
                      color: selectedFilter == filter
                          ? Colors.white
                          : AdminColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterIndicator extends StatelessWidget {
  const _FilterIndicator({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AdminColors.navy,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            children: [
              Icon(Icons.tune_rounded, color: Colors.white, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Bộ lọc',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (active)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AdminColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _StaggeredEmployeeCard extends StatefulWidget {
  const _StaggeredEmployeeCard({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_StaggeredEmployeeCard> createState() => _StaggeredEmployeeCardState();
}

class _StaggeredEmployeeCardState extends State<_StaggeredEmployeeCard> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 55 * widget.index.clamp(0, 8));
    _timer = Timer(delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.12),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: widget.child,
        ),
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({
    super.key,
    required this.user,
    required this.onTap,
    required this.onPhone,
    required this.onEdit,
  });

  final AdminUserModel user;
  final VoidCallback onTap;
  final VoidCallback onPhone;
  final VoidCallback onEdit;

  bool get _isShipper => user.roleName.toUpperCase() == 'SHIPPER';

  String get _initials {
    final parts = user.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _isShipper ? AdminColors.primary : AdminColors.accent;
    final softAccent = _isShipper
        ? AdminColors.primarySoft
        : AdminColors.accentSoft;
    final secondaryText = user.email.isNotEmpty
        ? user.email
        : (user.phoneNumber.isNotEmpty
              ? user.phoneNumber
              : 'Chưa cập nhật thông tin liên hệ');

    return AdminSurface(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 440;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EmployeeAvatar(
                    initials: _initials,
                    active: user.status,
                    accent: accent,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.fullName.isEmpty
                                    ? 'Chưa cập nhật tên'
                                    : user.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.title.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (!compact)
                              _RoleBadge(
                                label: user.roleName,
                                color: accent,
                                background: softAccent,
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          secondaryText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AdminColors.textSecondary,
                          ),
                        ),
                        if (compact) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _RoleBadge(
                            label: user.roleName,
                            color: accent,
                            background: softAccent,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1, color: AdminColors.border),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _MetadataItem(
                      icon: Icons.badge_outlined,
                      label: 'Mã nhân viên',
                      value: user.id.isEmpty
                          ? 'Chưa có dữ liệu'
                          : '#${user.id}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _MetadataItem(
                      icon: _isShipper
                          ? Icons.local_shipping_outlined
                          : Icons.calendar_today_outlined,
                      label: _isShipper ? 'Đơn đang giao' : 'Ngày tham gia',
                      value: 'Chưa có dữ liệu',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickIconButton(
                    tooltip: 'Số điện thoại',
                    icon: Icons.phone_outlined,
                    onPressed: onPhone,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _QuickIconButton(
                    tooltip: 'Chỉnh sửa',
                    icon: Icons.edit_outlined,
                    onPressed: onEdit,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StaffOperationsPanel extends StatelessWidget {
  const _StaffOperationsPanel({
    required this.workShifts,
    required this.leaveRequests,
    required this.isLoading,
    required this.isSaving,
    required this.errorMessage,
    required this.onRefresh,
    required this.onAddShift,
    required this.onEditShift,
    required this.onDeleteShift,
    required this.onAddLeave,
    required this.onEditLeave,
    required this.onApproveLeave,
    required this.onRejectLeave,
    required this.onDeleteLeave,
  });

  final List<WorkShiftModel> workShifts;
  final List<LeaveRequestModel> leaveRequests;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final VoidCallback onAddShift;
  final ValueChanged<WorkShiftModel> onEditShift;
  final ValueChanged<WorkShiftModel> onDeleteShift;
  final VoidCallback onAddLeave;
  final ValueChanged<LeaveRequestModel> onEditLeave;
  final ValueChanged<LeaveRequestModel> onApproveLeave;
  final ValueChanged<LeaveRequestModel> onRejectLeave;
  final ValueChanged<LeaveRequestModel> onDeleteLeave;

  @override
  Widget build(BuildContext context) {
    final pendingLeaves = leaveRequests
        .where((leave) => leave.status.toUpperCase() == 'PENDING')
        .length;
    return AdminSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AdminIconBadge(icon: Icons.event_available_rounded),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch làm & nghỉ phép',
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${workShifts.length} ca làm · $pendingLeaves đơn chờ duyệt',
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Làm mới',
                onPressed: isLoading ? null : onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            AdminInlineBanner(
              message: errorMessage!,
              onRefresh: onRefresh,
              isError: true,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            _OperationExpansion(
              title: 'Ca làm việc',
              actionLabel: 'Thêm ca',
              onAdd: isSaving ? null : onAddShift,
              emptyText: 'Chưa có ca làm trong khoảng thời gian hiện tại.',
              children: workShifts
                  .map(
                    (shift) => _WorkShiftRow(
                      shift: shift,
                      isSaving: isSaving,
                      onEdit: () => onEditShift(shift),
                      onDelete: () => onDeleteShift(shift),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            _OperationExpansion(
              title: 'Đơn nghỉ phép',
              actionLabel: 'Thêm đơn',
              onAdd: isSaving ? null : onAddLeave,
              emptyText: 'Chưa có đơn nghỉ phép.',
              children: leaveRequests
                  .map(
                    (leave) => _LeaveRequestRow(
                      leave: leave,
                      isSaving: isSaving,
                      onEdit: () => onEditLeave(leave),
                      onApprove: () => onApproveLeave(leave),
                      onReject: () => onRejectLeave(leave),
                      onDelete: () => onDeleteLeave(leave),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _OperationExpansion extends StatelessWidget {
  const _OperationExpansion({
    required this.title,
    required this.actionLabel,
    required this.onAdd,
    required this.emptyText,
    required this.children,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onAdd;
  final String emptyText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AdminColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AdminColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        title: Text(title, style: AppTextStyles.subtitle),
        trailing: TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(actionLabel),
        ),
        children: children.isEmpty
            ? [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      emptyText,
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ]
            : children,
      ),
    );
  }
}

class _WorkShiftRow extends StatelessWidget {
  const _WorkShiftRow({
    required this.shift,
    required this.isSaving,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkShiftModel shift;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = shift.shiftDate?.toIso8601String().split('T').first ?? '-';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${shift.fullName} · ${shift.shiftCode}'),
      subtitle: Text('$date${shift.note.isEmpty ? '' : ' · ${shift.note}'}'),
      trailing: Wrap(
        children: [
          IconButton(
            tooltip: 'Sửa ca',
            onPressed: isSaving ? null : onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Xóa ca',
            onPressed: isSaving ? null : onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _LeaveRequestRow extends StatelessWidget {
  const _LeaveRequestRow({
    required this.leave,
    required this.isSaving,
    required this.onEdit,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
  });

  final LeaveRequestModel leave;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = leave.startDate?.toIso8601String().split('T').first ?? '-';
    final isPending = leave.status.toUpperCase() == 'PENDING';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${leave.fullName} · ${leave.days} ngày'),
      subtitle: Text('$date · ${leave.status} · ${leave.reason}'),
      trailing: Wrap(
        children: [
          if (isPending) ...[
            IconButton(
              tooltip: 'Duyệt',
              onPressed: isSaving ? null : onApprove,
              icon: const Icon(Icons.check_circle_outline),
            ),
            IconButton(
              tooltip: 'Từ chối',
              onPressed: isSaving ? null : onReject,
              icon: const Icon(Icons.cancel_outlined),
            ),
          ],
          IconButton(
            tooltip: 'Sửa đơn',
            onPressed: isSaving ? null : onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Xóa đơn',
            onPressed: isSaving ? null : onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _WorkShiftFormResult {
  const _WorkShiftFormResult({
    required this.userId,
    required this.shiftDate,
    required this.shiftCode,
    required this.note,
  });

  final String userId;
  final String shiftDate;
  final String shiftCode;
  final String note;
}

class _WorkShiftFormDialog extends StatefulWidget {
  const _WorkShiftFormDialog({required this.staffUsers, this.shift});

  final List<AdminUserModel> staffUsers;
  final WorkShiftModel? shift;

  @override
  State<_WorkShiftFormDialog> createState() => _WorkShiftFormDialogState();
}

class _WorkShiftFormDialogState extends State<_WorkShiftFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _userId;
  late final TextEditingController _dateController;
  late final TextEditingController _codeController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final shift = widget.shift;
    _userId =
        shift?.userId ??
        (widget.staffUsers.isEmpty ? '' : widget.staffUsers.first.id);
    _dateController = TextEditingController(
      text:
          shift?.shiftDate?.toIso8601String().split('T').first ??
          DateTime.now().toIso8601String().split('T').first,
    );
    _codeController = TextEditingController(text: shift?.shiftCode ?? 'AM');
    _noteController = TextEditingController(text: shift?.note ?? '');
  }

  @override
  void dispose() {
    _dateController.dispose();
    _codeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.shift == null ? 'Thêm ca làm' : 'Sửa ca làm'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _userId.isEmpty ? null : _userId,
                decoration: const InputDecoration(labelText: 'Nhân viên'),
                items: widget.staffUsers
                    .map(
                      (user) => DropdownMenuItem(
                        value: user.id,
                        child: Text(user.fullName),
                      ),
                    )
                    .toList(),
                validator: (value) => value == null ? 'Chọn nhân viên.' : null,
                onChanged: (value) => setState(() => _userId = value ?? ''),
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Ngày yyyy-MM-dd'),
                validator: _required,
              ),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Mã ca'),
                validator: _required,
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            Navigator.of(context).pop(
              _WorkShiftFormResult(
                userId: _userId,
                shiftDate: _dateController.text.trim(),
                shiftCode: _codeController.text.trim(),
                note: _noteController.text.trim(),
              ),
            );
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Bắt buộc.' : null;
  }
}

class _LeaveRequestFormResult {
  const _LeaveRequestFormResult({
    required this.userId,
    required this.startDate,
    required this.days,
    required this.reason,
  });

  final String userId;
  final String startDate;
  final int days;
  final String reason;
}

class _LeaveRequestFormDialog extends StatefulWidget {
  const _LeaveRequestFormDialog({required this.staffUsers, this.leave});

  final List<AdminUserModel> staffUsers;
  final LeaveRequestModel? leave;

  @override
  State<_LeaveRequestFormDialog> createState() =>
      _LeaveRequestFormDialogState();
}

class _LeaveRequestFormDialogState extends State<_LeaveRequestFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _userId;
  late final TextEditingController _dateController;
  late final TextEditingController _daysController;
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    final leave = widget.leave;
    _userId =
        leave?.userId ??
        (widget.staffUsers.isEmpty ? '' : widget.staffUsers.first.id);
    _dateController = TextEditingController(
      text:
          leave?.startDate?.toIso8601String().split('T').first ??
          DateTime.now().toIso8601String().split('T').first,
    );
    _daysController = TextEditingController(
      text: leave == null ? '1' : leave.days.toString(),
    );
    _reasonController = TextEditingController(text: leave?.reason ?? '');
  }

  @override
  void dispose() {
    _dateController.dispose();
    _daysController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.leave == null ? 'Thêm đơn nghỉ' : 'Sửa đơn nghỉ'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _userId.isEmpty ? null : _userId,
                decoration: const InputDecoration(labelText: 'Nhân viên'),
                items: widget.staffUsers
                    .map(
                      (user) => DropdownMenuItem(
                        value: user.id,
                        child: Text(user.fullName),
                      ),
                    )
                    .toList(),
                validator: (value) => value == null ? 'Chọn nhân viên.' : null,
                onChanged: (value) => setState(() => _userId = value ?? ''),
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
                validator: _required,
              ),
              TextFormField(
                controller: _daysController,
                decoration: const InputDecoration(labelText: 'Số ngày'),
                keyboardType: TextInputType.number,
                validator: (value) => (int.tryParse(value ?? '') ?? 0) <= 0
                    ? 'Không hợp lệ.'
                    : null,
              ),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(labelText: 'Lý do'),
                validator: _required,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            Navigator.of(context).pop(
              _LeaveRequestFormResult(
                userId: _userId,
                startDate: _dateController.text.trim(),
                days: int.parse(_daysController.text.trim()),
                reason: _reasonController.text.trim(),
              ),
            );
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Bắt buộc.' : null;
  }
}
