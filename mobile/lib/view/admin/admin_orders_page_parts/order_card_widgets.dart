part of '../admin_orders_page.dart';

class OrderCardWidget extends StatelessWidget {
  const OrderCardWidget({
    super.key,
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

    return AdminSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderCardHeader(order: order, status: status),
          const SizedBox(height: AppSpacing.lg),
          _CustomerInformation(order: order),
          const SizedBox(height: AppSpacing.md),
          _ProductSummaryBox(order: order),
          const SizedBox(height: AppSpacing.lg),
          const _DashedDivider(),
          const SizedBox(height: AppSpacing.lg),
          _OrderCardFooter(
            amount: '$priceTextđ',
            status: status,
            nextStatus: nextStatus,
            isBusy: isBusy,
            onPressed: nextStatus == null
                ? null
                : () => onNextStatus(order.id, nextStatus.apiValue),
          ),
        ],
      ),
    );
  }

  OrderStatus? _nextStatus(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => OrderStatus.confirmed,
      OrderStatus.confirmed => OrderStatus.packing,
      OrderStatus.packing => OrderStatus.shipped,
      OrderStatus.shipped => null,
      OrderStatus.delivered => OrderStatus.completed,
      OrderStatus.completed => null,
      OrderStatus.cancelled => null,
    };
  }
}

class _OrderCardHeader extends StatelessWidget {
  const _OrderCardHeader({required this.order, required this.status});

  final OrderModel order;
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final dateText = order.orderDate == null
        ? 'Chưa có thời gian'
        : _formatOrderDate(order.orderDate!);

    return Row(
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                '#${order.id}',
                style: AppTextStyles.subtitle.copyWith(
                  color: AdminColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: _OrderPalette.slate,
                  shape: BoxShape.circle,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 14,
                    color: _OrderPalette.slate,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    dateText,
                    style: AppTextStyles.caption.copyWith(
                      color: _OrderPalette.slate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _PremiumStatusBadge(status: status),
      ],
    );
  }

  String _formatOrderDate(DateTime date) {
    final now = DateTime.now();
    final localDate = date.toLocal();
    final isToday =
        now.year == localDate.year &&
        now.month == localDate.month &&
        now.day == localDate.day;
    return isToday
        ? 'Hôm nay ${DateFormat('HH:mm').format(localDate)}'
        : DateFormat('dd/MM/yyyy HH:mm').format(localDate);
  }
}

class _PremiumStatusBadge extends StatelessWidget {
  const _PremiumStatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final presentation = _statusPresentation(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: presentation.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        presentation.label,
        style: AppTextStyles.caption.copyWith(
          color: presentation.foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CustomerInformation extends StatelessWidget {
  const _CustomerInformation({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.recipientName.isEmpty ? 'Khách hàng' : order.recipientName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w800),
        ),
        if (order.phoneNumber.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 15,
                color: _OrderPalette.slate,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                order.phoneNumber,
                style: AppTextStyles.caption.copyWith(
                  color: _OrderPalette.slate,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ProductSummaryBox extends StatelessWidget {
  const _ProductSummaryBox({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _OrderPalette.productSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AdminColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              color: AdminColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.firstProductName.isEmpty
                      ? 'Chưa có thông tin sản phẩm'
                      : order.firstProductName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${order.totalItems} sản phẩm',
                      style: AppTextStyles.caption.copyWith(
                        color: _OrderPalette.slate,
                      ),
                    ),
                    _PaymentBadge(method: order.paymentMethod),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    final label = method.isEmpty ? 'Chưa xác định' : method.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AdminColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AdminColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OrderCardFooter extends StatelessWidget {
  const _OrderCardFooter({
    required this.amount,
    required this.status,
    required this.nextStatus,
    required this.isBusy,
    required this.onPressed,
  });

  final String amount;
  final OrderStatus status;
  final OrderStatus? nextStatus;
  final bool isBusy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        final amountWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng thanh toán',
              style: AppTextStyles.caption.copyWith(color: _OrderPalette.slate),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              amount,
              style: AppTextStyles.title.copyWith(
                color: AdminColors.accent,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
        final actionWidget = _OrderActionButton(
          label: _actionLabel(status, nextStatus),
          enabled: nextStatus != null && !isBusy,
          isLoading: isBusy,
          primary: nextStatus != null,
          onPressed: onPressed,
        );
        final assignWidget = status == OrderStatus.shipped
            ? _AssignShipperAction(
                onPressed: () => context.go(AppRoutes.adminDeliveryMonitoring),
              )
            : null;

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              amountWidget,
              const SizedBox(height: AppSpacing.md),
              if (assignWidget != null) ...[
                assignWidget,
                const SizedBox(height: AppSpacing.sm),
              ],
              actionWidget,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: amountWidget),
            const SizedBox(width: AppSpacing.lg),
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [?assignWidget, actionWidget],
              ),
            ),
          ],
        );
      },
    );
  }

  String _actionLabel(OrderStatus current, OrderStatus? next) {
    if (next == null) {
      return switch (current) {
        OrderStatus.shipped => 'Chờ shipper giao',
        OrderStatus.cancelled => 'Đã hủy',
        _ => 'Đã hoàn tất',
      };
    }
    return switch (next) {
      OrderStatus.confirmed => 'Xác nhận',
      OrderStatus.packing => 'Đóng gói',
      OrderStatus.shipped => 'Bàn giao',
      OrderStatus.delivered => 'Hoàn thành',
      OrderStatus.completed => 'Hoàn thành',
      _ => 'Cập nhật',
    };
  }
}

class _AssignShipperAction extends StatelessWidget {
  const _AssignShipperAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Gán shipper cho đơn hàng',
      child: SizedBox(
        height: 44,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.assignment_ind_outlined, size: 18),
          label: const Text('Gán shipper'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AdminColors.primary,
            side: const BorderSide(color: AdminColors.border),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
        ),
      ),
    );
  }
}
