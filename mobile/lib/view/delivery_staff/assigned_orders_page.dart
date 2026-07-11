import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/hover_effect.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/common/delivery_status.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../../presenter/delivery_staff/delivery_orders_presenter.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class AssignedOrdersPage extends StatefulWidget {
  const AssignedOrdersPage({super.key});

  @override
  State<AssignedOrdersPage> createState() => _AssignedOrdersPageState();
}

class _AssignedOrdersPageState extends State<AssignedOrdersPage> {
  late final DeliveryOrdersPresenter _presenter = DeliveryOrdersPresenter(
    orderRepository: AppDependencies.instance.orderRepository,
    deliveryOperationsRepository:
        AppDependencies.instance.deliveryOperationsRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadOrders();
    _presenter.startAutoRefresh();
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shipperBackground,
      appBar: const AdminAppBar(variant: AdminAppBarVariant.shipper),
      body: RefreshIndicator(
        onRefresh: _presenter.loadOrders,
        child: _buildBody(),
      ),
      bottomNavigationBar: const DeliveryBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildBody() {
    final orders = _presenter.assignedOrders;
    if (_presenter.isLoading && orders.isEmpty) {
      return const AppLoadingState(title: 'Đang tải đơn giao hàng');
    }
    if (_presenter.errorMessage != null && orders.isEmpty) {
      return AppErrorState(
        title: 'Không tải được đơn giao',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadOrders,
      );
    }
    if (orders.isEmpty) {
      return const AppEmptyState(title: 'Chưa có đơn được giao');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: orders.length + 4 + (_presenter.errorMessage == null ? 0 : 1),
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
        if (index == 2 && _presenter.errorMessage != null) {
          return _DeliveryErrorBanner(
            message: _presenter.errorMessage!,
            onRefresh: _presenter.loadOrders,
          );
        }
        final contentIndex = _presenter.errorMessage == null
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
              _FilterChip(label: 'CANCELLED'),
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
      backgroundColor: selected ? AppColors.info : AppColors.surface,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      side: BorderSide(color: selected ? AppColors.info : AppColors.border),
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
    final deliveryStatus = order.deliveryStatus.isNotEmpty
        ? DeliveryStatus.fromApi(order.deliveryStatus)
        : orderStatus == OrderStatus.delivered ||
              orderStatus == OrderStatus.completed
        ? DeliveryStatus.delivered
        : orderStatus == OrderStatus.cancelled
        ? DeliveryStatus.returned
        : DeliveryStatus.outForDelivery;
    return HoverLift(
      interactive: true,
      scale: 1.01,
      dy: -2,
      borderRadius: SuperSportsTheme.borderRadius,
      child: Material(
        color: Colors.transparent,
        borderRadius: SuperSportsTheme.borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.secondary.withValues(alpha: 0.045),
              ],
            ),
            borderRadius: SuperSportsTheme.borderRadius,
            border: Border.all(color: AppColors.successBorder),
            boxShadow: AppElevation.role(AppColors.secondary),
          ),
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.secondary.withValues(alpha: 0.10),
            highlightColor: AppColors.secondary.withValues(alpha: 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${order.id}',
                        style: AppTextStyles.title.copyWith(
                          color: SuperSportsTheme.colorPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    DeliveryStatusBadge(status: deliveryStatus),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  order.recipientName.isEmpty
                      ? 'Khách hàng'
                      : order.recipientName,
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  order.shippingAddress,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.call),
                        label: Text(
                          order.phoneNumber.isEmpty
                              ? 'Gọi khách'
                              : order.phoneNumber,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    IconButton.filled(
                      onPressed: onTap,
                      icon: const Icon(Icons.arrow_forward),
                      style: IconButton.styleFrom(
                        backgroundColor: SuperSportsTheme.colorAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
