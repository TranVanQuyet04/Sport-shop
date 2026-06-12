import 'package:flutter/material.dart';

import '../../controller/admin/admin_orders_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/common/delivery_status.dart';
import '../../model/customer/order_model.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminDeliveryMonitoringPage extends StatefulWidget {
  const AdminDeliveryMonitoringPage({super.key});

  @override
  State<AdminDeliveryMonitoringPage> createState() =>
      _AdminDeliveryMonitoringPageState();
}

class _AdminDeliveryMonitoringPageState
    extends State<AdminDeliveryMonitoringPage> {
  late final AdminOrdersController _controller = AdminOrdersController(
    orderRepository: AppDependencies.instance.orderRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadOrders();
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

  List<OrderModel> get _deliveryOrders {
    return _controller.orders.where((order) {
      final status = order.status.toUpperCase();
      return status == 'CONFIRMED' ||
          status == 'PACKING' ||
          status == 'SHIPPED' ||
          status == 'COMPLETED' ||
          status == 'CANCELLED';
    }).toList();
  }

  Future<void> _advanceDelivery(OrderModel order) async {
    final currentStatus = order.status.toUpperCase();
    final nextStatus = currentStatus == 'SHIPPED' ? 'COMPLETED' : 'SHIPPED';
    await _controller.updateOrderStatus(order.id, nextStatus);
    if (!mounted) {
      return;
    }
    final failed = _controller.errorMessage != null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failed
              ? _controller.errorMessage!
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
      body: RefreshIndicator(
        onRefresh: _controller.loadOrders,
        child: _buildBody(orders),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: _controller.isLoading ? null : _controller.loadOrders,
        child: const Icon(Icons.refresh),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
    );
  }

  Widget _buildBody(List<OrderModel> orders) {
    if (_controller.isLoading && orders.isEmpty) {
      return const AppLoadingState(title: 'Đang tải giao hàng');
    }
    if (_controller.errorMessage != null && orders.isEmpty) {
      return AppErrorState(
        title: 'Không tải được giao hàng',
        message: _controller.errorMessage!,
        onAction: _controller.loadOrders,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const _Header(),
        const SizedBox(height: AppSpacing.lg),
        const TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Tìm mã đơn hàng hoặc địa chỉ...',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _DeliveryChip(label: 'Tất cả', active: true),
            _DeliveryChip(label: 'Đang giao'),
            _DeliveryChip(label: 'Đã giao'),
            _DeliveryChip(label: 'Lỗi/Trả lại', warning: true),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        if (orders.isEmpty)
          const AppEmptyState(
            title: 'Chưa có đơn giao hàng',
            message:
                'Các đơn đã xác nhận, đang đóng gói hoặc đang giao sẽ hiển thị tại đây.',
          )
        else
          ...orders.map(
            (order) => _DeliveryCard(
              order: order,
              status: _mapDeliveryStatus(order.status),
              onAdvance: _controller.isUpdating
                  ? null
                  : () => _advanceDelivery(order),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Ghi chú: backend chưa có deliveryStatus riêng, nên màn này đang map từ OrderStatus.',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  DeliveryStatus _mapDeliveryStatus(String orderStatus) {
    return switch (orderStatus.toUpperCase()) {
      'CONFIRMED' => DeliveryStatus.waitingPickup,
      'PACKING' => DeliveryStatus.pickedUp,
      'SHIPPED' => DeliveryStatus.outForDelivery,
      'COMPLETED' => DeliveryStatus.delivered,
      'CANCELLED' => DeliveryStatus.returned,
      _ => DeliveryStatus.waitingPickup,
    };
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Theo dõi giao hàng',
        style: AppTextStyles.display.copyWith(fontSize: 34),
      ),
      Text(
        'Giám sát trạng thái vận chuyển của các đơn hàng đang hoạt động.',
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
      ),
    ],
  );
}

class _DeliveryChip extends StatelessWidget {
  const _DeliveryChip({
    required this.label,
    this.active = false,
    this.warning = false,
  });

  final String label;
  final bool active;
  final bool warning;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(label),
    backgroundColor: active
        ? AppColors.primary
        : warning
        ? const Color(0xFFFFD9D9)
        : AppColors.surfaceMuted,
    labelStyle: TextStyle(
      color: active
          ? Colors.white
          : warning
          ? AppColors.secondary
          : AppColors.primary,
      fontWeight: FontWeight.w900,
    ),
  );
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.order,
    required this.status,
    required this.onAdvance,
  });

  final OrderModel order;
  final DeliveryStatus status;
  final VoidCallback? onAdvance;

  @override
  Widget build(BuildContext context) {
    final alert =
        status == DeliveryStatus.returned || status == DeliveryStatus.failed;
    final progress = _progressFor(status);
    final canAdvance =
        status == DeliveryStatus.waitingPickup ||
        status == DeliveryStatus.pickedUp ||
        status == DeliveryStatus.outForDelivery;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: alert
            ? const Border(
                left: BorderSide(color: AppColors.secondary, width: 4),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DeliveryStatusBadge(status: status),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '#${order.id}',
              style: AppTextStyles.display.copyWith(fontSize: 26),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              [
                order.firstProductName,
                if (order.shippingAddress.isNotEmpty)
                  'Điểm đến: ${order.shippingAddress}',
                if (order.recipientName.isNotEmpty)
                  'Người nhận: ${order.recipientName}',
                'OrderStatus: ${order.status}',
              ].join('\n'),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (alert) ...[
              const SizedBox(height: AppSpacing.md),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Đơn đang ở trạng thái cần kiểm tra lại.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            LinearProgressIndicator(
              value: progress,
              color: AppColors.secondary,
              backgroundColor: AppColors.surfaceMuted,
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
            if (canAdvance) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: onAdvance,
                child: Text(
                  status == DeliveryStatus.outForDelivery
                      ? 'ĐÁNH DẤU ĐÃ GIAO'
                      : 'BÀN GIAO / ĐANG GIAO',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _progressFor(DeliveryStatus status) {
    return switch (status) {
      DeliveryStatus.waitingPickup => 0.2,
      DeliveryStatus.pickedUp => 0.35,
      DeliveryStatus.inTransit => 0.55,
      DeliveryStatus.outForDelivery => 0.75,
      DeliveryStatus.delivered => 1,
      DeliveryStatus.failed => 0.5,
      DeliveryStatus.returned => 0.15,
    };
  }
}
