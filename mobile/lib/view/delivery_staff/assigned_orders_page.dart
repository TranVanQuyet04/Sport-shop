import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/delivery_staff/delivery_orders_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/common/delivery_status.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class AssignedOrdersPage extends StatefulWidget {
  const AssignedOrdersPage({super.key});

  @override
  State<AssignedOrdersPage> createState() => _AssignedOrdersPageState();
}

class _AssignedOrdersPageState extends State<AssignedOrdersPage> {
  late final DeliveryOrdersController _controller = DeliveryOrdersController(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadOrders,
        child: _buildBody(),
      ),
      bottomNavigationBar: const DeliveryBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildBody() {
    final orders = _controller.assignedOrders;
    if (_controller.isLoading && orders.isEmpty) {
      return const AppLoadingState(title: 'Đang tải đơn giao hàng');
    }
    if (_controller.errorMessage != null && orders.isEmpty) {
      return AppErrorState(
        title: 'Không tải được đơn giao',
        message: _controller.errorMessage!,
        onAction: _controller.loadOrders,
      );
    }
    if (orders.isEmpty) {
      return const AppEmptyState(title: 'Chưa có đơn được giao');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: orders.length + 4 + (_controller.errorMessage == null ? 0 : 1),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            'Đơn hàng được giao',
            style: AppTextStyles.display.copyWith(fontSize: 30),
          );
        }
        if (index == 1) {
          return Text(
            'Theo dõi các đơn đã bàn giao cho bạn trong ca hiện tại.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          );
        }
        if (index == 2 && _controller.errorMessage != null) {
          return _DeliveryErrorBanner(
            message: _controller.errorMessage!,
            onRefresh: _controller.loadOrders,
          );
        }
        final contentIndex = _controller.errorMessage == null
            ? index
            : index - 1;
        if (contentIndex == 2) {
          return const AppTextField(
            label: 'Tìm kiếm',
            hintText: 'Tìm mã đơn hoặc địa chỉ',
            prefixIcon: Icons.search,
            suffixIcon: Icons.tune,
          );
        }
        if (contentIndex == 3) {
          return const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _FilterChip(label: 'Tất cả', selected: true),
              _FilterChip(label: 'SHIPPED'),
              _FilterChip(label: 'COMPLETED'),
            ],
          );
        }
        final order = orders[contentIndex - 4];
        return _AssignedOrderCard(
          order: order,
          onTap: () => context.go('/delivery-staff/orders/${order.id}/status'),
        );
      },
    );
  }
}

class _DeliveryErrorBanner extends StatelessWidget {
  const _DeliveryErrorBanner({required this.message, required this.onRefresh});

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
            TextButton(onPressed: onRefresh, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: selected ? AppColors.primary : AppColors.surface,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    );
  }
}

class _AssignedOrderCard extends StatelessWidget {
  const _AssignedOrderCard({required this.order, required this.onTap});

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final orderStatus = OrderStatus.fromApi(order.status);
    final deliveryStatus = orderStatus == OrderStatus.completed
        ? DeliveryStatus.delivered
        : DeliveryStatus.outForDelivery;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('#${order.id}', style: AppTextStyles.title)),
              DeliveryStatusBadge(status: deliveryStatus),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            order.recipientName.isEmpty ? 'Khách hàng' : order.recipientName,
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            order.shippingAddress,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call),
                  label: Text(
                    order.phoneNumber.isEmpty ? 'Gọi khách' : order.phoneNumber,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton.filled(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

