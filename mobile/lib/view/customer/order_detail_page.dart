import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../presenter/customer/order_detail_presenter.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final OrderDetailPresenter _presenter = OrderDetailPresenter(
    orderRepository: AppDependencies.instance.orderRepository,
    orderId: widget.orderId,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadOrder();
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
    final order = _presenter.order;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _leavePage,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: RefreshIndicator(
        onRefresh: _presenter.loadOrder,
        child: _buildBody(order),
      ),
    );
  }

  Widget _buildBody(OrderModel? order) {
    if (_presenter.isLoading && order == null) {
      return const AppLoadingState(title: 'Đang tải đơn hàng');
    }
    if (_presenter.errorMessage != null && order == null) {
      return AppErrorState(
        title: 'Không tải được đơn hàng',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadOrder,
      );
    }
    if (order == null) {
      return const AppEmptyState(title: 'Không có dữ liệu đơn hàng');
    }

    final status = OrderStatus.fromApi(order.status);
    final total = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(order.totalAmount);
    final orderTime = order.orderDate == null
        ? 'Chưa có thời gian'
        : DateFormat('HH:mm, dd/MM/yyyy', 'vi_VN').format(order.orderDate!);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '#${order.id}',
                style: AppTextStyles.display.copyWith(fontSize: 30),
              ),
            ),
            OrderStatusBadge(status: status),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Đặt lúc $orderTime',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        _Panel(
          title: 'Địa chỉ nhận hàng',
          child: Text(
            '${order.recipientName} • ${order.phoneNumber}\n${order.shippingAddress}',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Panel(
          title: 'Sản phẩm',
          child: Column(
            children: order.items.isEmpty
                ? [const Text('Không có sản phẩm trong đơn hàng.')]
                : order.items
                      .map((item) => _OrderItemTile(item: item))
                      .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Panel(
          title: 'Thanh toán',
          child: Column(
            children: [
              _PriceLine(label: 'Phương thức', value: order.paymentMethod),
              _PriceLine(label: 'Tổng thanh toán', value: '$totalđ'),
              if (order.note.isNotEmpty)
                _PriceLine(label: 'Ghi chú', value: order.note),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Theo dõi hành trình',
          variant: AppButtonVariant.secondary,
          onPressed: () => context.go('/customer/orders/${order.id}/tracking'),
        ),
        const SizedBox(height: AppSpacing.md),
        if (status == OrderStatus.delivered ||
            status == OrderStatus.completed)
          AppButton(
            label: status == OrderStatus.completed
                ? 'Đã hoàn thành'
                : 'Xác nhận đã nhận hàng',
            variant: AppButtonVariant.outline,
            isLoading: _presenter.isUpdating,
            onPressed: status == OrderStatus.completed
                ? null
                : () => context.go(
                    '/customer/orders/${order.id}/confirm-received',
                  ),
          )
        else if (status == OrderStatus.pending)
          AppButton(
            label: 'Hủy đơn hàng',
            variant: AppButtonVariant.outline,
            isLoading: _presenter.isUpdating,
            onPressed: _cancelOrder,
          ),
      ],
    );
  }

  Future<void> _cancelOrder() async {
    final success = await _presenter.cancelOrder();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã hủy đơn hàng.'
              : _presenter.errorMessage ?? 'Không thể hủy đơn.',
        ),
      ),
    );
  }

  void _leavePage() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.orders);
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    final price = NumberFormat.decimalPattern('vi_VN').format(item.subTotal);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.variantImage.isEmpty
                ? const Icon(
                    Icons.directions_run,
                    color: AppColors.secondary,
                    size: 42,
                  )
                : Image.network(
                    item.variantImage,
                    fit: BoxFit.cover,
                    webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.directions_run,
                      color: AppColors.secondary,
                      size: 42,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: AppTextStyles.subtitle),
                Text(
                  item.variantLabel,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$priceđ x${item.quantity}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
            Text(title, style: AppTextStyles.subtitle),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
