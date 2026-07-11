part of '../admin_delivery_monitoring_page.dart';

class DeliveryCardWidget extends StatelessWidget {
  const DeliveryCardWidget({
    super.key,
    required this.order,
    required this.status,
    required this.assignment,
    required this.isUpdating,
    required this.onAdvance,
    required this.onAssign,
  });

  final OrderModel order;
  final DeliveryStatus status;
  final DeliveryAssignmentModel? assignment;
  final bool isUpdating;
  final VoidCallback? onAdvance;
  final VoidCallback? onAssign;

  bool get _isIssue =>
      status == DeliveryStatus.returned || status == DeliveryStatus.failed;

  bool get _canAdvance =>
      status == DeliveryStatus.waitingPickup ||
      status == DeliveryStatus.pickedUp ||
      status == DeliveryStatus.inTransit ||
      status == DeliveryStatus.outForDelivery ||
      status == DeliveryStatus.delivered;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      interactive: false,
      scale: 1.01,
      dy: -2,
      borderRadius: BorderRadius.circular(AdminDesign.radius),
      child: Material(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(AdminDesign.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: null,
          splashColor: AdminColors.primary.withValues(alpha: 0.08),
          child: Ink(
            padding: AdminDesign.cardPadding,
            decoration: BoxDecoration(
              color: AdminColors.surface,
              borderRadius: BorderRadius.circular(AdminDesign.radius),
              boxShadow: AdminDesign.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DeliveryCardHeader(orderId: order.id, status: status),
                const SizedBox(height: AppSpacing.md),
                _ProductSummary(order: order),
                const SizedBox(height: AppSpacing.md),
                _DeliveryInfo(order: order),
                const SizedBox(height: AppSpacing.md),
                _AssignmentInfo(assignment: assignment, onAssign: onAssign),
                if (_isIssue) ...[
                  const SizedBox(height: AppSpacing.md),
                  const _IssueNotice(),
                ],
                const SizedBox(height: AppSpacing.lg),
                DeliveryStatusStepper(status: status),
                if (_canAdvance) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onAdvance,
                      icon: isUpdating
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              status == DeliveryStatus.outForDelivery
                                  ? Icons.task_alt_rounded
                                  : status == DeliveryStatus.delivered
                                  ? Icons.task_alt_rounded
                                  : Icons.local_shipping_outlined,
                            ),
                      label: Text(
                        status == DeliveryStatus.outForDelivery
                            ? 'Đánh dấu đã giao'
                            : status == DeliveryStatus.delivered
                            ? 'Chốt hoàn thành'
                            : 'Bàn giao cho đơn vị vận chuyển',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignmentInfo extends StatelessWidget {
  const _AssignmentInfo({required this.assignment, required this.onAssign});

  final DeliveryAssignmentModel? assignment;
  final VoidCallback? onAssign;

  @override
  Widget build(BuildContext context) {
    final assigned = assignment != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: assigned ? AdminColors.greenSoft : AdminColors.orangeSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: assigned
              ? AdminColors.green.withValues(alpha: 0.22)
              : AdminColors.orange.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        children: [
          Icon(
            assigned
                ? Icons.assignment_ind_outlined
                : Icons.person_add_alt_1_outlined,
            size: 18,
            color: assigned ? AdminColors.green : AdminColors.orange,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              assigned
                  ? 'Đã gán: ${assignment!.staffName.isEmpty ? 'Shipper #${assignment!.staffId}' : assignment!.staffName}'
                  : 'Chưa gán shipper nên nhân viên giao hàng chưa thấy đơn này.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: assigned
                    ? const Color(0xFF166534)
                    : const Color(0xFF9A3412),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: onAssign,
            child: Text(assigned ? 'Đổi' : 'Gán'),
          ),
        ],
      ),
    );
  }
}

class _DeliveryCardHeader extends StatelessWidget {
  const _DeliveryCardHeader({required this.orderId, required this.status});

  final String orderId;
  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AdminColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(
            Icons.local_shipping_outlined,
            color: AdminColors.primary,
            size: 21,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'Đơn hàng #$orderId',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AdminColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _DeliveryStatusPill(status: status),
      ],
    );
  }
}

class _DeliveryStatusPill extends StatelessWidget {
  const _DeliveryStatusPill({required this.status});

  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final presentation = _statusPresentation(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: presentation.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        presentation.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: presentation.foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final productName = order.firstProductName.isEmpty
        ? 'Chưa có thông tin sản phẩm'
        : order.firstProductName;
    return Row(
      children: [
        const Icon(
          Icons.inventory_2_outlined,
          size: 16,
          color: AdminColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AdminColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${order.totalItems} sản phẩm',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AdminColors.textSecondary),
        ),
      ],
    );
  }
}

class _DeliveryInfo extends StatelessWidget {
  const _DeliveryInfo({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AdminColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_outline_rounded,
            child: Text(
              order.recipientName.isEmpty
                  ? 'Chưa có tên người nhận'
                  : order.recipientName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AdminColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (order.phoneNumber.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              icon: Icons.phone_outlined,
              child: Text(
                order.phoneNumber,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AdminColors.textSecondary,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.location_on_outlined,
            alignStart: true,
            child: Text(
              order.shippingAddress.isEmpty
                  ? 'Chưa có địa chỉ giao hàng'
                  : order.shippingAddress,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AdminColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.child,
    this.alignStart = false,
  });

  final IconData icon;
  final Widget child;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: alignStart
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 17, color: AdminColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: child),
      ],
    );
  }
}

class _IssueNotice extends StatelessWidget {
  const _IssueNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFBE123C),
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Vận đơn cần được kiểm tra và xử lý lại.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF9F1239),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
