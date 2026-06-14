import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/customer/order_detail_controller.dart';
import '../../controller/delivery_staff/delivery_orders_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
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
  late final OrderDetailController _orderController = OrderDetailController(
    orderRepository: AppDependencies.instance.orderRepository,
    orderId: widget.orderId,
    useAdminOrders: true,
  );
  late final DeliveryOrdersController _deliveryController =
      DeliveryOrdersController(
        orderRepository: AppDependencies.instance.orderRepository,
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
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _orderController.loadOrder,
        child: _buildBody(_orderController.order),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: 'Cập nhật: Đã giao thành công',
                icon: Icons.check_circle_outline,
                isLoading: _deliveryController.isUpdating,
                onPressed: _completeDelivery,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Báo cáo giao thất bại',
                icon: Icons.report_problem_outlined,
                variant: AppButtonVariant.outline,
                onPressed: () => context.go(
                  '/delivery-staff/orders/${widget.orderId}/failed-report',
                ),
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
      return const AppLoadingState(title: 'Đang tải đơn giao hàng');
    }
    if (_orderController.errorMessage != null && order == null) {
      return AppErrorState(
        title: 'Không tải được đơn',
        message: _orderController.errorMessage!,
        onAction: _orderController.loadOrder,
      );
    }
    if (order == null) {
      return const AppEmptyState(title: 'Không có dữ liệu đơn hàng');
    }
    final status = OrderStatus.fromApi(order.status);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Cập nhật vận chuyển',
          style: AppTextStyles.display.copyWith(fontSize: 30),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Đơn #${order.id}',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
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
                  'Lộ trình: Cửa hàng -> ${order.shippingAddress}',
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
          subtitle: 'Đơn đã được bàn giao cho nhân viên giao hàng',
          done:
              status == OrderStatus.shipped || status == OrderStatus.completed,
          active: status == OrderStatus.shipped,
        ),
        _DeliveryStep(
          title: 'COMPLETED',
          subtitle: 'Giao thành công cho khách',
          done: status == OrderStatus.completed,
          active: status == OrderStatus.completed,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Ghi chú nhanh', style: AppTextStyles.subtitle),
        const SizedBox(height: AppSpacing.sm),
        const AppTextField(
          label: 'Ghi chú',
          maxLines: 3,
          prefixIcon: Icons.edit_note_outlined,
          hintText: 'Ví dụ: Khách hẹn nhận sau 15 phút...',
        ),
      ],
    );
  }

  Future<void> _completeDelivery() async {
    final success = await _deliveryController.completeDelivery(widget.orderId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã cập nhật giao hàng thành công.'
              : _deliveryController.errorMessage ?? 'Không thể cập nhật.',
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
    final color = done || active ? AppColors.secondary : AppColors.border;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
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
              color: active ? const Color(0xFFFCE8EE) : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: active ? AppColors.secondary : AppColors.border,
              ),
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
