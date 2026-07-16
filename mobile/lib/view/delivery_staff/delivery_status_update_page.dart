import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../../presenter/customer/order_detail_presenter.dart';
import '../../presenter/delivery_staff/delivery_orders_presenter.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class DeliveryStatusUpdatePage extends StatefulWidget {
  const DeliveryStatusUpdatePage({super.key, required this.orderId});

  final String orderId;

  @override
  State<DeliveryStatusUpdatePage> createState() =>
      _DeliveryStatusUpdatePageState();
}

class _DeliveryStatusUpdatePageState extends State<DeliveryStatusUpdatePage> {
  late final OrderDetailPresenter _orderController = OrderDetailPresenter(
    orderRepository: AppDependencies.instance.orderRepository,
    orderId: widget.orderId,
    useAdminOrders: true,
  );
  late final DeliveryOrdersPresenter _deliveryController =
      DeliveryOrdersPresenter(
        orderRepository: AppDependencies.instance.orderRepository,
        deliveryOperationsRepository:
            AppDependencies.instance.deliveryOperationsRepository,
      );

  @override
  void initState() {
    super.initState();
    _orderController.addListener(_onControllerChanged);
    _deliveryController.addListener(_onControllerChanged);
    _orderController.loadOrder();
  }

  @override
  void dispose() {
    _orderController
      ..removeListener(_onControllerChanged)
      ..dispose();
    _deliveryController
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
    final order = _orderController.order;
    final status = OrderStatus.fromApi(order?.status);
    final canUpdate = status == OrderStatus.shipped;

    return Scaffold(
      backgroundColor: AppColors.shipperBackground,
      appBar: const AdminAppBar(variant: AdminAppBarVariant.shipper),
      body: RefreshIndicator(
        onRefresh: _orderController.loadOrder,
        child: _buildBody(order),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Giao thất bại',
                      icon: Icons.report_problem_outlined,
                      variant: AppButtonVariant.outline,
                      isLoading: _deliveryController.isUpdating,
                      onPressed: canUpdate ? _markFailed : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Đã giao hàng',
                      icon: Icons.check_circle_outline,
                      backgroundColor: SuperSportsTheme.colorAccent,
                      isLoading: _deliveryController.isUpdating,
                      onPressed: canUpdate ? _completeDelivery : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const DeliveryBottomNav(selectedIndex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(OrderModel? order) {
    if (_orderController.isLoading && order == null) {
      return const AppLoadingState(title: 'Đang tải đơn giao');
    }
    if (_orderController.errorMessage != null && order == null) {
      return AppErrorState(
        title: 'Không tải được đơn giao',
        message: _orderController.errorMessage!,
        onAction: _orderController.loadOrder,
      );
    }
    if (order == null) {
      return const AppEmptyState(title: 'Chưa có dữ liệu đơn hàng');
    }

    final status = OrderStatus.fromApi(order.status);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Cập nhật giao hàng',
          style: AppTextStyles.display.copyWith(fontSize: 30),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Đơn #${order.id}',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.info),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          constraints: const BoxConstraints(minHeight: 180),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.shipperPrimary, AppColors.secondary],
            ),
            borderRadius: SuperSportsTheme.borderRadius,
            boxShadow: AppElevation.role(AppColors.secondary),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.map_outlined,
                  color: Colors.white24,
                  size: 120,
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Text(
                  'Tuyến giao: cửa hàng -> ${order.shippingAddress}',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Trạng thái đơn hàng', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.md),
        _DeliveryStep(
          title: 'SHIPPED',
          subtitle: 'Đơn hàng đã được bàn giao cho nhân viên giao hàng.',
          done:
              status == OrderStatus.shipped ||
              status == OrderStatus.delivered ||
              status == OrderStatus.completed,
          active: status == OrderStatus.shipped,
        ),
        _DeliveryStep(
          title: 'DELIVERED',
          subtitle: 'Shipper đã giao hàng, chờ khách xác nhận đã nhận.',
          done:
              status == OrderStatus.delivered ||
              status == OrderStatus.completed,
          active: status == OrderStatus.delivered,
        ),
        _DeliveryStep(
          title: 'COMPLETED',
          subtitle: 'Admin đã chốt đơn hoàn thành.',
          done: status == OrderStatus.completed,
          active: status == OrderStatus.completed,
        ),
        if (status == OrderStatus.cancelled)
          const _DeliveryStep(
            title: 'CANCELLED',
            subtitle: 'Đơn hàng đã bị hủy hoặc giao thất bại.',
            done: true,
            active: true,
          ),
      ],
    );
  }

  Future<void> _completeDelivery() async {
    final success = await _deliveryController.completeDelivery(widget.orderId);
    await _afterStatusUpdate(success);
  }

  Future<void> _markFailed() async {
    final success = await _deliveryController.markFailed(widget.orderId);
    await _afterStatusUpdate(success);
  }

  Future<void> _afterStatusUpdate(bool success) async {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã cập nhật trạng thái giao hàng.'
              : _deliveryController.errorMessage ??
                    'Không thể cập nhật đơn hàng.',
        ),
      ),
    );
    await _orderController.loadOrder();
  }
}

class _DeliveryStep extends StatelessWidget {
  const _DeliveryStep({
    required this.title,
    required this.subtitle,
    this.done = false,
    this.active = false,
  });

  final String title;
  final String subtitle;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = done || active
        ? SuperSportsTheme.colorAccent
        : AppColors.border;
    final surface = active
        ? AppColors.secondarySoft
        : done
        ? AppColors.surface
        : AppColors.surfaceMuted.withValues(alpha: 0.72);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: SuperSportsTheme.borderRadius,
                boxShadow: active ? AppElevation.glow(color) : null,
              ),
              child: Icon(
                done ? Icons.check : Icons.circle,
                color: Colors.white,
                size: 14,
              ),
            ),
            Container(width: 2, height: 54, color: AppColors.border),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: SuperSportsTheme.borderRadius,
              border: Border.all(
                color: active || done
                    ? SuperSportsTheme.colorAccent
                    : AppColors.border,
              ),
              boxShadow: active
                  ? AppElevation.role(SuperSportsTheme.colorAccent)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                Text(
                  subtitle,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
