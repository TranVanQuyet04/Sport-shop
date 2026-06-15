import 'package:flutter/material.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../controller/admin/admin_orders_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/customer/order_model.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminOrderAssignmentPage extends StatefulWidget {
  const AdminOrderAssignmentPage({super.key});

  @override
  State<AdminOrderAssignmentPage> createState() =>
      _AdminOrderAssignmentPageState();
}

class _AdminOrderAssignmentPageState extends State<AdminOrderAssignmentPage> {
  late final AdminOrdersController _ordersController = AdminOrdersController(
    orderRepository: AppDependencies.instance.orderRepository,
  );
  late final AdminCatalogController _catalogController = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  final Map<String, AdminUserModel> _assignedStaffByOrderId = {};
  String? _assignmentErrorMessage;

  @override
  void initState() {
    super.initState();
    _ordersController.addListener(_onControllerChanged);
    _catalogController.addListener(_onControllerChanged);
    _loadData();
  }

  @override
  void dispose() {
    _ordersController
      ..removeListener(_onControllerChanged)
      ..dispose();
    _catalogController
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _ordersController.loadOrders(),
      _catalogController.loadUsers(),
    ]);
    await _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      final response = await AppDependencies.instance.apiClient.getJson(
        '/admin/order-assignments',
      );
      final data = response['data'];
      if (data is! List) {
        return;
      }
      final usersById = {
        for (final user in _catalogController.users) user.id: user,
      };
      final assignments = <String, AdminUserModel>{};
      for (final item in data) {
        if (item is! Map) {
          continue;
        }
        final orderId = item['orderId']?.toString();
        final staffId = item['staffId']?.toString();
        final staff = staffId == null ? null : usersById[staffId];
        if (orderId != null && staff != null) {
          assignments[orderId] = staff;
        }
      }
      if (mounted) {
        setState(() {
          _assignmentErrorMessage = null;
          _assignedStaffByOrderId
            ..clear()
            ..addAll(assignments);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _assignmentErrorMessage = error.toString());
      }
    }
  }

  List<OrderModel> get _assignableOrders {
    return _ordersController.orders.where((order) {
      final status = order.status.toUpperCase();
      return status == 'PENDING' ||
          status == 'CONFIRMED' ||
          status == 'PACKING' ||
          status == 'SHIPPED';
    }).toList();
  }

  List<AdminUserModel> get _staffUsers {
    return _catalogController.users.where((user) {
      final role = user.roleName.toUpperCase();
      return user.status &&
          (role == 'SHOP_STAFF' ||
              role == 'DELIVERY_STAFF' ||
              role == 'SHIPPER' ||
              role == 'STAFF');
    }).toList();
  }

  Future<void> _assignOrder(OrderModel order) async {
    final selectedStaff = await showModalBottomSheet<AdminUserModel>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          _StaffPickerSheet(order: order, staffUsers: _staffUsers),
    );
    if (selectedStaff == null) {
      return;
    }
    try {
      await AppDependencies.instance.apiClient.putJson(
        '/admin/order-assignments/orders/${order.id.replaceAll('#', '')}',
        data: {
          'staffId': int.parse(selectedStaff.id),
          'note': 'Assigned from mobile admin',
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      return;
    }
    setState(() => _assignedStaffByOrderId[order.id] = selectedStaff);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã gán đơn #${order.id} cho ${selectedStaff.fullName}.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        (_ordersController.isLoading || _catalogController.isLoading) &&
        _assignableOrders.isEmpty;
    final errorMessage =
        _ordersController.errorMessage ??
        _catalogController.errorMessage ??
        _assignmentErrorMessage;

    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: isLoading
            ? const AppLoadingState(title: 'Đang tải đơn hàng')
            : errorMessage != null && _assignableOrders.isEmpty
            ? AppErrorState(
                title: 'Không tải được phân công',
                message: errorMessage,
                onAction: _loadData,
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _Title(count: _assignableOrders.length),
                  const SizedBox(height: AppSpacing.xl),
                  if (_assignableOrders.isEmpty)
                    const AppEmptyState(
                      title: 'Không có đơn cần phân công',
                      message:
                          'Các đơn PENDING, CONFIRMED, PACKING hoặc SHIPPED sẽ hiển thị tại đây.',
                    )
                  else
                    ..._assignableOrders.map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: _AssignmentCard(
                          order: order,
                          assignedStaff: _assignedStaffByOrderId[order.id],
                          onAssign: () => _assignOrder(order),
                        ),
                      ),
                    ),
                ],
              ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phân công đơn hàng',
          style: AppTextStyles.display.copyWith(fontSize: 38),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text.rich(
          TextSpan(
            text: 'Có ',
            style: AppTextStyles.body.copyWith(fontSize: 20),
            children: [
              TextSpan(
                text: '$count',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const TextSpan(text: ' đơn hàng có thể phân công.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.order,
    required this.assignedStaff,
    required this.onAssign,
  });

  final OrderModel order;
  final AdminUserModel? assignedStaff;
  final VoidCallback onAssign;

  bool get _urgent {
    final date = order.orderDate;
    if (date == null) {
      return order.status.toUpperCase() == 'PENDING';
    }
    return DateTime.now().difference(date).inHours >= 24;
  }

  @override
  Widget build(BuildContext context) {
    final priority = _urgent ? 'GẤP' : 'TIÊU CHUẨN';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'MÃ ĐƠN #${order.id}',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Chip(
                  label: Text(priority),
                  backgroundColor: _urgent
                      ? const Color(0xFFFCE8EE)
                      : AppColors.surfaceMuted,
                  labelStyle: TextStyle(
                    color: _urgent
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(order.firstProductName, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    order.shippingAddress.isEmpty
                        ? 'Chưa có địa chỉ giao hàng'
                        : order.shippingAddress,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: assignedStaff == null
                      ? Text(
                          'Chưa có người xử lý',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : _Assignee(staff: assignedStaff!),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(150, 56),
                  ),
                  onPressed: onAssign,
                  child: Text(
                    assignedStaff == null ? 'Gán người xử lý' : 'Đổi người',
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

class _Assignee extends StatelessWidget {
  const _Assignee({required this.staff});

  final AdminUserModel staff;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 24, child: Icon(Icons.person)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(staff.fullName, style: AppTextStyles.subtitle),
              Text(
                staff.roleName,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StaffPickerSheet extends StatelessWidget {
  const _StaffPickerSheet({required this.order, required this.staffUsers});

  final OrderModel order;
  final List<AdminUserModel> staffUsers;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn nhân viên xử lý',
              style: AppTextStyles.display.copyWith(fontSize: 30),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Đơn #${order.id} • ${order.firstProductName}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (staffUsers.isEmpty)
              const AppEmptyState(
                title: 'Chưa có nhân viên hoạt động',
                message:
                    'Tạo user SHOP_STAFF hoặc DELIVERY_STAFF đang hoạt động để phân công.',
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: staffUsers.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final staff = staffUsers[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        staff.fullName,
                        style: AppTextStyles.subtitle,
                      ),
                      subtitle: Text(staff.roleName),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pop(context, staff),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
