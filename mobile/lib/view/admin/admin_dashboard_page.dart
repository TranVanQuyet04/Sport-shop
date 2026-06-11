import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../controller/admin/admin_dashboard_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
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
            if (_controller.errorMessage != null)
              AppErrorState(
                title: 'Không tải được dashboard',
                message: _controller.errorMessage!,
                onAction: _controller.loadDashboard,
              ),
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
                subtitle: 'Từ API báo cáo',
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
                  onTap: () => context.go(AppRoutes.adminStaff),
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
              title: 'Đơn hàng đang được xử lý',
              subtitle: 'Theo dõi toàn bộ đơn trong màn quản lý đơn hàng.',
              accent: AppColors.secondary,
            ),
            const _ActivityCard(
              icon: Icons.person_add_alt,
              title: 'Người dùng mới',
              subtitle: 'Số người dùng mới được lấy từ báo cáo dashboard.',
              accent: AppColors.primary,
            ),
            const _ActivityCard(
              icon: Icons.inventory_2_outlined,
              title: 'Kho hàng',
              subtitle: 'Quản lý sản phẩm và biến thể trong phân hệ sản phẩm.',
              accent: AppColors.textSecondary,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 0),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border(left: BorderSide(color: accent, width: 4)),
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
          'API',
          textAlign: TextAlign.right,
          style: AppTextStyles.caption,
        ),
      ),
    );
  }
}
