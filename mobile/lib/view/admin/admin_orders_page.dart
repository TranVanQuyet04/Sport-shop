import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controller/admin/admin_orders_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(largeLogo: true),
      body: RefreshIndicator(
        onRefresh: _controller.loadOrders,
        child: _buildBody(),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.orders.isEmpty) {
      return const AppLoadingState(title: 'Đang tải đơn hàng');
    }
    if (_controller.errorMessage != null && _controller.orders.isEmpty) {
      return AppErrorState(
        title: 'Không tải được đơn hàng',
        message: _controller.errorMessage!,
        onAction: _controller.loadOrders,
      );
    }
    if (_controller.orders.isEmpty) {
      return const AppEmptyState(title: 'Chưa có đơn hàng');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _controller.orders.length + 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _AdminTitle(
            title: 'Quản lý đơn hàng',
            count: '${_controller.orders.length}',
          );
        }
        if (index == 1) {
          return const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm kiếm mã đơn, tên khách hàng...',
            ),
          );
        }
        if (index == 2) {
          return const _OrderTabs();
        }
        return _AdminOrderCard(
          order: _controller.orders[index - 3],
          isBusy: _controller.isUpdating,
          onNextStatus: _controller.updateOrderStatus,
        );
      },
    );
  }
}

class _AdminTitle extends StatelessWidget {
  const _AdminTitle({required this.title, this.count});

  final String title;
  final String? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.display.copyWith(fontSize: 32),
          ),
        ),
        if (count != null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                count!,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OrderTabs extends StatelessWidget {
  const _OrderTabs();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            [
                  'Tất cả',
                  'Chờ xác nhận',
                  'Đang đóng gói',
                  'Đang giao',
                  'Hoàn thành',
                ]
                .map(
                  (tab) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    child: Text(
                      tab,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w900,
                        color: tab == 'Tất cả'
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({
    required this.order,
    required this.isBusy,
    required this.onNextStatus,
  });

  final OrderModel order;
  final bool isBusy;
  final Future<void> Function(String orderId, String status) onNextStatus;

  @override
  Widget build(BuildContext context) {
    final status = OrderStatus.fromApi(order.status);
    final nextStatus = _nextStatus(status);
    final priceText = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(order.totalAmount);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${order.id}',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                OrderStatusBadge(status: status),
              ],
            ),
            Text(
              order.recipientName.isEmpty ? 'Khách hàng' : order.recipientName,
              style: AppTextStyles.title,
            ),
            if (order.phoneNumber.isNotEmpty)
              Text(
                order.phoneNumber,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.directions_run,
                    color: AppColors.secondary,
                    size: 48,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.firstProductName,
                        style: AppTextStyles.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${order.totalItems} sản phẩm',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        order.paymentMethod,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng thanh toán',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$priceTextđ',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: AppButton(
                    label: nextStatus == null
                        ? 'Hoàn tất'
                        : _actionLabel(nextStatus),
                    variant: nextStatus == null
                        ? AppButtonVariant.outline
                        : AppButtonVariant.primary,
                    isLoading: isBusy,
                    onPressed: nextStatus == null
                        ? null
                        : () => onNextStatus(order.id, nextStatus.apiValue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  OrderStatus? _nextStatus(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => OrderStatus.confirmed,
      OrderStatus.confirmed => OrderStatus.packing,
      OrderStatus.packing => OrderStatus.shipped,
      OrderStatus.shipped => OrderStatus.completed,
      OrderStatus.completed => null,
      OrderStatus.cancelled => null,
    };
  }

  String _actionLabel(OrderStatus status) {
    return switch (status) {
      OrderStatus.confirmed => 'Xác nhận',
      OrderStatus.packing => 'Đóng gói',
      OrderStatus.shipped => 'Bàn giao',
      OrderStatus.completed => 'Hoàn thành',
      _ => 'Cập nhật',
    };
  }
}
