import 'package:flutter/material.dart';

import '../../controller/admin/admin_orders_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/hover_effect.dart';
import '../../model/common/delivery_status.dart';
import '../../model/customer/order_model.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

enum _DeliveryFilter { all, active, delivered, issue }

class AdminDeliveryMonitoringPage extends StatefulWidget {
  const AdminDeliveryMonitoringPage({super.key});

  @override
  State<AdminDeliveryMonitoringPage> createState() =>
      _AdminDeliveryMonitoringPageState();
}

class _AdminDeliveryMonitoringPageState
    extends State<AdminDeliveryMonitoringPage> {
  late final AdminOrdersController _controller = AdminOrdersController(
    orderRepository: AppDependencies.instance.orderRepository,
  );
  final TextEditingController _searchController = TextEditingController();

  _DeliveryFilter _selectedFilter = _DeliveryFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadOrders();
  }

  @override
  void dispose() {
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

  List<OrderModel> get _deliveryOrders {
    final query = _searchQuery.trim().toLowerCase();
    return _controller.orders.where((order) {
      final rawStatus = order.status.toUpperCase();
      final paymentMethod = order.paymentMethod.toUpperCase();
      final belongsToDelivery =
          (rawStatus == 'PENDING' && paymentMethod == 'COD') ||
          rawStatus == 'PAID' ||
          rawStatus == 'SHIPPING' ||
          rawStatus == 'DELIVERED' ||
          rawStatus == 'COMPLETED' ||
          rawStatus == 'CANCELLED';
      if (!belongsToDelivery) {
        return false;
      }

      final deliveryStatus = _mapDeliveryStatus(order);
      final matchesFilter = switch (_selectedFilter) {
        _DeliveryFilter.all => true,
        _DeliveryFilter.active =>
          deliveryStatus != DeliveryStatus.delivered &&
              deliveryStatus != DeliveryStatus.failed &&
              deliveryStatus != DeliveryStatus.returned,
        _DeliveryFilter.delivered => deliveryStatus == DeliveryStatus.delivered,
        _DeliveryFilter.issue =>
          deliveryStatus == DeliveryStatus.failed ||
              deliveryStatus == DeliveryStatus.returned,
      };
      if (!matchesFilter || query.isEmpty) {
        return matchesFilter;
      }

      return order.id.toLowerCase().contains(query) ||
          order.recipientName.toLowerCase().contains(query) ||
          order.phoneNumber.toLowerCase().contains(query) ||
          order.shippingAddress.toLowerCase().contains(query) ||
          order.firstProductName.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _advanceDelivery(OrderModel order) async {
    final currentStatus = order.status.toUpperCase();
    final nextStatus = currentStatus == 'SHIPPING' ? 'DELIVERED' : 'SHIPPING';
    await _controller.updateOrderStatus(order.id, nextStatus);
    if (!mounted) {
      return;
    }
    final failed = _controller.errorMessage != null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failed
              ? _controller.errorMessage!
              : 'Đã cập nhật đơn #${order.id} sang $nextStatus.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = _deliveryOrders;
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadOrders,
        child: _buildBody(orders),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Làm mới danh sách giao hàng',
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: _controller.isLoading ? null : _controller.loadOrders,
        child: _controller.isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh_rounded),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
    );
  }

  Widget _buildBody(List<OrderModel> orders) {
    if (_controller.isLoading && _controller.orders.isEmpty) {
      return const AppLoadingState(title: 'Đang tải giao hàng');
    }
    if (_controller.errorMessage != null && _controller.orders.isEmpty) {
      return AppErrorState(
        title: 'Không tải được giao hàng',
        message: _controller.errorMessage!,
        onAction: _controller.loadOrders,
      );
    }

    final allDeliveryOrders = _controller.orders.where((order) {
      final status = order.status.toUpperCase();
      return status == 'PENDING' ||
          status == 'PAID' ||
          status == 'SHIPPING' ||
          status == 'DELIVERED' ||
          status == 'COMPLETED' ||
          status == 'CANCELLED';
    }).toList();
    final activeCount = allDeliveryOrders.where((order) {
      final status = _mapDeliveryStatus(order);
      return status != DeliveryStatus.delivered &&
          status != DeliveryStatus.failed &&
          status != DeliveryStatus.returned;
    }).length;
    final deliveredCount = allDeliveryOrders
        .where((order) => _mapDeliveryStatus(order) == DeliveryStatus.delivered)
        .length;

    return AbsolutePersistentLayout(
      title: 'Theo dõi giao hàng',
      subtitle: 'Giám sát trạng thái vận chuyển và xử lý các đơn đang giao.',
      icon: Icons.local_shipping_outlined,
      trailing: _DeliverySummary(
        activeCount: activeCount,
        deliveredCount: deliveredCount,
      ),
      filterAndSearchZone: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_controller.errorMessage != null) ...[
            _DeliveryErrorBanner(
              message: _controller.errorMessage!,
              onRefresh: _controller.loadOrders,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          AppTextField(
            label: 'Tìm kiếm',
            controller: _searchController,
            prefixIcon: Icons.search_rounded,
            hintText: 'Tìm mã đơn, người nhận, số điện thoại hoặc địa chỉ...',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: AppSpacing.md),
          _DeliveryFilterBar(
            selected: _selectedFilter,
            onSelected: (filter) => setState(() => _selectedFilter = filter),
          ),
        ],
      ),
      dynamicContent: orders.isEmpty
          ? _buildEmptyState()
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                0,
              ),
              children: [
                _SectionHeading(
                  count: orders.length,
                  hasFilter:
                      _selectedFilter != _DeliveryFilter.all ||
                      _searchQuery.trim().isNotEmpty,
                ),
                const SizedBox(height: AppSpacing.md),
                ...orders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: DeliveryCardWidget(
                      order: order,
                      status: _mapDeliveryStatus(order),
                      isUpdating: _controller.isUpdating,
                      onAdvance: _controller.isUpdating
                          ? null
                          : () => _advanceDelivery(order),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return PremiumEmptyState(
      icon: _emptyPresentation.icon,
      title: _emptyPresentation.title,
      message: _emptyPresentation.message,
      actionLabel:
          _selectedFilter == _DeliveryFilter.all && _searchQuery.trim().isEmpty
          ? 'Tải lại dữ liệu'
          : 'Xóa bộ lọc',
      actionIcon:
          _selectedFilter == _DeliveryFilter.all && _searchQuery.trim().isEmpty
          ? Icons.refresh_rounded
          : Icons.filter_alt_off_outlined,
      onAction:
          _selectedFilter == _DeliveryFilter.all && _searchQuery.trim().isEmpty
          ? _controller.loadOrders
          : () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedFilter = _DeliveryFilter.all;
              });
            },
    );
  }

  _DeliveryEmptyPresentation get _emptyPresentation {
    if (_searchQuery.trim().isNotEmpty) {
      return const _DeliveryEmptyPresentation(
        icon: Icons.search_off_rounded,
        title: 'Không tìm thấy vận đơn',
        message: 'Không có vận đơn nào khớp với từ khóa tìm kiếm hiện tại.',
      );
    }
    return switch (_selectedFilter) {
      _DeliveryFilter.all => const _DeliveryEmptyPresentation(
        icon: Icons.local_shipping_outlined,
        title: 'Chưa có vận đơn',
        message: 'Các đơn đã thanh toán hoặc chờ giao sẽ hiển thị tại đây.',
      ),
      _DeliveryFilter.active => const _DeliveryEmptyPresentation(
        icon: Icons.local_shipping_outlined,
        title: 'Không có đơn đang giao',
        message:
            'Tất cả các kiện hàng đã được bưu tá phát hoặc đang ở kho lưu trữ.',
      ),
      _DeliveryFilter.delivered => const _DeliveryEmptyPresentation(
        icon: Icons.check_circle_outline_rounded,
        title: 'Chưa có đơn hoàn thành',
        message: 'Không tìm thấy dữ liệu lịch sử giao hàng thành công.',
      ),
      _DeliveryFilter.issue => const _DeliveryEmptyPresentation(
        icon: Icons.report_problem_outlined,
        title: 'Không có vận đơn lỗi',
        message: 'Hiện chưa có đơn giao thất bại hoặc hoàn trả cần xử lý lại.',
      ),
    };
  }

  DeliveryStatus _mapDeliveryStatus(OrderModel order) {
    final value = order.deliveryStatus.isNotEmpty
        ? order.deliveryStatus
        : order.status;
    return switch (value.toUpperCase()) {
      'PAID' || 'PENDING' || 'WAITING_PICKUP' => DeliveryStatus.waitingPickup,
      'PICKED_UP' => DeliveryStatus.pickedUp,
      'IN_TRANSIT' => DeliveryStatus.inTransit,
      'SHIPPING' || 'OUT_FOR_DELIVERY' => DeliveryStatus.outForDelivery,
      'DELIVERED' || 'COMPLETED' => DeliveryStatus.delivered,
      'CANCELLED' || 'RETURNED' => DeliveryStatus.returned,
      'FAILED' => DeliveryStatus.failed,
      _ => DeliveryStatus.waitingPickup,
    };
  }
}

class _DeliveryEmptyPresentation {
  const _DeliveryEmptyPresentation({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}

class _DeliverySummary extends StatelessWidget {
  const _DeliverySummary({
    required this.activeCount,
    required this.deliveredCount,
  });

  final int activeCount;
  final int deliveredCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AdminColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        '$activeCount đang giao · $deliveredCount đã giao',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AdminColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DeliveryErrorBanner extends StatelessWidget {
  const _DeliveryErrorBanner({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AdminColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AdminColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AdminColors.primaryPressed,
              ),
            ),
          ),
          TextButton(onPressed: onRefresh, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _DeliveryFilterBar extends StatelessWidget {
  const _DeliveryFilterBar({required this.selected, required this.onSelected});

  final _DeliveryFilter selected;
  final ValueChanged<_DeliveryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = <(_DeliveryFilter, String)>[
      (_DeliveryFilter.all, 'Tất cả'),
      (_DeliveryFilter.active, 'Đang giao'),
      (_DeliveryFilter.delivered, 'Đã giao'),
      (_DeliveryFilter.issue, 'Lỗi / Trả lại'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((entry) {
          final isSelected = selected == entry.$1;
          final isIssue = entry.$1 == _DeliveryFilter.issue;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(entry.$2),
              selected: isSelected,
              onSelected: (_) => onSelected(entry.$1),
              showCheckmark: false,
              backgroundColor: AdminColors.surface,
              selectedColor: isIssue
                  ? const Color(0xFFFFE4E6)
                  : AdminColors.primary,
              side: BorderSide(
                color: isSelected && isIssue
                    ? const Color(0xFFBE123C)
                    : isSelected
                    ? AdminColors.primary
                    : AdminColors.border,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? isIssue
                          ? const Color(0xFFBE123C)
                          : Colors.white
                    : AdminColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.count, required this.hasFilter});

  final int count;
  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            hasFilter ? 'Kết quả lọc' : 'Danh sách vận đơn',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AdminColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AdminColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            '$count vận đơn',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AdminColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class DeliveryCardWidget extends StatelessWidget {
  const DeliveryCardWidget({
    super.key,
    required this.order,
    required this.status,
    required this.isUpdating,
    required this.onAdvance,
  });

  final OrderModel order;
  final DeliveryStatus status;
  final bool isUpdating;
  final VoidCallback? onAdvance;

  bool get _isIssue =>
      status == DeliveryStatus.returned || status == DeliveryStatus.failed;

  bool get _canAdvance =>
      status == DeliveryStatus.waitingPickup ||
      status == DeliveryStatus.pickedUp ||
      status == DeliveryStatus.inTransit ||
      status == DeliveryStatus.outForDelivery;

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
                                  : Icons.local_shipping_outlined,
                            ),
                      label: Text(
                        status == DeliveryStatus.outForDelivery
                            ? 'Đánh dấu đã giao'
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

class DeliveryStatusStepper extends StatelessWidget {
  const DeliveryStatusStepper({super.key, required this.status});

  final DeliveryStatus status;

  int get _currentStep {
    return switch (status) {
      DeliveryStatus.waitingPickup || DeliveryStatus.pickedUp => 0,
      DeliveryStatus.inTransit ||
      DeliveryStatus.outForDelivery ||
      DeliveryStatus.failed ||
      DeliveryStatus.returned => 1,
      DeliveryStatus.delivered => 2,
    };
  }

  @override
  Widget build(BuildContext context) {
    final complete = status == DeliveryStatus.delivered;
    final issue =
        status == DeliveryStatus.failed || status == DeliveryStatus.returned;
    final activeColor = complete
        ? const Color(0xFF16A34A)
        : issue
        ? const Color(0xFFBE123C)
        : AdminColors.primary;

    return Column(
      children: [
        Row(
          children: List.generate(5, (index) {
            if (index.isOdd) {
              final connectorStep = index ~/ 2;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 3,
                  color: connectorStep < _currentStep
                      ? activeColor
                      : AdminColors.border,
                ),
              );
            }
            final step = index ~/ 2;
            final reached = step <= _currentStep;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? activeColor : AdminColors.surface,
                border: Border.all(
                  color: reached ? activeColor : AdminColors.border,
                  width: 2,
                ),
              ),
              child: reached
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            );
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _StepLabel(
              label: 'Xác nhận',
              active: _currentStep >= 0,
              color: activeColor,
            ),
            _StepLabel(
              label: issue ? 'Có sự cố' : 'Đang giao',
              active: _currentStep >= 1,
              color: activeColor,
              centered: true,
            ),
            _StepLabel(
              label: 'Hoàn thành',
              active: _currentStep >= 2,
              color: activeColor,
              trailing: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({
    required this.label,
    required this.active,
    required this.color,
    this.centered = false,
    this.trailing = false,
  });

  final String label;
  final bool active;
  final Color color;
  final bool centered;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: centered
            ? TextAlign.center
            : trailing
            ? TextAlign.end
            : TextAlign.start,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: active ? color : AdminColors.textSecondary,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

({String label, Color background, Color foreground}) _statusPresentation(
  DeliveryStatus status,
) {
  return switch (status) {
    DeliveryStatus.waitingPickup => (
      label: 'Chờ lấy hàng',
      background: const Color(0xFFFEF3C7),
      foreground: const Color(0xFF92400E),
    ),
    DeliveryStatus.pickedUp => (
      label: 'Đã lấy hàng',
      background: AdminColors.primarySoft,
      foreground: AdminColors.primaryPressed,
    ),
    DeliveryStatus.inTransit => (
      label: 'Đang vận chuyển',
      background: AdminColors.primarySoft,
      foreground: AdminColors.primaryPressed,
    ),
    DeliveryStatus.outForDelivery => (
      label: 'Đang giao',
      background: AdminColors.primarySoft,
      foreground: AdminColors.primaryPressed,
    ),
    DeliveryStatus.delivered => (
      label: 'Đã giao',
      background: const Color(0xFFDCFCE7),
      foreground: const Color(0xFF166534),
    ),
    DeliveryStatus.failed => (
      label: 'Giao thất bại',
      background: const Color(0xFFFFE4E6),
      foreground: const Color(0xFFBE123C),
    ),
    DeliveryStatus.returned => (
      label: 'Hoàn trả',
      background: const Color(0xFFFFE4E6),
      foreground: const Color(0xFFBE123C),
    ),
  };
}
