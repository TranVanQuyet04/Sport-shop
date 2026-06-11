import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../controller/customer/orders_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import 'widgets/customer_bottom_nav.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final OrdersController _controller = OrdersController(
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Đơn hàng',
          style: AppTextStyles.display.copyWith(fontSize: 28),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _controller.isLoading ? null : _controller.loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadOrders,
        child: _buildBody(),
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.orders.isEmpty) {
      return const AppLoadingState(
        title: 'Đang tải đơn hàng',
        message: 'Sportshop đang lấy lịch sử đơn hàng của bạn.',
      );
    }

    if (_controller.errorMessage != null && _controller.orders.isEmpty) {
      return AppErrorState(
        title: 'Không tải được đơn hàng',
        message: _controller.errorMessage!,
        onAction: _controller.loadOrders,
      );
    }

    if (_controller.orders.isEmpty) {
      return AppEmptyState(
        title: 'Bạn chưa có đơn hàng',
        message: 'Các đơn hàng sau khi thanh toán sẽ xuất hiện tại đây.',
        actionLabel: 'Tiếp tục mua sắm',
        onAction: () => context.go('/customer/home'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _OrderTabs();
        }
        final order = _controller.orders[index - 1];
        return _OrderCard(order: order);
      },
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemCount: _controller.orders.length + 1,
    );
  }
}

class _OrderTabs extends StatelessWidget {
  const _OrderTabs();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _OrderTab(label: 'Tất cả', active: true),
          _OrderTab(label: 'Chờ xác nhận'),
          _OrderTab(label: 'Đang giao'),
          _OrderTab(label: 'Đã giao'),
        ],
      ),
    );
  }
}

class _OrderTab extends StatelessWidget {
  const _OrderTab({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w900,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 72,
            height: 3,
            color: active ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final status = OrderStatus.fromApi(order.status);
    final priceText = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(order.totalAmount);
    final timeText = order.orderDate == null
        ? 'Chưa có thời gian'
        : DateFormat('HH:mm, dd/MM/yyyy', 'vi_VN').format(order.orderDate!);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã đơn: #${order.id}',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        timeText,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                OrderStatusBadge(status: status),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.directions_run,
                    color: AppColors.secondary,
                    size: 44,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.firstProductName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title,
                      ),
                      Text(
                        '${order.totalItems} sản phẩm • ${order.paymentMethod}',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text('$priceTextđ', style: AppTextStyles.subtitle),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
                Text('Tổng thanh toán:', style: AppTextStyles.body),
                const Spacer(),
                Text(
                  '$priceTextđ',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Chi tiết',
                    variant: AppButtonVariant.outline,
                    onPressed: () => context.go('/customer/orders/${order.id}'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: status == OrderStatus.completed
                        ? 'Đánh giá'
                        : 'Theo dõi',
                    onPressed: () =>
                        context.go('/customer/orders/${order.id}/tracking'),
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
