import 'package:flutter/material.dart';

import '../../controller/customer/order_detail_controller.dart';
import '../../controller/delivery_staff/delivery_orders_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class DeliveryStatusUpdatePage extends StatefulWidget {
  const DeliveryStatusUpdatePage({super.key, required this.orderId});

  final String orderId;

  @override
  State<DeliveryStatusUpdatePage> createState() =>
      _DeliveryStatusUpdatePageState();
}

class _DeliveryStatusUpdatePageState extends State<DeliveryStatusUpdatePage> {
  late final OrderDetailController _orderController = OrderDetailController(
    orderRepository: AppDependencies.instance.orderRepository,
    orderId: widget.orderId,
    useAdminOrders: true,
  );
  late final DeliveryOrdersController _deliveryController =
      DeliveryOrdersController(
        orderRepository: AppDependencies.instance.orderRepository,
      );

  @override
  void initState() {
    super.initState();
    _orderController.addListener(_onControllerChanged);
    _deliveryController.addListener(_onControllerChanged);
    _orderController.loadOrder();
  }

  @override
  void dispose() {
    _orderController
      ..removeListener(_onControllerChanged)
      ..dispose();
    _deliveryController
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _orderController.order;
    final rawStatus = (order?.status ?? '').toUpperCase();
    final isShipping = rawStatus == 'SHIPPING';
    final canUpdate = rawStatus == 'PENDING' ||
        rawStatus == 'PAID' ||
        rawStatus == 'SHIPPING';
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _orderController.loadOrder,
        child: _buildBody(_orderController.order),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: isShipping ? 'Mark as delivered' : 'Start delivery',
                icon: isShipping
                    ? Icons.check_circle_outline
                    : Icons.local_shipping_outlined,
                isLoading: _deliveryController.isUpdating,
                onPressed: canUpdate
                    ? () => _updateDelivery(isShipping: isShipping)
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              const DeliveryBottomNav(selectedIndex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(OrderModel? order) {
    if (_orderController.isLoading && order == null) {
      return const AppLoadingState(title: 'Loading delivery order');
    }
    if (_orderController.errorMessage != null && order == null) {
      return AppErrorState(
        title: 'Could not load order',
        message: _orderController.errorMessage!,
        onAction: _orderController.loadOrder,
      );
    }
    if (order == null) {
      return const AppEmptyState(title: 'No order data');
    }

    final status = OrderStatus.fromApi(order.status);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Delivery update',
          style: AppTextStyles.display.copyWith(fontSize: 30),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Order #${order.id}',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.map_outlined,
                  color: Colors.white24,
                  size: 120,
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Text(
                  'Route: store -> ${order.shippingAddress}',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Order status', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.md),
        _DeliveryStep(
          title: 'SHIPPING',
          subtitle: 'The order is being delivered.',
          done:
              status == OrderStatus.shipped || status == OrderStatus.completed,
          active: status == OrderStatus.shipped,
        ),
        _DeliveryStep(
          title: 'COMPLETED',
          subtitle: 'The customer received the order.',
          done: status == OrderStatus.completed,
          active: status == OrderStatus.completed,
        ),
      ],
    );
  }

  Future<void> _updateDelivery({required bool isShipping}) async {
    final success = isShipping
        ? await _deliveryController.completeDelivery(widget.orderId)
        : await _deliveryController.startDelivery(widget.orderId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Delivery status updated.'
              : _deliveryController.errorMessage ?? 'Could not update order.',
        ),
      ),
    );
    await _orderController.loadOrder();
  }
}

class _DeliveryStep extends StatelessWidget {
  const _DeliveryStep({
    required this.title,
    required this.subtitle,
    this.done = false,
    this.active = false,
  });

  final String title;
  final String subtitle;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = done || active ? AppColors.secondary : AppColors.border;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: Icon(
                done ? Icons.check : Icons.circle,
                color: Colors.white,
                size: 14,
              ),
            ),
            Container(width: 2, height: 54, color: AppColors.border),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFCE8EE) : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: active ? AppColors.secondary : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                Text(
                  subtitle,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
