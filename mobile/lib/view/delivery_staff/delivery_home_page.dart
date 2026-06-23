import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/delivery_staff/delivery_orders_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/hover_effect.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class DeliveryHomePage extends StatefulWidget {
  const DeliveryHomePage({super.key});

  @override
  State<DeliveryHomePage> createState() => _DeliveryHomePageState();
}

class _DeliveryHomePageState extends State<DeliveryHomePage> {
  late final DeliveryOrdersController _controller = DeliveryOrdersController(
    orderRepository: AppDependencies.instance.orderRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _controller.loadOrders();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final shipping = _controller.orders
        .where(
          (order) => OrderStatus.fromApi(order.status) == OrderStatus.shipped,
        )
        .toList();
    final ready = _controller.assignedOrders
        .where(
          (order) => OrderStatus.fromApi(order.status) != OrderStatus.completed,
        )
        .toList();
    final completed = _controller.orders
        .where(
          (order) => OrderStatus.fromApi(order.status) == OrderStatus.completed,
        )
        .toList();

    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Bảng điều phối giao hàng',
              style: AppTextStyles.display.copyWith(fontSize: 32),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Dữ liệu lấy từ /api/orders/admin và cập nhật trạng thái bằng /api/orders/{id}/status.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Đang giao',
                    value: '${shipping.length}',
                    icon: Icons.local_shipping_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MetricCard(
                    label: 'Hoàn tất',
                    value: '${completed.length}',
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Xem đơn giao',
              icon: Icons.assignment_outlined,
              onPressed: () => context.go(AppRoutes.deliveryAssignedOrders),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Đơn ưu tiên', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            if (_controller.isLoading && _controller.orders.isEmpty)
              const AppLoadingState(title: 'Đang tải đơn giao')
            else if (_controller.errorMessage != null &&
                _controller.orders.isEmpty)
              AppErrorState(
                title: 'Không tải được đơn giao',
                message: _controller.errorMessage!,
                onAction: _controller.loadOrders,
              )
            else if (ready.isEmpty)
              const AppEmptyState(title: 'Không có đơn giao')
            else
              ...ready.take(5).map((order) => _DeliveryTile(order: order)),
          ],
        ),
      ),
      bottomNavigationBar: const DeliveryBottomNav(selectedIndex: 0),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => HoverLift(
    borderRadius: BorderRadius.circular(AppRadius.xl),
    child: Container(
      height: 128,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.secondary),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(value, style: AppTextStyles.display.copyWith(fontSize: 30)),
        ],
      ),
    ),
  );
}

class _DeliveryTile extends StatelessWidget {
  const _DeliveryTile({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: HoverLift(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: ListTile(
        tileColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
        onTap: () => context.go('/delivery-staff/orders/${order.id}/status'),
        leading: const CircleAvatar(child: Icon(Icons.location_on_outlined)),
        title: Text(
          '#${order.id} - ${order.status}',
          style: AppTextStyles.subtitle,
        ),
        subtitle: Text(order.shippingAddress),
        trailing: const Icon(Icons.chevron_right),
      ),
    ),
  );
}
