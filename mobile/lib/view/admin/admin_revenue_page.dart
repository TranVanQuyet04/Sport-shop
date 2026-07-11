// ──────────────────────────────────────────────────────────────────────────────
//  Admin Revenue – PHẦN 2: BÁO CÁO DOANH THU CHI TIẾT
//  Architecture: View → Presenter (ChangeNotifier) → Repository
//  UI Style: premium, card-first, mobile-native
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/dashboard_report_model.dart';
import '../../presenter/admin/admin_dashboard_presenter.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminRevenuePage extends StatefulWidget {
  const AdminRevenuePage({super.key});

  @override
  State<AdminRevenuePage> createState() => _AdminRevenuePageState();
}

class _AdminRevenuePageState extends State<AdminRevenuePage> {
  late final AdminDashboardPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = AdminDashboardPresenter(
      adminReportRepository: AppDependencies.instance.adminReportRepository,
    );
    _presenter.addListener(_onChanged);
    _presenter.loadDashboard();
  }

  @override
  void dispose() {
    _presenter.removeListener(_onChanged);
    _presenter.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
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
      appBar: const AdminAppBar(title: 'Báo cáo doanh thu'),
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

    final moneyFmt = NumberFormat.decimalPattern('vi_VN');
    final formattedRevenue = moneyFmt.format(report.totalRevenue);

    return AbsolutePersistentLayout(
      title: 'Báo cáo doanh thu',
      subtitle: 'Xem dữ liệu kinh doanh chi tiết trong kỳ',
      icon: Icons.analytics_outlined,
      trailing: IconButton(
        tooltip: 'Chọn khoảng ngày',
        icon: const Icon(Icons.date_range_rounded),
        onPressed: _pickDateRange,
      ),
      filterAndSearchZone: _DateFilterRow(
        selectedRange: _presenter.dateRange,
        onQuickSelect: _presenter.selectQuickRange,
        onTap: _pickDateRange,
      ),
      dynamicContent: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Total Revenue Hero Card
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TỔNG DOANH THU',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$formattedRevenueđ',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.greenAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tính trên trạng thái đã hoàn tất',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Operating Stats Row
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Sức mua',
                  value: '${report.totalOrders} đơn',
                  subtitle: '${report.pendingOrders} đơn chờ',
                  icon: Icons.local_mall_outlined,
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MetricCard(
                  label: 'Tương tác mới',
                  value: '${report.newUsers} user',
                  subtitle: 'Đăng ký thành công',
                  icon: Icons.people_outline,
                  color: AdminColors.action,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Chart summary title
          const Text(
            'Phân bổ dòng tiền',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Visual graph layout
          _RevenueVisualSummary(report: report),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AdminColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AdminColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueVisualSummary extends StatelessWidget {
  const _RevenueVisualSummary({required this.report});

  final DashboardReportModel report;

  @override
  Widget build(BuildContext context) {
    final maxVal = report.totalOrders > 0 ? report.totalOrders : 1;
    final stats = [
      (
        'Đơn chờ xử lý',
        report.pendingOrders,
        const Color(0xFFF97316),
        'Có thể chuyển đổi thành doanh số qua phê duyệt',
      ),
      (
        'Đơn hoàn tất',
        report.totalOrders - report.pendingOrders,
        const Color(0xFF16A34A),
        'Trực tiếp đóng góp dòng tiền trong kỳ',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.inputBorder),
      ),
      child: Column(
        children: [
          for (final (title, val, color, desc) in stats) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                      Text(
                        '$val đơn',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (val / maxVal).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AdminColors.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: AppTextStyles.caption.copyWith(
                      color: AdminColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateFilterRow extends StatelessWidget {
  const _DateFilterRow({
    required this.selectedRange,
    required this.onQuickSelect,
    required this.onTap,
  });

  final DateTimeRange? selectedRange;
  final void Function(String) onQuickSelect;
  final VoidCallback onTap;

  String _formatRange(DateTimeRange range) =>
      '${DateFormat('dd/MM/yyyy').format(range.start)} – ${DateFormat('dd/MM/yyyy').format(range.end)}';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AdminColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminColors.inputBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.date_range_outlined,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedRange != null
                          ? _formatRange(selectedRange!)
                          : 'Chọn khoảng ngày',
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _QuickFilterChip(label: '7N', value: '7d', onSelect: onQuickSelect),
        const SizedBox(width: AppSpacing.xs),
        _QuickFilterChip(label: '30N', value: '30d', onSelect: onQuickSelect),
      ],
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  const _QuickFilterChip({
    required this.label,
    required this.value,
    required this.onSelect,
  });

  final String label;
  final String value;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AdminColors.primarySoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AdminColors.primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AdminColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
