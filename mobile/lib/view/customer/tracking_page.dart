import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../controller/customer/order_detail_controller.dart';
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

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  late final OrderDetailController _controller = OrderDetailController(
    orderRepository: AppDependencies.instance.orderRepository,
    orderId: widget.orderId,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadOrder();
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
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Theo dõi đơn hàng',
          style: AppTextStyles.display.copyWith(fontSize: 24),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _controller.isLoading ? null : _controller.loadOrder,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadOrder,
        child: _buildBody(_controller.order),
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody(OrderModel? order) {
    if (_controller.isLoading && order == null) {
      return const AppLoadingState(title: 'Đang tải hành trình');
    }
    if (_controller.errorMessage != null && order == null) {
      return AppErrorState(
        title: 'Không tải được hành trình',
        message: _controller.errorMessage!,
        onAction: _controller.loadOrder,
      );
    }
    if (order == null) {
      return const AppEmptyState(title: 'Không có dữ liệu hành trình');
    }

    final status = OrderStatus.fromApi(order.status);
    final firstItem = order.items.isEmpty ? null : order.items.first;
    final price = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(order.totalAmount);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (_controller.errorMessage != null) ...[
          _TrackingErrorBanner(message: _controller.errorMessage!),
          const SizedBox(height: AppSpacing.lg),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
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
                        'Mã đơn hàng',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    OrderStatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '#${order.id}',
                  style: AppTextStyles.display.copyWith(fontSize: 28),
                ),
                const Divider(height: AppSpacing.xl),
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.directions_run,
                        color: AppColors.secondary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Text(
                        firstItem == null
                            ? order.firstProductName
                            : '${firstItem.productName}\n${firstItem.variantLabel}',
                        style: AppTextStyles.body,
                      ),
                    ),
                    Text('$priceđ', style: AppTextStyles.title),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          height: 190,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: const Color(0xFFC7C7C7),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Địa chỉ giao hàng',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.shippingAddress,
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.navigation),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.route, color: AppColors.secondary),
                    const SizedBox(width: AppSpacing.md),
                    Text('Hành trình đơn hàng', style: AppTextStyles.title),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                ..._timelineItems(status),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Xem chi tiết hóa đơn',
          onPressed: () => context.go('/customer/orders/${order.id}'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton.icon(
          onPressed: () => context.go('/customer/support/chat'),
          icon: const Icon(Icons.support_agent),
          label: const Text('Liên hệ hỗ trợ'),
        ),
      ],
    );
  }

  List<Widget> _timelineItems(OrderStatus status) {
    final steps = <_TimelineData>[
      _TimelineData(
        OrderStatus.pending,
        'Chờ xác nhận',
        'Đơn hàng đã được tạo và đang chờ cửa hàng xác nhận.',
      ),
      _TimelineData(
        OrderStatus.confirmed,
        'Đã xác nhận',
        'Cửa hàng đã xác nhận đơn hàng.',
      ),
      _TimelineData(
        OrderStatus.packing,
        'Đang đóng gói',
        'Sản phẩm đang được chuẩn bị và đóng gói.',
      ),
      _TimelineData(
        OrderStatus.shipped,
        'Đang giao',
        'Đơn hàng đã bàn giao cho nhân viên giao hàng.',
      ),
      _TimelineData(
        OrderStatus.completed,
        'Hoàn thành',
        'Đơn hàng đã hoàn thành.',
      ),
    ];

    final currentIndex = status == OrderStatus.cancelled
        ? 0
        : steps
              .indexWhere((step) => step.status == status)
              .clamp(0, steps.length - 1);

    if (status == OrderStatus.cancelled) {
      return [
        const _TimelineItem(
          active: true,
          last: true,
          title: 'Đã hủy',
          time: 'Hiện tại',
          subtitle: 'Đơn hàng đã bị hủy.',
        ),
      ];
    }

    return List.generate(steps.length, (index) {
      final step = steps[index];
      return _TimelineItem(
        active: index <= currentIndex,
        last: index == steps.length - 1,
        title: step.title,
        time: index == currentIndex ? 'Hiện tại' : '',
        subtitle: step.subtitle,
      );
    });
  }
}

class _TrackingErrorBanner extends StatelessWidget {
  const _TrackingErrorBanner({required this.message});

  final String message;

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
          ],
        ),
      ),
    );
  }
}

class _TimelineData {
  const _TimelineData(this.status, this.title, this.subtitle);

  final OrderStatus status;
  final String title;
  final String subtitle;
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.time,
    required this.subtitle,
    this.active = false,
    this.last = false,
  });

  final String title;
  final String time;
  final String subtitle;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: active
                    ? AppColors.secondary
                    : const Color(0xFFD7CDD0),
                child: Icon(
                  active ? Icons.check : Icons.circle,
                  size: active ? 14 : 8,
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFFD7CDD0)),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.subtitle.copyWith(
                            color: active
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: AppTextStyles.body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

