import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controller/admin/admin_orders_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
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
      itemCount:
          _controller.orders.length +
          3 +
          (_controller.errorMessage == null ? 0 : 1),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _AdminTitle(
            title: 'Quản lý đơn hàng',
            count: '${_controller.orders.length}/${_controller.totalOrders}',
          );
        }
        if (index == 1 && _controller.errorMessage != null) {
          return _AdminInlineBanner(
            message: _controller.errorMessage!,
            onRefresh: _controller.loadOrders,
          );
        }
        final contentIndex = _controller.errorMessage == null
            ? index
            : index - 1;
        if (contentIndex == 1) {
          return const AppTextField(
            label: 'Tìm kiếm',
            prefixIcon: Icons.search,
            hintText: 'Tìm kiếm mã đơn, tên khách hàng...',
          );
        }
        if (contentIndex == 2) {
          return _OrderTabs(
            selectedStatus: _controller.selectedStatus,
            onChanged: _controller.selectStatus,
          );
        }
        return _AdminOrderCard(
          order: _controller.orders[contentIndex - 3],
          isBusy: _controller.isUpdating,
          onNextStatus: _controller.updateOrderStatus,
        );
      },
    );
  }
}

class _AdminInlineBanner extends StatelessWidget {
  const _AdminInlineBanner({required this.message, required this.onRefresh});

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
  const _OrderTabs({required this.selectedStatus, required this.onChanged});

  final OrderStatus? selectedStatus;
  final ValueChanged<OrderStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      _OrderTabItem(label: 'Tất cả'),
      _OrderTabItem(label: 'Chờ xác nhận', status: OrderStatus.pending),
      _OrderTabItem(label: 'Đã xác nhận', status: OrderStatus.confirmed),
      _OrderTabItem(label: 'Đang đóng gói', status: OrderStatus.packing),
      _OrderTabItem(label: 'Đang giao', status: OrderStatus.shipped),
      _OrderTabItem(label: 'Hoàn thành', status: OrderStatus.completed),
    ];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: tabs.map((tab) {
          final selected = selectedStatus == tab.status;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(tab.label),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => onChanged(tab.status),
              labelStyle: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OrderTabItem {
  const _OrderTabItem({required this.label, this.status});

  final String label;
  final OrderStatus? status;
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
