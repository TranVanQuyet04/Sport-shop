import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../../presenter/customer/order_detail_presenter.dart';
import 'widgets/customer_bottom_nav.dart';

part 'tracking_page_parts/tracking_timeline_widgets.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _leavePage,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Theo dõi đơn hàng',
          style: AppTextStyles.display.copyWith(fontSize: 24),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _presenter.isLoading ? null : _presenter.loadOrder,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _presenter.loadOrder,
        child: _buildBody(_presenter.order),
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody(OrderModel? order) {
    if (_presenter.isLoading && order == null) {
      return const AppLoadingState(title: 'Đang tải hành trình');
    }
    if (_presenter.errorMessage != null && order == null) {
      return AppErrorState(
        title: 'Không tải được hành trình',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadOrder,
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
        if (_presenter.errorMessage != null) ...[
          _TrackingErrorBanner(message: _presenter.errorMessage!),
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
                    _OrderPreviewImage(imageUrl: firstItem?.variantImage ?? ''),
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
          constraints: const BoxConstraints(minHeight: 178),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primary,
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
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.shippingAddress.isEmpty
                          ? 'Chưa có địa chỉ'
                          : order.shippingAddress,
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    backgroundColor: AppColors.secondary,
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
                ..._timelineItems(order),
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

  List<Widget> _timelineItems(OrderModel order) {
    final status = OrderStatus.fromApi(order.status);
    final deliveryStatus = order.deliveryStatus.toUpperCase();
    final steps = <_TimelineData>[
      const _TimelineData(
        OrderStatus.pending,
        'Chờ xác nhận',
        'Đơn hàng đã được tạo và đang chờ cửa hàng xác nhận.',
      ),
      const _TimelineData(
        OrderStatus.confirmed,
        'Đã xác nhận',
        'Cửa hàng đã xác nhận đơn hàng.',
      ),
      const _TimelineData(
        OrderStatus.packing,
        'Đang đóng gói',
        'Sản phẩm đang được chuẩn bị và đóng gói.',
      ),
      const _TimelineData(
        OrderStatus.shipped,
        'Đang giao',
        'Đơn hàng đã bàn giao cho nhân viên giao hàng.',
      ),
      const _TimelineData(
        OrderStatus.delivered,
        'Đã giao',
        'Shipper đã giao đơn hàng. Vui lòng xác nhận khi bạn đã nhận được hàng; hệ thống sẽ tự hoàn tất sau 7 ngày.',
      ),
      const _TimelineData(
        OrderStatus.completed,
        'Hoàn thành',
        'Đơn hàng đã giao thành công.',
      ),
    ];

    if (status == OrderStatus.cancelled || deliveryStatus == 'RETURNED') {
      return const [
        _TimelineItem(
          active: true,
          last: true,
          title: 'Đã hủy',
          time: 'Hiện tại',
          subtitle: 'Đơn hàng đã bị hủy hoặc hoàn trả.',
        ),
      ];
    }

    final effectiveStatus = switch (deliveryStatus) {
      'OUT_FOR_DELIVERY' => OrderStatus.shipped,
      'DELIVERED' => OrderStatus.delivered,
      _ => status,
    };
    final currentIndex = steps
        .indexWhere((step) => step.status == effectiveStatus)
        .clamp(0, steps.length - 1);

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

  void _leavePage() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.orders);
  }
}

class _OrderPreviewImage extends StatelessWidget {
  const _OrderPreviewImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 72,
        height: 72,
        color: AppColors.surfaceMuted,
        child: imageUrl.isEmpty
            ? const Icon(
                Icons.directions_run,
                color: AppColors.secondary,
                size: 36,
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.directions_run,
                  color: AppColors.secondary,
                  size: 36,
                ),
              ),
      ),
    );
  }
}
