import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controller/admin/admin_dashboard_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_design_system.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_stat_card.dart';

class AdminRevenuePage extends StatefulWidget {
  const AdminRevenuePage({super.key});

  @override
  State<AdminRevenuePage> createState() => _AdminRevenuePageState();
}

class _AdminRevenuePageState extends State<AdminRevenuePage> {
  late final AdminDashboardController _controller = AdminDashboardController(
    adminReportRepository: AppDependencies.instance.adminReportRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    _controller
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
    final report = _controller.report;
    final moneyFormatter = NumberFormat.decimalPattern('vi_VN');
    final numberFormatter = NumberFormat.decimalPattern('vi_VN');
    final revenue = moneyFormatter.format(report?.totalRevenue ?? 0);
    final orders = numberFormatter.format(report?.totalOrders ?? 0);
    final pendingOrders = numberFormatter.format(report?.pendingOrders ?? 0);
    final newUsers = numberFormatter.format(report?.newUsers ?? 0);

    return Scaffold(
      appBar: const AdminAppBar(largeLogo: true),
      body: RefreshIndicator(
        onRefresh: _controller.loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (_controller.isLoading)
              const LinearProgressIndicator(minHeight: 3),
            if (_controller.errorMessage != null) ...[
              _RevenueErrorBanner(
                message: _controller.errorMessage!,
                onRefresh: _controller.loadDashboard,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              'Tổng quan doanh thu',
              style: AppTextStyles.display.copyWith(fontSize: 30),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Dữ liệu được lấy trực tiếp từ API báo cáo backend.',
              style: AppTextStyles.body.copyWith(
                color: AdminColors.textSecondary,
              ),
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
                      value: orders,
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
                      subtitle: 'Trong ngay',
                      icon: Icons.badge_outlined,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _RevenueSummary(
              revenue: revenue,
              orders: orders,
              pendingOrders: pendingOrders,
              newUsers: newUsers,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 0),
    );
  }
}

class _RevenueErrorBanner extends StatelessWidget {
  const _RevenueErrorBanner({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return AdminInlineBanner(
      message: message,
      onRefresh: onRefresh,
      isError: true,
    );
  }
}

class _RevenueSummary extends StatelessWidget {
  const _RevenueSummary({
    required this.revenue,
    required this.orders,
    required this.pendingOrders,
    required this.newUsers,
  });

  final String revenue;
  final String orders;
  final String pendingOrders;
  final String newUsers;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chỉ số vận hành', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          _SummaryLine(label: 'Doanh thu', value: '$revenueđ'),
          _SummaryLine(label: 'Tổng đơn hàng', value: orders),
          _SummaryLine(label: 'Đơn cần xử lý', value: pendingOrders),
          _SummaryLine(label: 'Người dùng mới', value: newUsers),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AdminColors.textSecondary,
              ),
            ),
          ),
          Text(value, style: AppTextStyles.title),
        ],
      ),
    );
  }
}
