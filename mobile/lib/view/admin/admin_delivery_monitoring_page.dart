import 'dart:async';

import 'package:flutter/material.dart';

import '../../presenter/admin/admin_orders_presenter.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/hover_effect.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/common/delivery_status.dart';
import '../../model/customer/order_model.dart';
import '../../model/delivery/delivery_assignment_model.dart';
import '../../model/delivery/delivery_report_model.dart';
import '../../repository/delivery/delivery_operations_repository.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

part 'admin_delivery_monitoring_page_parts/delivery_filters_and_summary.dart';
part 'admin_delivery_monitoring_page_parts/delivery_card_widgets.dart';
part 'admin_delivery_monitoring_page_parts/delivery_stepper_widgets.dart';
part 'admin_delivery_monitoring_page_parts/delivery_operations_panel.dart';

enum _DeliveryFilter { all, active, delivered, issue }

class AdminDeliveryMonitoringPage extends StatefulWidget {
  const AdminDeliveryMonitoringPage({super.key});

  @override
  State<AdminDeliveryMonitoringPage> createState() =>
      _AdminDeliveryMonitoringPageState();
}

class _AdminDeliveryMonitoringPageState
    extends State<AdminDeliveryMonitoringPage> {
  late final AdminOrdersPresenter _presenter = AdminOrdersPresenter(
    orderRepository: AppDependencies.instance.orderRepository,
  );
  late final DeliveryOperationsRepository _deliveryOperationsRepository =
      AppDependencies.instance.deliveryOperationsRepository;
  final TextEditingController _searchController = TextEditingController();

  _DeliveryFilter _selectedFilter = _DeliveryFilter.all;
  String _searchQuery = '';
  List<AdminUserModel> _staffUsers = const [];
  List<DeliveryAssignmentModel> _assignments = const [];
  List<DeliveryReportModel> _reports = const [];
  bool _isLoadingOperations = false;
  bool _isSavingOperations = false;
  String? _operationsError;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadOrders();
    _loadDeliveryOperations();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
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

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!_presenter.isLoading &&
          !_presenter.isUpdating &&
          !_isLoadingOperations &&
          !_isSavingOperations) {
        _refreshAll(showLoading: false);
      }
    });
  }

  Future<void> _refreshAll({bool showLoading = true}) async {
    await Future.wait([
      _presenter.loadOrders(showLoading: showLoading),
      _loadDeliveryOperations(showLoading: showLoading),
    ]);
  }

  Future<void> _loadDeliveryOperations({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoadingOperations = true;
        _operationsError = null;
      });
    } else {
      _operationsError = null;
    }
    try {
      final users = await AppDependencies.instance.adminCatalogRepository
          .getUsers();
      final assignments = await _deliveryOperationsRepository.getAssignments();
      final reports = await _deliveryOperationsRepository.getAllReports();
      if (!mounted) {
        return;
      }
      setState(() {
        _staffUsers = users
            .where((user) => user.roleName.toUpperCase() == 'SHIPPER')
            .toList();
        _assignments = assignments;
        _reports = reports;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _operationsError = error.toString());
    } finally {
      if (mounted) {
        if (showLoading) {
          setState(() => _isLoadingOperations = false);
        }
      }
    }
  }

  Future<void> _openAssignmentForm({
    OrderModel? order,
    DeliveryAssignmentModel? assignment,
  }) async {
    final result = await showModalBottomSheet<_AssignmentFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _AssignmentFormSheet(
        orders: _deliveryOrders,
        assignments: _assignments,
        staffUsers: _staffUsers,
        assignment: assignment,
        initialOrderId: order?.id,
      ),
    );
    if (result == null) {
      return;
    }
    setState(() => _isSavingOperations = true);
    try {
      if (assignment == null) {
        await _deliveryOperationsRepository.assignOrder(
          orderId: result.orderId,
          staffId: result.staffId,
          note: result.note,
        );
      } else {
        await _deliveryOperationsRepository.updateAssignment(
          id: assignment.id,
          orderId: result.orderId,
          staffId: result.staffId,
          note: result.note,
        );
      }
      await _loadDeliveryOperations();
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

  Future<void> _deleteAssignment(DeliveryAssignmentModel assignment) async {
    final confirmed = await _confirm(
      title: 'Gỡ phân công',
      message: 'Bạn có chắc muốn gỡ shipper khỏi đơn #${assignment.orderId}?',
    );
    if (!confirmed) {
      return;
    }
    setState(() => _isSavingOperations = true);
    try {
      await _deliveryOperationsRepository.deleteAssignment(assignment.id);
      await _loadDeliveryOperations();
    } finally {
      if (mounted) {
        setState(() => _isSavingOperations = false);
      }
    }
  }

  Future<void> _openReportForm(DeliveryReportModel report) async {
    final result = await showModalBottomSheet<_ReportFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ReportFormSheet(report: report),
    );
    if (result == null) {
      return;
    }
    setState(() => _isSavingOperations = true);
    try {
      await _deliveryOperationsRepository.updateReport(
        id: report.id,
        status: result.status,
        reason: result.reason,
        note: result.note,
        evidenceImageUrl: result.evidenceImageUrl,
      );
      await _loadDeliveryOperations();
    } finally {
      if (mounted) {
        setState(() => _isSavingOperations = false);
      }
    }
  }

  Future<void> _deleteReport(DeliveryReportModel report) async {
    final confirmed = await _confirm(
      title: 'Xóa báo cáo',
      message: 'Bạn có chắc muốn xóa báo cáo giao hàng #${report.id}?',
    );
    if (!confirmed) {
      return;
    }
    setState(() => _isSavingOperations = true);
    try {
      await _deliveryOperationsRepository.deleteReport(report.id);
      await _loadDeliveryOperations();
    } finally {
      if (mounted) {
        setState(() => _isSavingOperations = false);
      }
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
        ) ??
        false;
  }

  List<OrderModel> get _deliveryOrders {
    final query = _searchQuery.trim().toLowerCase();
    return _presenter.orders.where((order) {
      final rawStatus = order.status.toUpperCase();
      final paymentMethod = order.paymentMethod.toUpperCase();
      final belongsToDelivery =
          (rawStatus == 'PENDING' && paymentMethod == 'COD') ||
          rawStatus == 'PAID' ||
          rawStatus == 'CONFIRMED' ||
          rawStatus == 'PACKING' ||
          rawStatus == 'SHIPPED' ||
          rawStatus == 'SHIPPING' ||
          rawStatus == 'DELIVERED' ||
          rawStatus == 'COMPLETED' ||
          rawStatus == 'CANCELLED';
      if (!belongsToDelivery) {
        return false;
      }

      final deliveryStatus = _mapDeliveryStatus(order);
      final matchesFilter = switch (_selectedFilter) {
        _DeliveryFilter.all => true,
        _DeliveryFilter.active =>
          deliveryStatus != DeliveryStatus.delivered &&
              deliveryStatus != DeliveryStatus.failed &&
              deliveryStatus != DeliveryStatus.returned,
        _DeliveryFilter.delivered => deliveryStatus == DeliveryStatus.delivered,
        _DeliveryFilter.issue =>
          deliveryStatus == DeliveryStatus.failed ||
              deliveryStatus == DeliveryStatus.returned,
      };
      if (!matchesFilter || query.isEmpty) {
        return matchesFilter;
      }

      return order.id.toLowerCase().contains(query) ||
          order.recipientName.toLowerCase().contains(query) ||
          order.phoneNumber.toLowerCase().contains(query) ||
          order.shippingAddress.toLowerCase().contains(query) ||
          order.firstProductName.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _advanceDelivery(OrderModel order) async {
    final currentStatus = order.status.toUpperCase();
    final nextStatus = switch (currentStatus) {
      'PENDING' => 'CONFIRMED',
      'CONFIRMED' => 'PACKING',
      'PACKING' || 'PAID' => 'SHIPPED',
      'SHIPPED' || 'SHIPPING' => 'DELIVERED',
      'DELIVERED' => 'COMPLETED',
      _ => 'SHIPPED',
    };
    await _presenter.updateOrderStatus(order.id, nextStatus);
    if (!mounted) {
      return;
    }
    final failed = _presenter.errorMessage != null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failed
              ? _presenter.errorMessage!
              : 'Đã cập nhật đơn #${order.id} sang $nextStatus.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = _deliveryOrders;
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(onRefresh: _refreshAll, child: _buildBody(orders)),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Làm mới danh sách giao hàng',
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: _presenter.isLoading || _isLoadingOperations
            ? null
            : _refreshAll,
        child: _presenter.isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh_rounded),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
    );
  }

  Widget _buildBody(List<OrderModel> orders) {
    final assignmentByOrderId = {
      for (final assignment in _assignments) assignment.orderId: assignment,
    };
    final canAddAssignment = _deliveryOrders.any(
      (order) => !assignmentByOrderId.containsKey(order.id),
    );
    if (_presenter.isLoading && _presenter.orders.isEmpty) {
      return const AppLoadingState(title: 'Đang tải giao hàng');
    }
    if (_presenter.errorMessage != null && _presenter.orders.isEmpty) {
      return AppErrorState(
        title: 'Không tải được giao hàng',
        message: _presenter.errorMessage!,
        onAction: _refreshAll,
      );
    }

    final allDeliveryOrders = _presenter.orders.where((order) {
      final status = order.status.toUpperCase();
      return status == 'PENDING' ||
          status == 'PAID' ||
          status == 'CONFIRMED' ||
          status == 'PACKING' ||
          status == 'SHIPPED' ||
          status == 'SHIPPING' ||
          status == 'DELIVERED' ||
          status == 'COMPLETED' ||
          status == 'CANCELLED';
    }).toList();
    final activeCount = allDeliveryOrders.where((order) {
      final status = _mapDeliveryStatus(order);
      return status != DeliveryStatus.delivered &&
          status != DeliveryStatus.failed &&
          status != DeliveryStatus.returned;
    }).length;
    final deliveredCount = allDeliveryOrders
        .where((order) => _mapDeliveryStatus(order) == DeliveryStatus.delivered)
        .length;

    return AbsolutePersistentLayout(
      title: 'Theo dõi giao hàng',
      subtitle: 'Giám sát trạng thái vận chuyển và xử lý các đơn đang giao.',
      icon: Icons.local_shipping_outlined,
      trailing: _DeliverySummary(
        activeCount: activeCount,
        deliveredCount: deliveredCount,
      ),
      filterAndSearchZone: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_presenter.errorMessage != null) ...[
            _DeliveryErrorBanner(
              message: _presenter.errorMessage!,
              onRefresh: _refreshAll,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          AppTextField(
            label: 'Tìm kiếm',
            controller: _searchController,
            prefixIcon: Icons.search_rounded,
            hintText: 'Tìm mã đơn, người nhận, số điện thoại hoặc địa chỉ...',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: AppSpacing.md),
          _DeliveryFilterBar(
            selected: _selectedFilter,
            onSelected: (filter) => setState(() => _selectedFilter = filter),
          ),
        ],
      ),
      dynamicContent: orders.isEmpty
          ? _buildEmptyState()
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                0,
              ),
              children: [
                _DeliveryOperationsPanel(
                  assignments: _assignments,
                  reports: _reports,
                  staffUsers: _staffUsers,
                  canAddAssignment: canAddAssignment,
                  isLoading: _isLoadingOperations,
                  isSaving: _isSavingOperations,
                  errorMessage: _operationsError,
                  onRefresh: _loadDeliveryOperations,
                  onAddAssignment: () => _openAssignmentForm(),
                  onEditAssignment: (assignment) =>
                      _openAssignmentForm(assignment: assignment),
                  onDeleteAssignment: _deleteAssignment,
                  onEditReport: _openReportForm,
                  onDeleteReport: _deleteReport,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeading(
                  count: orders.length,
                  hasFilter:
                      _selectedFilter != _DeliveryFilter.all ||
                      _searchQuery.trim().isNotEmpty,
                ),
                const SizedBox(height: AppSpacing.md),
                ...orders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: DeliveryCardWidget(
                      order: order,
                      status: _mapDeliveryStatus(order),
                      assignment: assignmentByOrderId[order.id],
                      isUpdating: _presenter.isUpdating,
                      onAdvance: _presenter.isUpdating
                          ? null
                          : () => _advanceDelivery(order),
                      onAssign: _isSavingOperations
                          ? null
                          : () => _openAssignmentForm(
                              order: order,
                              assignment: assignmentByOrderId[order.id],
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return PremiumEmptyState(
      icon: _emptyPresentation.icon,
      title: _emptyPresentation.title,
      message: _emptyPresentation.message,
      actionLabel:
          _selectedFilter == _DeliveryFilter.all && _searchQuery.trim().isEmpty
          ? 'Tải lại dữ liệu'
          : 'Xóa bộ lọc',
      actionIcon:
          _selectedFilter == _DeliveryFilter.all && _searchQuery.trim().isEmpty
          ? Icons.refresh_rounded
          : Icons.filter_alt_off_outlined,
      onAction:
          _selectedFilter == _DeliveryFilter.all && _searchQuery.trim().isEmpty
          ? _refreshAll
          : () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedFilter = _DeliveryFilter.all;
              });
            },
    );
  }

  _DeliveryEmptyPresentation get _emptyPresentation {
    if (_searchQuery.trim().isNotEmpty) {
      return const _DeliveryEmptyPresentation(
        icon: Icons.search_off_rounded,
        title: 'Không tìm thấy vận đơn',
        message: 'Không có vận đơn nào khớp với từ khóa tìm kiếm hiện tại.',
      );
    }
    return switch (_selectedFilter) {
      _DeliveryFilter.all => const _DeliveryEmptyPresentation(
        icon: Icons.local_shipping_outlined,
        title: 'Chưa có vận đơn',
        message: 'Các đơn đã thanh toán hoặc chờ giao sẽ hiển thị tại đây.',
      ),
      _DeliveryFilter.active => const _DeliveryEmptyPresentation(
        icon: Icons.local_shipping_outlined,
        title: 'Không có đơn đang giao',
        message:
            'Tất cả các kiện hàng đã được bưu tá phát hoặc đang ở kho lưu trữ.',
      ),
      _DeliveryFilter.delivered => const _DeliveryEmptyPresentation(
        icon: Icons.check_circle_outline_rounded,
        title: 'Chưa có đơn hoàn thành',
        message: 'Không tìm thấy dữ liệu lịch sử giao hàng thành công.',
      ),
      _DeliveryFilter.issue => const _DeliveryEmptyPresentation(
        icon: Icons.report_problem_outlined,
        title: 'Không có vận đơn lỗi',
        message: 'Hiện chưa có đơn giao thất bại hoặc hoàn trả cần xử lý lại.',
      ),
    };
  }

  DeliveryStatus _mapDeliveryStatus(OrderModel order) {
    final value = order.deliveryStatus.isNotEmpty
        ? order.deliveryStatus
        : order.status;
    return switch (value.toUpperCase()) {
      'PAID' ||
      'PENDING' ||
      'CONFIRMED' ||
      'WAITING_PICKUP' => DeliveryStatus.waitingPickup,
      'PACKING' || 'PICKED_UP' => DeliveryStatus.pickedUp,
      'IN_TRANSIT' => DeliveryStatus.inTransit,
      'SHIPPED' ||
      'SHIPPING' ||
      'OUT_FOR_DELIVERY' => DeliveryStatus.outForDelivery,
      'DELIVERED' || 'COMPLETED' => DeliveryStatus.delivered,
      'CANCELLED' || 'RETURNED' => DeliveryStatus.returned,
      'FAILED' => DeliveryStatus.failed,
      _ => DeliveryStatus.waitingPickup,
    };
  }
}
