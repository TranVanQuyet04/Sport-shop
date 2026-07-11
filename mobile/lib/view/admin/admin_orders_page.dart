import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../presenter/admin/admin_orders_presenter.dart';
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

part 'admin_orders_page_parts/orders_filters_and_tabs.dart';
part 'admin_orders_page_parts/order_card_widgets.dart';
part 'admin_orders_page_parts/order_support_widgets.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  late final AdminOrdersPresenter _presenter = AdminOrdersPresenter(
    orderRepository: AppDependencies.instance.orderRepository,
  );
  final TextEditingController _searchController = TextEditingController();
  Timer? _tabSwitchTimer;
  bool _isSwitchingTab = false;

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadOrders();
    _presenter.startAutoRefresh();
  }

  @override
  void dispose() {
    _tabSwitchTimer?.cancel();
    _searchController.dispose();
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

  void _selectStatus(OrderStatus? status) {
    _tabSwitchTimer?.cancel();
    setState(() => _isSwitchingTab = true);
    _presenter.selectStatus(status);
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
    return _presenter.allOrders
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
    final selectedStatus = _presenter.selectedStatus;
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
      'DELIVERED' => OrderStatus.delivered,
      'COMPLETED' => OrderStatus.completed,
      'CANCELLED' => OrderStatus.cancelled,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _presenter.loadOrders,
        child: _buildBody(),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
    );
  }

  Widget _buildBody() {
    if (_presenter.isLoading && _presenter.allOrders.isEmpty) {
      return const PremiumShimmerList(itemCount: 3, itemHeight: 188);
    }
    if (_presenter.errorMessage != null && _presenter.allOrders.isEmpty) {
      return AppErrorState(
        title: 'Không tải được đơn hàng',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadOrders,
      );
    }
    if (_presenter.allOrders.isEmpty) {
      return PremiumEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Chưa có đơn hàng',
        message:
            'Đơn hàng mới từ khách hàng sẽ xuất hiện tại đây khi được tạo.',
        actionLabel: 'Tải lại dữ liệu',
        onAction: _presenter.loadOrders,
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
          '${displayedOrders.length}/${_presenter.totalOrders}',
          style: AppTextStyles.caption.copyWith(
            color: AdminColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      filterAndSearchZone: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_presenter.errorMessage != null) ...[
            AdminInlineBanner(
              message: _presenter.errorMessage!,
              onRefresh: _presenter.loadOrders,
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
            selectedStatus: _presenter.selectedStatus,
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
            'orders-${_presenter.selectedStatus}-${_searchController.text}-${_isSwitchingTab ? 'loading' : displayedOrders.length}',
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
            onPressed: _presenter.isLoading ? null : _presenter.loadOrders,
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
              isBusy: _presenter.isUpdating,
              onNextStatus: _presenter.updateOrderStatus,
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
          ? _presenter.loadOrders
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
    return switch (_presenter.selectedStatus) {
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
      OrderStatus.delivered => const _OrderEmptyPresentation(
        icon: Icons.task_alt_outlined,
        title: 'Không có đơn chờ hoàn tất',
        message:
            'Chưa có đơn nào được shipper đánh dấu đã giao để admin chốt hoàn thành.',
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
