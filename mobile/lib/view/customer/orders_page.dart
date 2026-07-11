import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../presenter/customer/orders_presenter.dart';
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

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _selectedTabIndex = 0;
  late final OrdersPresenter _presenter = OrdersPresenter(
    orderRepository: AppDependencies.instance.orderRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadOrders();
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customer/home');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Đơn hàng',
          style: AppTextStyles.display.copyWith(fontSize: 28),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _presenter.isLoading ? null : _presenter.loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _presenter.loadOrders,
        child: _buildBody(),
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody() {
    if (_presenter.isLoading && _presenter.orders.isEmpty) {
      return const AppLoadingState(
        title: 'Đang tải đơn hàng',
        message: 'StrideX đang lấy lịch sử đơn hàng của bạn.',
      );
    }

    if (_presenter.errorMessage != null && _presenter.orders.isEmpty) {
      return AppErrorState(
        title: 'Không tải được đơn hàng',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadOrders,
      );
    }

    if (_presenter.orders.isEmpty) {
      return AppEmptyState(
        title: 'Bạn chưa có đơn hàng',
        message: 'Các đơn hàng sau khi thanh toán sẽ xuất hiện tại đây.',
        actionLabel: 'Tiếp tục mua sắm',
        onAction: () => context.go('/customer/home'),
      );
    }

    final filteredOrders = _presenter.orders.where((order) {
      final status = OrderStatus.fromApi(order.status);
      return switch (_selectedTabIndex) {
        0 => true,
        1 =>
          status == OrderStatus.pending ||
              status == OrderStatus.confirmed ||
              status == OrderStatus.packing,
        2 => status == OrderStatus.shipped || status == OrderStatus.delivered,
        3 => status == OrderStatus.completed,
        _ => true,
      };
    }).toList();

    final hasNoFilteredOrders = filteredOrders.isEmpty;

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: hasNoFilteredOrders ? 2 : filteredOrders.length + 1,
      separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _OrderTabs(
            selectedIndex: _selectedTabIndex,
            onTap: (tabIndex) {
              setState(() {
                _selectedTabIndex = tabIndex;
              });
            },
          );
        }

        if (hasNoFilteredOrders) {
          return const Padding(
            padding: EdgeInsets.only(top: 48),
            child: AppEmptyState(
              title: 'Không tìm thấy đơn hàng',
              message: 'Không tìm thấy đơn hàng nào thuộc trạng thái này.',
            ),
          );
        }

        final order = filteredOrders[index - 1];
        return _OrderCard(order: order);
      },
    );
  }
}

class _OrderTabs extends StatelessWidget {
  const _OrderTabs({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _OrderTab(
            label: 'Tất cả',
            active: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          _OrderTab(
            label: 'Chờ xác nhận',
            active: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          _OrderTab(
            label: 'Đang giao',
            active: selectedIndex == 2,
            onTap: () => onTap(2),
          ),
          _OrderTab(
            label: 'Đã giao',
            active: selectedIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _OrderTab extends StatelessWidget {
  const _OrderTab({
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w900,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: active ? 40 : 0,
                height: 3,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final status = OrderStatus.fromApi(order.status);
    final priceText = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(order.totalAmount);
    final timeText = order.orderDate == null
        ? 'Chưa có thời gian'
        : DateFormat('HH:mm, dd/MM/yyyy', 'vi_VN').format(order.orderDate!);
    final firstItem = order.items.isEmpty ? null : order.items.first;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã đơn: #${order.id}',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        timeText,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                OrderStatusBadge(status: status),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _OrderPreviewImage(imageUrl: firstItem?.variantImage ?? ''),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.firstProductName.isEmpty
                            ? 'Đơn hàng #${order.id}'
                            : order.firstProductName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title,
                      ),
                      Text(
                        '${order.totalItems} sản phẩm • ${order.paymentMethod}',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text('$priceTextđ', style: AppTextStyles.subtitle),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
                Text('Tổng thanh toán:', style: AppTextStyles.body),
                const Spacer(),
                Text(
                  '$priceTextđ',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.secondary,
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
                    onPressed: () => context.go('/customer/orders/${order.id}'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: status == OrderStatus.completed
                        ? 'Đánh giá'
                        : 'Theo dõi',
                    onPressed: () =>
                        context.go('/customer/orders/${order.id}/tracking'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderPreviewImage extends StatelessWidget {
  const _OrderPreviewImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? const Icon(
              Icons.directions_run,
              color: AppColors.secondary,
              size: 44,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.directions_run,
                color: AppColors.secondary,
                size: 44,
              ),
            ),
    );
  }
}
