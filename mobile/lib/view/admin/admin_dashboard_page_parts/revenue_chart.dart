part of '../admin_dashboard_page.dart';

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({
    required this.title,
    required this.report,
    required this.dateRange,
  });

  final String title;
  final DashboardReportModel report;
  final DateTimeRange? dateRange;

  @override
  Widget build(BuildContext context) {
    final moneyFormat = NumberFormat.decimalPattern('vi_VN');
    final values = report.dailyRevenues.length > 7
        ? report.dailyRevenues.sublist(report.dailyRevenues.length - 7)
        : report.dailyRevenues;

    return AdminSurface(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AdminIconBadge(
                icon: Icons.insights_rounded,
                backgroundColor: AdminColors.actionSoft,
                color: AdminColors.action,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AdminColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      values.isEmpty
                          ? 'Chưa có dữ liệu theo ngày'
                          : 'So sánh kỳ hiện tại với kỳ trước',
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: AdminColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => context.go(AppRoutes.adminRevenue),
                  borderRadius: BorderRadius.circular(8),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AdminColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${moneyFormat.format(report.totalRevenue)}đ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.display.copyWith(
              color: AdminColors.primary,
              fontSize: 29,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _rangeLabel(dateRange),
            style: AppTextStyles.caption.copyWith(
              color: AdminColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              _ChartLegend(color: AdminColors.action, label: 'Kỳ này'),
              SizedBox(width: AppSpacing.md),
              _ChartLegend(color: AdminColors.border, label: 'Kỳ trước'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (values.isEmpty)
            const _RevenueEmptyChart()
          else
            _DailyComparisonChart(values: values),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _MiniStat(
                label: 'Chờ xử lý',
                value: '${report.pendingOrders}',
                color: AdminColors.orange,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniStat(
                label: 'Tổng đơn',
                value: '${report.totalOrders}',
                color: AdminColors.green,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniStat(
                label: 'User mới',
                value: '${report.newUsers}',
                color: AdminColors.action,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _rangeLabel(DateTimeRange? range) {
    if (range == null) return 'Toàn bộ khoảng dữ liệu';
    final format = DateFormat('dd/MM/yyyy');
    return '${format.format(range.start)} - ${format.format(range.end)}';
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AdminColors.textSecondary,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DailyComparisonChart extends StatelessWidget {
  const _DailyComparisonChart({required this.values});

  final List<DailyRevenueModel> values;

  @override
  Widget build(BuildContext context) {
    var maxValue = 1;
    for (final item in values) {
      if (item.revenueCurrent > maxValue) maxValue = item.revenueCurrent;
      if (item.revenuePrevious > maxValue) maxValue = item.revenuePrevious;
    }

    return Semantics(
      label: 'Biểu đồ doanh thu 7 ngày gần nhất, so sánh kỳ này và kỳ trước',
      child: SizedBox(
        height: 126,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final item in values)
              Expanded(
                child: _DailyBarGroup(item: item, maxValue: maxValue),
              ),
          ],
        ),
      ),
    );
  }
}

class _DailyBarGroup extends StatelessWidget {
  const _DailyBarGroup({required this.item, required this.maxValue});

  final DailyRevenueModel item;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.compactCurrency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return Tooltip(
      message:
          '${item.dateStr}\nKỳ này: ${formatter.format(item.revenueCurrent)}\nKỳ trước: ${formatter.format(item.revenuePrevious)}\n${item.ordersCount} đơn',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _RevenueBar(
                  value: item.revenuePrevious,
                  maxValue: maxValue,
                  color: AdminColors.border,
                ),
                const SizedBox(width: 3),
                _RevenueBar(
                  value: item.revenueCurrent,
                  maxValue: maxValue,
                  color: AdminColors.action,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _shortDay(item.dayOfWeek, item.dateStr),
            maxLines: 1,
            style: AppTextStyles.caption.copyWith(
              color: AdminColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _shortDay(String day, String date) {
    final normalized = day.trim();
    if (normalized.isNotEmpty) {
      return normalized.replaceFirst('Thứ ', 'T');
    }
    final parsed = DateTime.tryParse(date);
    return parsed == null ? '--' : DateFormat('dd/MM').format(parsed);
  }
}

class _RevenueBar extends StatelessWidget {
  const _RevenueBar({
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = (value / maxValue).clamp(0.0, 1.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: 8,
      height: value == 0 ? 4 : 88 * ratio.clamp(0.08, 1.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

class _RevenueEmptyChart extends StatelessWidget {
  const _RevenueEmptyChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AdminColors.surfaceMuted,
        borderRadius: BorderRadius.circular(_DashboardStyle.radius),
      ),
      child: Text(
        'Chưa phát sinh doanh thu theo ngày',
        style: AppTextStyles.caption.copyWith(color: AdminColors.textSecondary),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(_DashboardStyle.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AdminColors.textSecondary,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
