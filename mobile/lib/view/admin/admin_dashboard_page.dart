// ──────────────────────────────────────────────────────────────────────────────
//  Admin Dashboard – PHẦN 1: THỐNG KÊ & BÁO CÁO (Analytics)
//  Architecture: View → Presenter (ChangeNotifier) → Repository
//  UI Style: premium, card-first, mobile-native
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/hover_effect.dart';
import '../../model/admin/dashboard_report_model.dart';
import '../../presenter/admin/admin_dashboard_presenter.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

part 'admin_dashboard_page_parts/kpi_card.dart';
part 'admin_dashboard_page_parts/date_filter.dart';
part 'admin_dashboard_page_parts/quick_actions.dart';
part 'admin_dashboard_page_parts/revenue_chart.dart';
part 'admin_dashboard_page_parts/dashboard_actions_and_overview.dart';
part 'admin_dashboard_page_parts/dashboard_header_revenue_widgets.dart';
part 'admin_dashboard_page_parts/dashboard_operations_widgets.dart';

// Aliases để tương thích với các widget được tạo từ design system cũ
typedef _DashboardColors = AdminColors;
typedef _DashboardStyle = AdminDesign;

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final AdminDashboardPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = AdminDashboardPresenter(
      adminReportRepository: AppDependencies.instance.adminReportRepository,
    );
    _presenter.addListener(_onControllerChanged);
    _presenter.loadDashboard();
  }

  @override
  void dispose() {
    _presenter.removeListener(_onControllerChanged);
    _presenter.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initial =
        _presenter.dateRange ??
        DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initial,
    );
    if (result != null) {
      _presenter.updateDateRange(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Tổng quan'),
      body: RefreshIndicator(
        onRefresh: _presenter.loadDashboard,
        child: _buildBody(),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 0),
    );
  }

  Widget _buildBody() {
    if (_presenter.isLoading) {
      return const AppLoadingState(title: 'Đang tải...');
    }
    if (_presenter.errorMessage != null) {
      return AppErrorState(
        title: 'Lỗi tải dữ liệu',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadDashboard,
      );
    }
    final report = _presenter.dashboardReport;
    if (report == null) {
      return const PremiumEmptyState(
        icon: Icons.bar_chart,
        title: 'Chưa có dữ liệu thống kê',
        message:
            'Dữ liệu dashboard sẽ hiển thị khi hệ thống phát sinh giao dịch.',
      );
    }

    return AbsolutePersistentLayout(
      title: 'Tổng quan',
      subtitle: 'Theo dõi hoạt động và chỉ số vận hành',
      icon: Icons.dashboard_outlined,
      trailing: IconButton(
        tooltip: 'Chọn khoảng ngày',
        icon: const Icon(Icons.date_range_rounded),
        onPressed: _pickDateRange,
      ),
      filterAndSearchZone: _DateFilter(
        selectedRange: _presenter.dateRange,
        selectedQuickRange: _presenter.selectedQuickRange,
        onQuickSelect: _presenter.selectQuickRange,
        onTap: _pickDateRange,
      ),
      dynamicContent: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          104,
        ),
        children: [
          _DashboardPerformanceHero(
            report: report,
            dateRange: _presenter.dateRange,
            onOpenReport: () => context.go(AppRoutes.adminRevenue),
          ),
          const SizedBox(height: AppSpacing.lg),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.8,
            children: [
              _KpiCard(
                title: 'Tổng doanh thu',
                value:
                    '${NumberFormat.decimalPattern("vi_VN").format(report.totalRevenue)}đ',
                icon: Icons.attach_money_outlined,
                background: const Color(0xFF2563EB),
                helper: 'Trong kỳ đã chọn',
              ),
              _KpiCard(
                title: 'Tổng đơn hàng',
                value: '${report.totalOrders}',
                icon: Icons.shopping_cart_outlined,
                background: const Color(0xFF16A34A),
                helper: 'Đơn phát sinh',
              ),
              _KpiCard(
                title: 'Người dùng mới',
                value: '${report.newUsers}',
                icon: Icons.person_add_outlined,
                background: AdminColors.action,
                helper: 'Tài khoản mới',
              ),
              _KpiCard(
                title: 'Đơn chờ xử lý',
                value: '${report.pendingOrders}',
                icon: Icons.pending_actions_outlined,
                background: const Color(0xFFF97316),
                helper: report.pendingOrders > 0
                    ? 'Cần kiểm tra ngay'
                    : 'Không có tồn đọng',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── REVENUE OVERVIEW ───────────────────────────────────────────────
          _RevenueChart(
            title: 'Xu hướng doanh thu',
            report: report,
            dateRange: _presenter.dateRange,
          ),
          const SizedBox(height: AppSpacing.lg),

          _OperationsSection(
            pendingOrders: '${report.pendingOrders}',
            newUsers: '${report.newUsers}',
            onOrders: () => context.go(AppRoutes.adminOrders),
            onDelivery: () => context.go(AppRoutes.adminDeliveryMonitoring),
          ),
          const SizedBox(height: AppSpacing.lg),

          const _QuickActions(),
          const SizedBox(height: AppSpacing.lg),

          _TodayOverviewSection(
            pendingOrders: '${report.pendingOrders}',
            pendingOrdersCount: report.pendingOrders,
            newUsers: '${report.newUsers}',
          ),
        ],
      ),
    );
  }
}
