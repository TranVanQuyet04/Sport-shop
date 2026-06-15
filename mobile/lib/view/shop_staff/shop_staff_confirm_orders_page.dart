import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../controller/shop_staff/shop_staff_orders_controller.dart';
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
import '../admin/widgets/admin_bottom_nav.dart';

class ShopStaffConfirmOrdersPage extends StatefulWidget {
  const ShopStaffConfirmOrdersPage({super.key});

  @override
  State<ShopStaffConfirmOrdersPage> createState() =>
      _ShopStaffConfirmOrdersPageState();
}

class _ShopStaffConfirmOrdersPageState
    extends State<ShopStaffConfirmOrdersPage> {
  late final ShopStaffOrdersController _controller = ShopStaffOrdersController(
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
  Widget build(BuildContext context) => Scaffold(
    appBar: const AdminAppBar(),
    body: RefreshIndicator(
      onRefresh: _controller.loadOrders,
      child: _buildBody(),
    ),
    bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
  );

  Widget _buildBody() {
    final pendingOrders = _controller.pendingOrders;
    if (_controller.isLoading && pendingOrders.isEmpty) {
      return const AppLoadingState(title: 'Đang tải đơn chờ xác nhận');
    }
    if (_controller.errorMessage != null && pendingOrders.isEmpty) {
      return AppErrorState(
        title: 'Không tải được đơn',
        message: _controller.errorMessage!,
        onAction: _controller.loadOrders,
      );
    }
    if (pendingOrders.isEmpty) {
      return const AppEmptyState(title: 'Không có đơn chờ xác nhận');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount:
          pendingOrders.length + 4 + (_controller.errorMessage == null ? 0 : 1),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0 && _controller.errorMessage != null) {
          return _ShopStaffErrorBanner(
            message: _controller.errorMessage!,
            onRefresh: _controller.loadOrders,
          );
        }
        final contentIndex = _controller.errorMessage == null
            ? index
            : index - 1;
        if (contentIndex == 0) {
          return const AppTextField(
            label: 'Tìm kiếm',
            prefixIcon: Icons.search,
            hintText: 'Tìm đơn hàng hoặc khách hàng...',
          );
        }
        if (contentIndex == 1) {
          return Row(
            children: [
              Expanded(
                child: _TabLabel(
                  label: 'Chờ xác nhận (${pendingOrders.length})',
                  active: true,
                ),
              ),
              Expanded(
                child: _TabLabel(
                  label: 'Đã xác nhận (${_controller.confirmedOrders.length})',
                ),
              ),
            ],
          );
        }
        if (contentIndex == 2) {
          return const Divider();
        }
        if (contentIndex == 3) {
          return AppButton(
            label: 'Xác nhận hàng loạt',
            icon: Icons.done_all,
            isLoading: _controller.isUpdating,
            onPressed: _confirmAll,
          );
        }
        final order = pendingOrders[contentIndex - 4];
        return _ConfirmCard(
          order: order,
          isBusy: _controller.isUpdating,
          onDetail: () => context.go('/shop-staff/orders/${order.id}/timeline'),
          onConfirm: () =>
              _controller.updateStatus(order.id, OrderStatus.confirmed),
        );
      },
    );
  }

  Future<void> _confirmAll() async {
    for (final order in _controller.pendingOrders) {
      await _controller.updateStatus(order.id, OrderStatus.confirmed);
    }
  }
}

class _ShopStaffErrorBanner extends StatelessWidget {
  const _ShopStaffErrorBanner({required this.message, required this.onRefresh});

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

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w900,
          color: active ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Container(
        height: 3,
        color: active ? AppColors.secondary : Colors.transparent,
      ),
    ],
  );
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({
    required this.order,
    required this.isBusy,
    required this.onDetail,
    required this.onConfirm,
  });

  final OrderModel order;
  final bool isBusy;
  final VoidCallback onDetail;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(order.totalAmount);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mã đơn: #${order.id}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                  ),
                ),
              ),
              const Chip(label: Text('PENDING')),
            ],
          ),
          Text(
            order.recipientName.isEmpty ? 'Khách hàng' : order.recipientName,
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.directions_run,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.totalItems} sản phẩm',
                      style: AppTextStyles.body,
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
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Chi tiết',
                  variant: AppButtonVariant.outline,
                  onPressed: onDetail,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Xác nhận',
                  variant: AppButtonVariant.secondary,
                  isLoading: isBusy,
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

