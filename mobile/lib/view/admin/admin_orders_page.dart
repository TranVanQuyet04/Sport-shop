import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controller/admin/admin_orders_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  late final AdminOrdersController _controller = AdminOrdersController(
    orderRepository: AppDependencies.instance.orderRepository,
  );
  final TextEditingController _searchController = TextEditingController();
  Timer? _tabSwitchTimer;
  bool _isSwitchingTab = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadOrders();
  }

  @override
  void dispose() {
    _tabSwitchTimer?.cancel();
    _searchController.dispose();
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

  void _selectStatus(OrderStatus? status) {
    _tabSwitchTimer?.cancel();
    setState(() => _isSwitchingTab = true);
    _controller.selectStatus(status);
    _tabSwitchTimer = Timer(const Duration(milliseconds: 260), () {
      if (mounted) {
        setState(() => _isSwitchingTab = false);
      }
    });
  }

  List<OrderModel> get _visibleOrders {
    final query = _searchController.text.trim().toLowerCase();
    final displayedOrders = _displayedOrdersForCurrentTab();
    if (query.isEmpty) {
      return displayedOrders;
    }
    return displayedOrders.where((order) {
      return order.id.toLowerCase().contains(query) ||
          order.recipientName.toLowerCase().contains(query) ||
          order.phoneNumber.toLowerCase().contains(query) ||
          order.firstProductName.toLowerCase().contains(query);
    }).toList();
  }

  List<OrderModel> _displayedOrdersForCurrentTab() {
    return _controller.allOrders
        .where((order) {
          if (!_isRenderableOrder(order)) {
            return false;
          }
          return _matchesSelectedStatus(order);
        })
        .toList(growable: false);
  }

  bool _isRenderableOrder(OrderModel order) {
    return order.id.trim().isNotEmpty && _strictStatusOf(order) != null;
  }

  bool _matchesSelectedStatus(OrderModel order) {
    final selectedStatus = _controller.selectedStatus;
    if (selectedStatus == null) {
      return true;
    }
    return _strictStatusOf(order) == selectedStatus;
  }

  OrderStatus? _strictStatusOf(OrderModel order) {
    return switch (order.status.trim().toUpperCase()) {
      'PENDING' => OrderStatus.pending,
      'PAID' || 'CONFIRMED' => OrderStatus.confirmed,
      'PACKING' => OrderStatus.packing,
      'SHIPPING' || 'SHIPPED' => OrderStatus.shipped,
      'DELIVERED' || 'COMPLETED' => OrderStatus.completed,
      'CANCELLED' => OrderStatus.cancelled,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadOrders,
        child: _buildBody(),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.allOrders.isEmpty) {
      return const PremiumShimmerList(itemCount: 3, itemHeight: 188);
    }
    if (_controller.errorMessage != null && _controller.allOrders.isEmpty) {
      return AppErrorState(
        title: 'Không tải được đơn hàng',
        message: _controller.errorMessage!,
        onAction: _controller.loadOrders,
      );
    }
    if (_controller.allOrders.isEmpty) {
      return PremiumEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Chưa có đơn hàng',
        message:
            'Đơn hàng mới từ khách hàng sẽ xuất hiện tại đây khi được tạo.',
        actionLabel: 'Tải lại dữ liệu',
        onAction: _controller.loadOrders,
      );
    }

    final displayedOrders = _visibleOrders;
    final dynamicContent = _isSwitchingTab
        ? const PremiumShimmerList(itemCount: 3, itemHeight: 188)
        : displayedOrders.isEmpty
        ? _buildEmptyState()
        : _buildOrdersList(displayedOrders);
    return AbsolutePersistentLayout(
      title: 'Quản lý đơn hàng',
      subtitle: 'Theo dõi, xác nhận và cập nhật tiến trình xử lý đơn.',
      icon: Icons.receipt_long_outlined,
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AdminColors.primarySoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '${displayedOrders.length}/${_controller.totalOrders}',
          style: AppTextStyles.caption.copyWith(
            color: AdminColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      filterAndSearchZone: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_controller.errorMessage != null) ...[
            AdminInlineBanner(
              message: _controller.errorMessage!,
              onRefresh: _controller.loadOrders,
              isError: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _OrderSearchField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          _OrderTabs(
            selectedStatus: _controller.selectedStatus,
            onChanged: _selectStatus,
          ),
        ],
      ),
      dynamicContent: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: KeyedSubtree(
          key: ValueKey(
            'orders-${_controller.selectedStatus}-${_searchController.text}-${_isSwitchingTab ? 'loading' : displayedOrders.length}',
          ),
          child: dynamicContent,
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> displayedOrders) {
    final cleanOrders = displayedOrders
        .where(_isRenderableOrder)
        .toList(growable: false);
    if (cleanOrders.isEmpty) {
      return _buildEmptyState();
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
      children: [
        AdminSectionTitle(
          title: 'Danh sách đơn hàng',
          subtitle: '${cleanOrders.length} kết quả phù hợp',
          trailing: IconButton(
            tooltip: 'Làm mới',
            onPressed: _controller.isLoading ? null : _controller.loadOrders,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...cleanOrders.indexed.map(
          (entry) => _StaggeredOrderCard(
            key: ValueKey(entry.$2.id),
            index: entry.$1,
            child: OrderCardWidget(
              order: entry.$2,
              isBusy: _controller.isUpdating,
              onNextStatus: _controller.updateOrderStatus,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return PremiumEmptyState(
      icon: _emptyPresentation.icon,
      title: _emptyPresentation.title,
      message: _emptyPresentation.message,
      actionLabel: _searchController.text.trim().isEmpty
          ? 'Tải lại dữ liệu'
          : 'Xóa tìm kiếm',
      actionIcon: _searchController.text.trim().isEmpty
          ? Icons.refresh_rounded
          : Icons.filter_alt_off_outlined,
      onAction: _searchController.text.trim().isEmpty
          ? _controller.loadOrders
          : () {
              _searchController.clear();
              setState(() {});
            },
    );
  }

  _OrderEmptyPresentation get _emptyPresentation {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    if (hasSearch) {
      return const _OrderEmptyPresentation(
        icon: Icons.search_off_rounded,
        title: 'Không tìm thấy đơn hàng',
        message: 'Không có đơn hàng nào khớp với từ khóa tìm kiếm hiện tại.',
      );
    }
    return switch (_controller.selectedStatus) {
      OrderStatus.pending => const _OrderEmptyPresentation(
        icon: Icons.assignment_late_outlined,
        title: 'Không có đơn chờ xác nhận',
        message:
            'Hệ thống hiện tại không có đơn hàng mới nào cần bạn phê duyệt.',
      ),
      OrderStatus.confirmed => const _OrderEmptyPresentation(
        icon: Icons.assignment_turned_in_outlined,
        title: 'Danh sách trống',
        message: 'Chưa có đơn hàng nào được xác nhận trong phiên làm việc này.',
      ),
      OrderStatus.packing => const _OrderEmptyPresentation(
        icon: Icons.archive_outlined,
        title: 'Không có đơn đang đóng gói',
        message:
            'Tất cả các đơn hàng đã được đóng gói xong và chuyển cho bưu tá.',
      ),
      OrderStatus.shipped => const _OrderEmptyPresentation(
        icon: Icons.local_shipping_outlined,
        title: 'Không có đơn đang giao',
        message:
            'Tất cả các kiện hàng đã được bưu tá phát hoặc đang ở kho lưu trữ.',
      ),
      OrderStatus.completed => const _OrderEmptyPresentation(
        icon: Icons.check_circle_outline_rounded,
        title: 'Chưa có đơn hoàn thành',
        message: 'Không tìm thấy dữ liệu lịch sử giao hàng thành công.',
      ),
      OrderStatus.cancelled => const _OrderEmptyPresentation(
        icon: Icons.cancel_outlined,
        title: 'Không có đơn đã hủy',
        message: 'Hiện chưa có đơn hàng nào bị hủy trong danh sách này.',
      ),
      null => const _OrderEmptyPresentation(
        icon: Icons.receipt_long_outlined,
        title: 'Chưa có đơn hàng phù hợp',
        message:
            'Đơn hàng mới từ khách hàng sẽ xuất hiện tại đây khi được tạo.',
      ),
    };
  }
}

class _OrderEmptyPresentation {
  const _OrderEmptyPresentation({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}

abstract final class _OrderPalette {
  static const Color slate = Color(0xFF64748B);
  static const Color productSurface = Color(0xFFF1F5F9);
  static const Color pendingText = Color(0xFF9A3412);
  static const Color pendingSurface = Color(0xFFFFF1E6);
  static const Color infoText = Color(0xFF1D4ED8);
  static const Color infoSurface = Color(0xFFDBEAFE);
  static const Color successText = Color(0xFF166534);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color errorText = Color(0xFF991B1B);
  static const Color errorSurface = Color(0xFFFEE2E2);
}

class _OrderSearchField extends StatelessWidget {
  const _OrderSearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      padding: EdgeInsets.zero,
      hoverEnabled: false,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Tìm mã đơn, khách hàng, số điện thoại, sản phẩm...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Xóa tìm kiếm',
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: AdminColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AdminColors.primary, width: 1),
          ),
        ),
      ),
    );
  }
}

class _OrderTabs extends StatelessWidget {
  const _OrderTabs({required this.selectedStatus, required this.onChanged});

  final OrderStatus? selectedStatus;
  final ValueChanged<OrderStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      _OrderTabItem(label: 'Tất cả'),
      _OrderTabItem(label: 'Chờ xác nhận', status: OrderStatus.pending),
      _OrderTabItem(label: 'Đã xác nhận', status: OrderStatus.confirmed),
      _OrderTabItem(label: 'Đang đóng gói', status: OrderStatus.packing),
      _OrderTabItem(label: 'Đang giao', status: OrderStatus.shipped),
      _OrderTabItem(label: 'Hoàn thành', status: OrderStatus.completed),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final selected = selectedStatus == tab.status;
          return ChoiceChip(
            label: Text(tab.label),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => onChanged(tab.status),
            selectedColor: AdminColors.primary,
            backgroundColor: AdminColors.surfaceMuted,
            side: BorderSide.none,
            elevation: selected ? 3 : 0,
            shadowColor: AdminColors.primary.withValues(alpha: 0.22),
            pressElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            labelStyle: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AdminColors.textSecondary,
            ),
          );
        },
      ),
    );
  }
}

class _OrderTabItem {
  const _OrderTabItem({required this.label, this.status});

  final String label;
  final OrderStatus? status;
}

class _StaggeredOrderCard extends StatefulWidget {
  const _StaggeredOrderCard({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_StaggeredOrderCard> createState() => _StaggeredOrderCardState();
}

class _StaggeredOrderCardState extends State<_StaggeredOrderCard> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 55 * widget.index.clamp(0, 8));
    _timer = Timer(delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: widget.child,
        ),
      ),
    );
  }
}

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
      OrderStatus.shipped => OrderStatus.completed,
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

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              amountWidget,
              const SizedBox(height: AppSpacing.md),
              actionWidget,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: amountWidget),
            const SizedBox(width: AppSpacing.lg),
            actionWidget,
          ],
        );
      },
    );
  }

  String _actionLabel(OrderStatus current, OrderStatus? next) {
    if (next == null) {
      return current == OrderStatus.cancelled ? 'Đã hủy' : 'Đã hoàn tất';
    }
    return switch (next) {
      OrderStatus.confirmed => 'Xác nhận',
      OrderStatus.packing => 'Đóng gói',
      OrderStatus.shipped => 'Bàn giao',
      OrderStatus.completed => 'Hoàn thành',
      _ => 'Cập nhật',
    };
  }
}

class _OrderActionButton extends StatelessWidget {
  const _OrderActionButton({
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.primary,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool isLoading;
  final bool primary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: primary
              ? AdminColors.primary
              : AdminColors.surfaceMuted,
          foregroundColor: primary ? Colors.white : AdminColors.textSecondary,
          disabledBackgroundColor: AdminColors.surfaceMuted,
          disabledForegroundColor: AdminColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = AdminColors.border
      ..strokeWidth = 1;
    var startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset((startX + dashWidth).clamp(0, size.width), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

_StatusPresentation _statusPresentation(OrderStatus status) {
  return switch (status) {
    OrderStatus.pending => const _StatusPresentation(
      label: 'Chờ xác nhận',
      foreground: _OrderPalette.pendingText,
      background: _OrderPalette.pendingSurface,
    ),
    OrderStatus.confirmed => const _StatusPresentation(
      label: 'Đã xác nhận',
      foreground: _OrderPalette.infoText,
      background: _OrderPalette.infoSurface,
    ),
    OrderStatus.packing => const _StatusPresentation(
      label: 'Đang đóng gói',
      foreground: _OrderPalette.infoText,
      background: _OrderPalette.infoSurface,
    ),
    OrderStatus.shipped => const _StatusPresentation(
      label: 'Đang giao',
      foreground: _OrderPalette.infoText,
      background: _OrderPalette.infoSurface,
    ),
    OrderStatus.completed => const _StatusPresentation(
      label: 'Hoàn thành',
      foreground: _OrderPalette.successText,
      background: _OrderPalette.successSurface,
    ),
    OrderStatus.cancelled => const _StatusPresentation(
      label: 'Đã hủy',
      foreground: _OrderPalette.errorText,
      background: _OrderPalette.errorSurface,
    ),
  };
}

class _StatusPresentation {
  const _StatusPresentation({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;
}
