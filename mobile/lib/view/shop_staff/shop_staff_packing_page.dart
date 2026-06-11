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

class ShopStaffPackingPage extends StatefulWidget {
  const ShopStaffPackingPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<ShopStaffPackingPage> createState() => _ShopStaffPackingPageState();
}

class _ShopStaffPackingPageState extends State<ShopStaffPackingPage> {
  late final OrderDetailController _controller = OrderDetailController(
    orderRepository: AppDependencies.instance.orderRepository,
    orderId: widget.orderId,
    useAdminOrders: true,
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: context.pop,
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Text('APEX VELOCITY'),
      actions: const [
        IconButton(onPressed: null, icon: Icon(Icons.notifications_none)),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _controller.loadOrder,
      child: _buildBody(_controller.order),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppButton(
          label: 'HOÀN TẤT ĐÓNG GÓI',
          icon: Icons.inventory_2_outlined,
          isLoading: _controller.isUpdating,
          onPressed: _handover,
        ),
      ),
    ),
  );

  Widget _buildBody(OrderModel? order) {
    if (_controller.isLoading && order == null) {
      return const AppLoadingState(title: 'Đang tải đơn đóng gói');
    }
    if (_controller.errorMessage != null && order == null) {
      return AppErrorState(
        title: 'Không tải được đơn',
        message: _controller.errorMessage!,
        onAction: _controller.loadOrder,
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
          'ĐƠN HÀNG #${order.id}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w900,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                'Chi tiết đóng gói',
                style: AppTextStyles.display.copyWith(fontSize: 36),
              ),
            ),
            OrderStatusBadge(status: status),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (order.note.isNotEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: const Border(
                left: BorderSide(color: AppColors.secondary, width: 4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'GHI CHÚ KHÁCH HÀNG\n${order.note}',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: Text(
                'Danh sách sản phẩm (${order.items.length})',
                style: AppTextStyles.title,
              ),
            ),
            Text(
              '${order.items.length}/${order.items.length} ĐÃ SOẠN',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...order.items.map((item) => _PackItem(item: item)),
        const SizedBox(height: AppSpacing.xl),
        Text('Hướng dẫn đóng gói', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.md),
        const Row(
          children: [
            Expanded(
              child: _GuideBox(
                icon: Icons.inventory_2_outlined,
                label: 'Kiểm tra sản phẩm',
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _GuideBox(icon: Icons.crop_7_5, label: 'Dán tem đơn'),
            ),
          ],
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  Future<void> _handover() async {
    final order = _controller.order;
    if (order == null) {
      return;
    }
    final status = OrderStatus.fromApi(order.status);
    if (status == OrderStatus.confirmed) {
      await AppDependencies.instance.orderRepository.updateStatus(
        orderId: order.id,
        status: OrderStatus.packing.apiValue,
        asAdminOrShipper: true,
      );
    }
    await AppDependencies.instance.orderRepository.updateStatus(
      orderId: order.id,
      status: OrderStatus.shipped.apiValue,
      asAdminOrShipper: true,
    );
    if (!mounted) {
      return;
    }
    context.go('/shop-staff/orders/${order.id}/timeline');
  }
}

class _PackItem extends StatelessWidget {
  const _PackItem({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    final price = NumberFormat.decimalPattern('vi_VN').format(item.subTotal);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 92,
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
                Text(item.productName, style: AppTextStyles.subtitle),
                Text(item.variantLabel, style: AppTextStyles.body),
                Text(
                  'SL: ${item.quantity} • $priceđ',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.check_circle_outline,
              color: AppColors.secondary,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideBox extends StatelessWidget {
  const _GuideBox({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.border),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(icon, size: 34),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: AppTextStyles.subtitle),
        ],
      ),
    ),
  );
}
