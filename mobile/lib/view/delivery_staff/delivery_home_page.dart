import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/hover_effect.dart';
import '../../core/widgets/sport_performance_hero.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../../presenter/delivery_staff/delivery_orders_presenter.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class DeliveryHomePage extends StatefulWidget {
  const DeliveryHomePage({super.key});

  @override
  State<DeliveryHomePage> createState() => _DeliveryHomePageState();
}

class _DeliveryHomePageState extends State<DeliveryHomePage> {
  late final DeliveryOrdersPresenter _presenter = DeliveryOrdersPresenter(
    orderRepository: AppDependencies.instance.orderRepository,
    deliveryOperationsRepository:
        AppDependencies.instance.deliveryOperationsRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onChanged);
    _presenter.loadOrders();
    _presenter.startAutoRefresh();
  }

  @override
  void dispose() {
    _presenter
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _presenter.assignedOrders
        .where(
          (order) => OrderStatus.fromApi(order.status) == OrderStatus.shipped,
        )
        .toList();
    final completed = _presenter.assignedOrders.where((order) {
      final status = OrderStatus.fromApi(order.status);
      return status == OrderStatus.delivered || status == OrderStatus.completed;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.shipperBackground,
      appBar: const AdminAppBar(variant: AdminAppBarVariant.shipper),
      body: RefreshIndicator(
        onRefresh: _presenter.loadOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const _DeliveryHero(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Bảng điều phối giao hàng',
              style: AppTextStyles.display.copyWith(fontSize: 30),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Đơn được gán sẽ tự cập nhật gần realtime. Ưu tiên xử lý các đơn đang giao trước.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Đang giao',
                    value: '${active.length}',
                    icon: Icons.local_shipping_outlined,
                    tone: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MetricCard(
                    label: 'Hoàn tất',
                    value: '${completed.length}',
                    icon: Icons.check_circle_outline,
                    tone: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Xem đơn giao',
              icon: Icons.assignment_outlined,
              backgroundColor: SuperSportsTheme.colorAccent,
              onPressed: () => context.go(AppRoutes.deliveryAssignedOrders),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Đơn ưu tiên', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            if (_presenter.isLoading && _presenter.orders.isEmpty)
              const _PriorityStateCard(
                icon: Icons.sync_rounded,
                title: 'Đang tải đơn giao',
                message: 'Đang đồng bộ danh sách phân công mới nhất.',
                loading: true,
              )
            else if (_presenter.errorMessage != null &&
                _presenter.orders.isEmpty)
              _PriorityStateCard(
                icon: Icons.error_outline_rounded,
                title: 'Không tải được đơn giao',
                message: _presenter.errorMessage!,
                tone: AppColors.error,
                actionLabel: 'Thử lại',
                onAction: _presenter.loadOrders,
              )
            else if (active.isEmpty)
              const _PriorityStateCard(
                icon: Icons.route_outlined,
                title: 'Chưa có đơn đang giao',
                message: 'Đơn mới được điều phối sẽ xuất hiện tại đây.',
              )
            else
              ...active.take(5).map((order) => _DeliveryTile(order: order)),
          ],
        ),
      ),
      bottomNavigationBar: const DeliveryBottomNav(selectedIndex: 0),
    );
  }
}

class _DeliveryHero extends StatelessWidget {
  const _DeliveryHero();

  @override
  Widget build(BuildContext context) {
    return const SportPerformanceHero(
      title: 'Giao đúng đơn, cập nhật đúng nhịp',
      subtitle:
          'Theo dõi đơn được gán, chuyển trạng thái và báo cáo sự cố ngay trong ca giao.',
      icon: Icons.local_shipping_rounded,
      badges: [
        SportHeroBadge(label: 'Realtime 8s', icon: Icons.sync_rounded),
        SportHeroBadge(
          label: 'Route ready',
          icon: Icons.near_me_outlined,
          color: AppColors.accent,
        ),
      ],
    );
  }
}

class _PriorityStateCard extends StatelessWidget {
  const _PriorityStateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.tone = AppColors.secondary,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color tone;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: SuperSportsTheme.borderRadius,
        border: Border.all(color: tone.withValues(alpha: 0.16)),
        boxShadow: AppElevation.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: loading
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(tone),
                    ),
                  )
                : Icon(icon, color: tone, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(actionLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) => HoverLift(
    borderRadius: SuperSportsTheme.borderRadius,
    child: Container(
      height: 128,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, tone.withValues(alpha: 0.06)],
        ),
        borderRadius: SuperSportsTheme.borderRadius,
        border: Border.all(color: tone.withValues(alpha: 0.18)),
        boxShadow: AppElevation.role(tone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(icon, color: tone, size: 20),
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(value, style: AppTextStyles.display.copyWith(fontSize: 30)),
        ],
      ),
    ),
  );
}

class _DeliveryTile extends StatelessWidget {
  const _DeliveryTile({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: HoverLift(
      interactive: true,
      borderRadius: SuperSportsTheme.borderRadius,
      child: Material(
        color: AppColors.surface,
        borderRadius: SuperSportsTheme.borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.secondary.withValues(alpha: 0.045),
              ],
            ),
            borderRadius: SuperSportsTheme.borderRadius,
            border: Border.all(color: AppColors.successBorder, width: 0.8),
          ),
          child: ListTile(
            onTap: () =>
                context.go('/delivery-staff/orders/${order.id}/status'),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondarySoft,
                borderRadius: SuperSportsTheme.borderRadius,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: AppColors.secondary,
              ),
            ),
            title: Text(
              '#${order.id} - ${order.status}',
              style: AppTextStyles.subtitle,
            ),
            subtitle: Text(order.shippingAddress),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    ),
  );
}
