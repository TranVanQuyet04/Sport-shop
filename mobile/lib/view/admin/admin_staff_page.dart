import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../presenter/admin/admin_catalog_presenter.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/admin/leave_request_model.dart';
import '../../model/admin/work_shift_model.dart';
import '../../repository/admin/admin_staff_operations_repository.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

part 'admin_staff_page_parts/staff_filter_and_form.dart';
part 'admin_staff_page_parts/staff_toolbar_and_cards.dart';
part 'admin_staff_page_parts/staff_card_details.dart';

class AdminStaffPage extends StatefulWidget {
  const AdminStaffPage({super.key});

  @override
  State<AdminStaffPage> createState() => _AdminStaffPageState();
}

class _AdminStaffPageState extends State<AdminStaffPage> {
  late final AdminCatalogPresenter _presenter = AdminCatalogPresenter(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  late final AdminStaffOperationsRepository _operationsRepository =
      AppDependencies.instance.adminStaffOperationsRepository;
  final TextEditingController _searchController = TextEditingController();
  _StaffFilter _selectedFilter = _StaffFilter.all;
  List<WorkShiftModel> _workShifts = const [];
  List<LeaveRequestModel> _leaveRequests = const [];
  bool _isLoadingOperations = false;
  bool _isSavingOperations = false;
  String? _operationsError;

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadUsers();
    _loadOperations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _presenter
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
    return _presenter.users.where((user) {
      final role = user.roleName.toUpperCase();
      return role == 'ADMIN' || role == 'SHIPPER';
    }).toList();
  }

  List<AdminUserModel> get _visibleStaff {
    final query = _searchController.text.trim().toLowerCase();
    return _staffUsers.where((user) {
      final matchesFilter = switch (_selectedFilter) {
        _StaffFilter.all => true,
        _StaffFilter.admin => user.roleName.toUpperCase() == 'ADMIN',
        _StaffFilter.shipper => user.roleName.toUpperCase() == 'SHIPPER',
        _StaffFilter.active => user.status,
      };
      final matchesQuery =
          query.isEmpty ||
          user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phoneNumber.toLowerCase().contains(query) ||
          user.id.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  void _showPhone(AdminUserModel user) {
    final phone = user.phoneNumber.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          phone.isEmpty
              ? '${user.fullName} chưa cập nhật số điện thoại.'
              : 'Số điện thoại: $phone',
        ),
      ),
    );
  }

  Future<void> _loadOperations() async {
    setState(() {
      _isLoadingOperations = true;
      _operationsError = null;
    });
    try {
      final results = await Future.wait([
        _operationsRepository.getWorkShifts(),
        _operationsRepository.getLeaveRequests(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _workShifts = results[0] as List<WorkShiftModel>;
        _leaveRequests = results[1] as List<LeaveRequestModel>;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _operationsError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoadingOperations = false);
      }
    }
  }

  Future<void> _openStaffCreateForm() async {
    final result = await showDialog<_StaffFormResult>(
      context: context,
      builder: (context) => const _StaffFormDialog(),
    );
    if (result == null || !mounted) return;

    final success = await _presenter.saveUser(
      fullName: result.fullName,
      email: result.email,
      phoneNumber: result.phoneNumber,
      password: result.password,
      confirmPassword: result.confirmPassword,
      roleName: result.roleName,
      status: result.status,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã thêm nhân viên ${result.fullName}.'
              : (_presenter.errorMessage ?? 'Không thể thêm nhân viên.'),
        ),
      ),
    );
  }

  Future<void> _openStaffEditForm(AdminUserModel user) async {
    final result = await showDialog<_StaffFormResult>(
      context: context,
      builder: (context) => _StaffFormDialog(user: user),
    );
    if (result == null || !mounted) return;

    final success = await _presenter.saveUser(
      id: user.id,
      fullName: result.fullName,
      email: result.email,
      phoneNumber: result.phoneNumber,
      password: result.password,
      confirmPassword: result.confirmPassword,
      roleName: result.roleName,
      status: result.status,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã cập nhật nhân viên ${result.fullName}.'
              : (_presenter.errorMessage ?? 'Không thể cập nhật nhân viên.'),
        ),
      ),
    );
  }

  Future<void> _openWorkShiftForm([WorkShiftModel? shift]) async {
    final result = await showDialog<_WorkShiftFormResult>(
      context: context,
      builder: (context) =>
          _WorkShiftFormDialog(staffUsers: _staffUsers, shift: shift),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() => _isSavingOperations = true);
    try {
      if (shift == null) {
        await _operationsRepository.createWorkShift(
          userId: result.userId,
          shiftDate: result.shiftDate,
          shiftCode: result.shiftCode,
          note: result.note,
        );
      } else {
        await _operationsRepository.updateWorkShift(
          id: shift.id,
          userId: result.userId,
          shiftDate: result.shiftDate,
          shiftCode: result.shiftCode,
          note: result.note,
        );
      }
      await _loadOperations();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingOperations = false);
      }
    }
  }

  Future<void> _deleteWorkShift(WorkShiftModel shift) async {
    final confirmed = await _confirm(
      title: 'Xóa ca làm?',
      message: '${shift.fullName} - ${shift.shiftCode}',
    );
    if (confirmed != true) {
      return;
    }
    setState(() => _isSavingOperations = true);
    try {
      await _operationsRepository.deleteWorkShift(shift.id);
      await _loadOperations();
    } finally {
      if (mounted) {
        setState(() => _isSavingOperations = false);
      }
    }
  }

  Future<void> _openLeaveRequestForm([LeaveRequestModel? leave]) async {
    final result = await showDialog<_LeaveRequestFormResult>(
      context: context,
      builder: (context) =>
          _LeaveRequestFormDialog(staffUsers: _staffUsers, leave: leave),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() => _isSavingOperations = true);
    try {
      if (leave == null) {
        await _operationsRepository.createLeaveRequest(
          userId: result.userId,
          startDate: result.startDate,
          days: result.days,
          reason: result.reason,
        );
      } else {
        await _operationsRepository.updateLeaveRequest(
          id: leave.id,
          userId: result.userId,
          startDate: result.startDate,
          days: result.days,
          reason: result.reason,
        );
      }
      await _loadOperations();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingOperations = false);
      }
    }
  }

  Future<void> _decideLeaveRequest(
    LeaveRequestModel leave,
    String status,
  ) async {
    setState(() => _isSavingOperations = true);
    try {
      await _operationsRepository.decideLeaveRequest(
        id: leave.id,
        status: status,
      );
      await _loadOperations();
    } finally {
      if (mounted) {
        setState(() => _isSavingOperations = false);
      }
    }
  }

  Future<void> _deleteLeaveRequest(LeaveRequestModel leave) async {
    final confirmed = await _confirm(
      title: 'Xóa đơn nghỉ?',
      message: '${leave.fullName} - ${leave.reason}',
    );
    if (confirmed != true) {
      return;
    }
    setState(() => _isSavingOperations = true);
    try {
      await _operationsRepository.deleteLeaveRequest(leave.id);
      await _loadOperations();
    } finally {
      if (mounted) {
        setState(() => _isSavingOperations = false);
      }
    }
  }

  Future<bool?> _confirm({required String title, required String message}) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_presenter.loadUsers(), _loadOperations()]);
        },
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _presenter.isSubmitting ? null : _openStaffCreateForm,
        tooltip: 'Thêm nhân viên',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.person_add_alt_1),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody() {
    final staffUsers = _staffUsers;
    if (_presenter.isLoading && staffUsers.isEmpty) {
      return const AppLoadingState(title: 'Đang tải nhân viên');
    }
    if (_presenter.errorMessage != null && staffUsers.isEmpty) {
      return AppErrorState(
        title: 'Không tải được nhân viên',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadUsers,
      );
    }

    final visibleStaff = _visibleStaff;
    final activeCount = staffUsers.where((user) => user.status).length;
    final shipperCount = staffUsers
        .where((user) => user.roleName.toUpperCase() == 'SHIPPER')
        .length;

    return AbsolutePersistentLayout(
      title: 'Quản lý nhân viên',
      subtitle: 'Theo dõi tài khoản quản trị và đội ngũ giao hàng.',
      icon: Icons.groups_2_outlined,
      trailing: _StaffSummaryPill(
        total: staffUsers.length,
        active: activeCount,
        shippers: shipperCount,
      ),
      filterAndSearchZone: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_presenter.errorMessage != null) ...[
            AdminInlineBanner(
              message: _presenter.errorMessage!,
              onRefresh: _presenter.loadUsers,
              isError: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _StaffToolbar(
            controller: _searchController,
            selectedFilter: _selectedFilter,
            onSearchChanged: (_) => setState(() {}),
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
            },
          ),
        ],
      ),
      dynamicContent: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          104,
        ),
        children: [
          _StaffOperationsPanel(
            workShifts: _workShifts,
            leaveRequests: _leaveRequests,
            isLoading: _isLoadingOperations,
            isSaving: _isSavingOperations,
            errorMessage: _operationsError,
            onRefresh: _loadOperations,
            onAddShift: () => _openWorkShiftForm(),
            onEditShift: _openWorkShiftForm,
            onDeleteShift: _deleteWorkShift,
            onAddLeave: () => _openLeaveRequestForm(),
            onEditLeave: _openLeaveRequestForm,
            onApproveLeave: (leave) => _decideLeaveRequest(leave, 'APPROVED'),
            onRejectLeave: (leave) => _decideLeaveRequest(leave, 'REJECTED'),
            onDeleteLeave: _deleteLeaveRequest,
          ),
          const SizedBox(height: AppSpacing.lg),
          AdminSectionTitle(
            title: 'Danh sách nhân viên',
            subtitle: '${visibleStaff.length} kết quả phù hợp',
            trailing: IconButton(
              tooltip: 'Làm mới',
              onPressed: _presenter.isLoading ? null : _presenter.loadUsers,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (visibleStaff.isEmpty)
            PremiumEmptyState(
              icon: Icons.groups_2_outlined,
              title: 'Không tìm thấy nhân viên',
              message: 'Thử thay đổi từ khóa hoặc bộ lọc hiện tại.',
              actionLabel: 'Xóa bộ lọc',
              onAction: () {
                _searchController.clear();
                setState(() => _selectedFilter = _StaffFilter.all);
              },
            )
          else
            ...visibleStaff.indexed.map(
              (entry) => _StaggeredEmployeeCard(
                key: ValueKey(entry.$2.id),
                index: entry.$1,
                child: EmployeeCard(
                  user: entry.$2,
                  onTap: () => context.go(
                    AppRoutes.adminStaffDetail.replaceFirst(':id', entry.$2.id),
                  ),
                  onPhone: () => _showPhone(entry.$2),
                  onEdit: () => _openStaffEditForm(entry.$2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
