import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controller/admin/admin_dashboard_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_app_bar.dart';
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
              'Tong quan doanh thu',
              style: AppTextStyles.display.copyWith(fontSize: 30),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Du lieu duoc lay truc tiep tu API bao cao backend.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 164,
              child: AdminStatCard(
                title: 'Doanh thu hom nay',
                value: '${revenue}d',
                subtitle: 'Tong hop theo ngay',
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
                      title: 'Tong don',
                      value: orders,
                      subtitle: '$pendingOrders don cho xu ly',
                      icon: Icons.shopping_bag_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: AdminStatCard(
                      title: 'Nguoi dung moi',
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
            TextButton(onPressed: onRefresh, child: const Text('Thu lai')),
          ],
        ),
      ),
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
            Text('Chi so van hanh', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            _SummaryLine(label: 'Doanh thu', value: '${revenue}d'),
            _SummaryLine(label: 'Tong don hang', value: orders),
            _SummaryLine(label: 'Don can xu ly', value: pendingOrders),
            _SummaryLine(label: 'Nguoi dung moi', value: newUsers),
          ],
        ),
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
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: AppTextStyles.title),
        ],
      ),
    );
  }
}
