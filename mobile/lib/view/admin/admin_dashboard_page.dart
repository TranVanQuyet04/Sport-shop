import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../controller/admin/admin_dashboard_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_stat_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final AdminDashboardController _controller = AdminDashboardController(
    adminReportRepository: AppDependencies.instance.adminReportRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadDashboard();
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
  Widget build(BuildContext context) {
    final report = _controller.report;
    final revenue = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(report?.totalRevenue ?? 0);
    final totalOrders = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(report?.totalOrders ?? 0);
    final newUsers = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(report?.newUsers ?? 0);
    final pendingOrders = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(report?.pendingOrders ?? 0);

    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (_controller.isLoading)
              const LinearProgressIndicator(minHeight: 3),
            if (_controller.errorMessage != null) ...[
              _AdminDemoBanner(
                message: _controller.errorMessage!,
                onRefresh: _controller.loadDashboard,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              'Hệ thống quản trị',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Chào buổi sáng, Admin',
              style: AppTextStyles.display.copyWith(fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 164,
              child: AdminStatCard(
                title: 'Doanh thu hôm nay',
                value: '$revenueđ',
                subtitle: 'Tổng hợp theo ngày',
                icon: Icons.payments_outlined,
                dark: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: AdminStatCard(
                      title: 'Tổng đơn',
                      value: totalOrders,
                      subtitle: '$pendingOrders đơn chờ xử lý',
                      icon: Icons.shopping_bag_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: AdminStatCard(
                      title: 'Người dùng mới',
                      value: newUsers,
                      subtitle: 'Trong ngày',
                      icon: Icons.badge_outlined,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _OperationsSnapshot(
              pendingOrders: pendingOrders,
              totalOrders: totalOrders,
              onOrders: () => context.go(AppRoutes.adminOrders),
              onDelivery: () => context.go(AppRoutes.adminDeliveryMonitoring),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Thao tác nhanh', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _QuickAction(
                  icon: Icons.add_box_outlined,
                  label: 'Thêm sản phẩm',
                  onTap: () => context.go(AppRoutes.adminProducts),
                ),
                const SizedBox(width: AppSpacing.md),
                _QuickAction(
                  icon: Icons.check_circle_outline,
                  label: 'Duyệt đơn',
                  onTap: () => context.go(AppRoutes.adminOrders),
                ),
                const SizedBox(width: AppSpacing.md),
                _QuickAction(
                  icon: Icons.calendar_month_outlined,
                  label: 'Lịch trực',
                  onTap: () => context.go(AppRoutes.adminShiftPlanning),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Text('Hoạt động gần đây', style: AppTextStyles.title),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.adminOrders),
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            const _ActivityCard(
              icon: Icons.local_shipping_outlined,
              title: '12 đơn đang chờ xử lý',
              subtitle: 'Ưu tiên xác nhận đơn mới và bàn giao vận chuyển.',
              accent: AppColors.secondary,
              meta: 'Cần xử lý',
            ),
            const _ActivityCard(
              icon: Icons.person_add_alt,
              title: '18 khách hàng mới',
              subtitle: 'Tăng trưởng người dùng trong ngày hôm nay.',
              accent: AppColors.primary,
              meta: 'Hôm nay',
            ),
            const _ActivityCard(
              icon: Icons.inventory_2_outlined,
              title: 'Kho hàng cần rà soát',
              subtitle: 'Kiểm tra sản phẩm bán chạy và biến thể sắp hết hàng.',
              accent: AppColors.textSecondary,
              meta: 'Inventory',
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 0),
    );
  }
}

class _AdminDemoBanner extends StatelessWidget {
  const _AdminDemoBanner({required this.message, required this.onRefresh});

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

class _OperationsSnapshot extends StatelessWidget {
  const _OperationsSnapshot({
    required this.pendingOrders,
    required this.totalOrders,
    required this.onOrders,
    required this.onDelivery,
  });

  final String pendingOrders;
  final String totalOrders;
  final VoidCallback onOrders;
  final VoidCallback onDelivery;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tình hình vận hành',
              style: AppTextStyles.title.copyWith(color: AppColors.textInverse),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _SnapshotMetric(
                    label: 'Chờ xử lý',
                    value: pendingOrders,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _SnapshotMetric(label: 'Tổng đơn', value: totalOrders),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onOrders,
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Đơn hàng'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelivery,
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: const Text('Giao hàng'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textInverse,
                      side: BorderSide(
                        color: AppColors.textInverse.withValues(alpha: 0.4),
                      ),
                    ),
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

class _SnapshotMetric extends StatelessWidget {
  const _SnapshotMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.textInverse.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textInverse.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.display.copyWith(
                color: AppColors.textInverse,
                fontSize: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.sm,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.surfaceMuted,
                  foregroundColor: AppColors.primary,
                  child: Icon(icon),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.meta,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: accent, width: 1),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.surfaceMuted,
            foregroundColor: accent,
            child: Icon(icon),
          ),
          title: Text(
            title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(subtitle),
          trailing: Text(
            meta,
            textAlign: TextAlign.right,
            style: AppTextStyles.caption,
          ),
        ),
      ),
    );
  }
}
