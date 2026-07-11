// ──────────────────────────────────────────────────────────────────────────────
//  Admin Revenue Report – PHẦN 2: BÁO CÁO DOANH THU CHI TIẾT (INTERACTIVE VERSION)
//  Architecture: View → Presenter (ChangeNotifier) → Repository
//  UI Style: premium, card‑first, mobile‑native
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/widgets/app_state.dart';
import '../../presenter/admin/admin_revenue_report_presenter.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'admin_revenue_report_page_parts/revenue_report_widgets.dart';

class AdminRevenueReportPage extends StatefulWidget {
  const AdminRevenueReportPage({super.key});

  @override
  State<AdminRevenueReportPage> createState() => _AdminRevenueReportPageState();
}

class _AdminRevenueReportPageState extends State<AdminRevenueReportPage> {
  late final AdminRevenueReportPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = AdminRevenueReportPresenter(
      adminReportRepository: AppDependencies.instance.adminReportRepository,
    );
    _presenter.addListener(_onControllerChanged);
    _presenter.loadReport();
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
    await _pickPeriod(_presenter.selectedPreset);
  }

  Future<void> _onPresetSelected(String preset) => _pickPeriod(preset);

  Future<void> _pickPeriod(String preset) async {
    final selection = await RevenuePeriodPicker.show(
      context: context,
      preset: preset,
      currentRange: _presenter.dateRange,
    );
    if (selection == null || !mounted) return;
    final validationMessage = _presenter.validateDateRange(
      selection.range,
      preset: selection.preset,
    );
    if (validationMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }
    _presenter.updateDateRange(selection.range, preset: selection.preset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Báo cáo doanh thu'),
      body: RefreshIndicator(
        onRefresh: _presenter.loadReport,
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
        onAction: _presenter.loadReport,
      );
    }
    final report = _presenter.dashboardReport;
    if (report == null) {
      return const PremiumEmptyState(
        icon: Icons.bar_chart,
        title: 'Chưa có dữ liệu doanh thu',
        message:
            'Hãy chọn khoảng thời gian khác hoặc kiểm tra lại dữ liệu hệ thống.',
      );
    }

    return AbsolutePersistentLayout(
      title: 'Báo cáo doanh thu',
      subtitle: 'Doanh thu chỉ tính đơn đã hoàn thành trong khoảng thời gian',
      icon: Icons.show_chart_outlined,
      trailing: IconButton(
        tooltip: 'Chọn khoảng ngày',
        icon: const Icon(Icons.date_range_rounded),
        onPressed: _pickDateRange,
      ),
      filterAndSearchZone: DateFilterRow(
        selectedRange: _presenter.dateRange,
        selectedPreset: _presenter.selectedPreset,
        onQuickSelect: _onPresetSelected,
        onTap: _pickDateRange,
      ),
      dynamicContent: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── HERO REVENUE CARD ────────────────────────────────────────
          RevenueHeroCard(report: report),
          const SizedBox(height: AppSpacing.lg),

          // ── 3 MINI SUMMARY CARDS ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: MiniSummaryCard(
                  title: 'Tổng đơn',
                  value: '${report.totalOrders}',
                  icon: Icons.shopping_bag_outlined,
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: MiniSummaryCard(
                  title: 'User mới',
                  value: '${report.newUsers}',
                  icon: Icons.person_add_outlined,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: MiniSummaryCard(
                  title: 'Chờ xử lý',
                  value: '${report.pendingOrders}',
                  icon: Icons.pending_actions_outlined,
                  color: const Color(0xFFF97316),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── DOANH THU THEO NGÀY CHART CARD ─────────────────────────────
          RevenueDailyChartCard(report: report),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
