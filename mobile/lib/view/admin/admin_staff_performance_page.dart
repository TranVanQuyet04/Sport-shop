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
import 'widgets/admin_bottom_nav.dart';

class AdminStaffPerformancePage extends StatefulWidget {
  const AdminStaffPerformancePage({super.key});

  @override
  State<AdminStaffPerformancePage> createState() =>
      _AdminStaffPerformancePageState();
}

class _AdminStaffPerformancePageState extends State<AdminStaffPerformancePage> {
  late final AdminCatalogController _catalogController = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  late final AdminOrdersController _ordersController = AdminOrdersController(
    orderRepository: AppDependencies.instance.orderRepository,
  );

  @override
  void initState() {
    super.initState();
    _catalogController.addListener(_onControllerChanged);
    _ordersController.addListener(_onControllerChanged);
    _loadData();
  }

  @override
  void dispose() {
    _catalogController
      ..removeListener(_onControllerChanged)
      ..dispose();
    _ordersController
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
      _catalogController.loadUsers(),
      _ordersController.loadOrders(),
    ]);
  }

  List<AdminUserModel> get _staffUsers {
    return _catalogController.users.where((user) {
      final role = user.roleName.toUpperCase();
      return role == 'SHOP_STAFF' ||
          role == 'DELIVERY_STAFF' ||
          role == 'SHIPPER' ||
          role == 'STAFF';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        (_catalogController.isLoading || _ordersController.isLoading) &&
        _staffUsers.isEmpty &&
        _ordersController.orders.isEmpty;
    final errorMessage =
        _catalogController.errorMessage ?? _ordersController.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hiệu suất nhân viên'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: isLoading
            ? const AppLoadingState(title: 'Đang tải hiệu suất')
            : errorMessage != null &&
                  _staffUsers.isEmpty &&
                  _ordersController.orders.isEmpty
            ? AppErrorState(
                title: 'Không tải được hiệu suất',
                message: errorMessage,
                onAction: _loadData,
              )
            : _PerformanceContent(
                staffUsers: _staffUsers,
                orders: _ordersController.orders,
              ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }
}

class _PerformanceContent extends StatelessWidget {
  const _PerformanceContent({required this.staffUsers, required this.orders});

  final List<AdminUserModel> staffUsers;
  final List<OrderModel> orders;

  int get completedOrders {
    return orders
        .where((order) => order.status.toUpperCase() == 'COMPLETED')
        .length;
  }

  int get activeStaff {
    return staffUsers.where((user) => user.status).length;
  }

  double get successRate {
    if (orders.isEmpty) {
      return 0;
    }
    return completedOrders / orders.length * 100;
  }

  @override
  Widget build(BuildContext context) {
    final ordersPerStaff = activeStaff == 0
        ? 0
        : (orders.length / activeStaff).round();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const _Title(),
        const SizedBox(height: AppSpacing.lg),
        if (_hasInfoMessage) ...[
          _PerformanceInfoBanner(message: _infoMessage),
          const SizedBox(height: AppSpacing.lg),
        ],
        const _Segmented(),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _Metric(
                icon: Icons.shopping_cart_outlined,
                title: 'Tổng đơn hàng',
                value: '${orders.length}',
                growth: 'API thật',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _Metric(
                icon: Icons.verified_outlined,
                title: 'Tỷ lệ hoàn thành',
                value: '${successRate.toStringAsFixed(1)}%',
                growth: '$completedOrders hoàn tất',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _ProcessTime(ordersPerStaff: ordersPerStaff, activeStaff: activeStaff),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Xu hướng hiệu suất',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              'THEO ĐƠN HÀNG',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _ChartPlaceholder(orders: orders),
        const SizedBox(height: AppSpacing.xl),
        const Text(
          'Xếp hạng nhân viên',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        if (staffUsers.isEmpty)
          const AppEmptyState(
            title: 'Chưa có nhân viên',
            message:
                'Tạo user có role SHOP_STAFF hoặc DELIVERY_STAFF để tính hiệu suất.',
          )
        else
          ...staffUsers.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _Rank(
                user: entry.value,
                ordersPerStaff: ordersPerStaff,
                rank: entry.key + 1,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Ghi chú: backend chưa có dữ liệu nhân viên nào xử lý đơn nào, nên ranking hiện chia đều theo số nhân viên đang hoạt động.',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  bool get _hasInfoMessage => staffUsers.isNotEmpty || orders.isNotEmpty;

  String get _infoMessage {
    return 'Hiệu suất đang tính từ dữ liệu người dùng/đơn hàng hiện có. Khi backend có phân công đơn theo nhân viên, ranking sẽ chính xác hơn.';
  }
}

class _PerformanceInfoBanner extends StatelessWidget {
  const _PerformanceInfoBanner({required this.message});

  final String message;

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
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Hiệu suất nhân viên',
        style: AppTextStyles.display.copyWith(fontSize: 34),
      ),
      Text(
        'Phân tích từ dữ liệu người dùng và đơn hàng hiện có.',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    ],
  );
}

class _Segmented extends StatelessWidget {
  const _Segmented();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.xs),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    child: Row(
      children: ['Ngày', 'Tuần', 'Tháng']
          .map(
            (label) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: label == 'Ngày'
                      ? AppColors.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.title,
    required this.value,
    required this.growth,
  });

  final IconData icon;
  final String title;
  final String value;
  final String growth;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          Text(value, style: AppTextStyles.display.copyWith(fontSize: 28)),
          Text(
            growth,
            style: AppTextStyles.body.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProcessTime extends StatelessWidget {
  const _ProcessTime({required this.ordersPerStaff, required this.activeStaff});

  final int ordersPerStaff;
  final int activeStaff;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.groups_outlined, color: AppColors.secondary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Nhân viên hoạt động',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$activeStaff',
                  style: AppTextStyles.display.copyWith(fontSize: 28),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TB $ordersPerStaff đơn / người',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  value: activeStaff == 0 ? 0 : 0.72,
                  color: AppColors.secondary,
                  backgroundColor: AppColors.surfaceMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.orders});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    final buckets = _lastSevenDayCounts();
    final maxValue = buckets.isEmpty
        ? 1
        : buckets.reduce((value, element) => value > element ? value : element);

    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final value = buckets[index];
            final height = 28 + (value / maxValue.clamp(1, 999)) * 110;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 24,
                  height: height,
                  decoration: BoxDecoration(
                    color: index == 6 ? AppColors.secondary : AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'T${index + 2}',
                  style: AppTextStyles.caption.copyWith(
                    color: index == 6 ? AppColors.secondary : AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  List<int> _lastSevenDayCounts() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index));
      return orders.where((order) {
        final orderDate = order.orderDate;
        if (orderDate == null) {
          return false;
        }
        return orderDate.year == day.year &&
            orderDate.month == day.month &&
            orderDate.day == day.day;
      }).length;
    });
  }
}

class _Rank extends StatelessWidget {
  const _Rank({
    required this.user,
    required this.ordersPerStaff,
    required this.rank,
  });

  final AdminUserModel user;
  final int ordersPerStaff;
  final int rank;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: const BorderSide(color: AppColors.border),
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: rank == 1 ? Colors.amber : AppColors.surfaceMuted,
        child: Text('$rank'),
      ),
      title: Text(user.fullName, style: AppTextStyles.subtitle),
      subtitle: Text('$ordersPerStaff đơn  •  ${user.roleName}'),
      trailing: Text(
        user.status ? 'Hoạt động' : 'Tạm khóa',
        style: AppTextStyles.body.copyWith(
          color: user.status ? AppColors.success : AppColors.secondary,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

