// ignore_for_file: unused_element

part of '../admin_dashboard_page.dart';

class _DashboardPerformanceHero extends StatelessWidget {
  const _DashboardPerformanceHero({
    required this.report,
    required this.dateRange,
    required this.onOpenReport,
  });

  final DashboardReportModel report;
  final DateTimeRange? dateRange;
  final VoidCallback onOpenReport;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.compactCurrency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 1,
    );
    final currentRevenue = report.dailyRevenues.fold<int>(
      0,
      (sum, item) => sum + item.revenueCurrent,
    );
    final previousRevenue = report.dailyRevenues.fold<int>(
      0,
      (sum, item) => sum + item.revenuePrevious,
    );
    final change = previousRevenue == 0
        ? null
        : ((currentRevenue - previousRevenue) / previousRevenue) * 100;
    final averageOrder = report.totalOrders == 0
        ? 0
        : report.totalRevenue ~/ report.totalOrders;

    return HoverLift(
      scale: 1.006,
      dy: -2,
      borderRadius: BorderRadius.circular(_DashboardStyle.radius),
      child: Material(
        color: AdminColors.primary,
        borderRadius: BorderRadius.circular(_DashboardStyle.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpenReport,
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Ink(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AdminColors.primary, Color(0xFF0D3D67)],
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  right: -12,
                  top: 18,
                  child: Icon(
                    Icons.sports_score_rounded,
                    size: 104,
                    color: Color(0x14FFFFFF),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AdminColors.green.withValues(alpha: 0.17),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AdminColors.green.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.sync_rounded,
                                  size: 13,
                                  color: Color(0xFF7AE5A5),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'ĐỒNG BỘ BACKEND',
                                  style: AppTextStyles.caption.copyWith(
                                    color: const Color(0xFFB7F3CD),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_outward_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Hiệu suất cửa hàng',
                        style: AppTextStyles.title.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _periodLabel(dateRange),
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _HeroMetric(
                              label: 'Doanh thu',
                              value: currency.format(report.totalRevenue),
                              trend: change == null
                                  ? 'Chưa có kỳ trước'
                                  : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                              positive: change == null || change >= 0,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 48,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _HeroMetric(
                              label: 'Giá trị / đơn',
                              value: currency.format(averageOrder),
                              trend: '${report.totalOrders} đơn trong kỳ',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _periodLabel(DateTimeRange? range) {
    if (range == null) return 'Tổng hợp dữ liệu vận hành mới nhất';
    final format = DateFormat('dd/MM/yyyy');
    return '${format.format(range.start)} - ${format.format(range.end)}';
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.trend,
    this.positive = true,
  });

  final String label;
  final String value;
  final String trend;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.68),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.title.copyWith(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          trend,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(
            color: positive ? const Color(0xFF8CE8AF) : const Color(0xFFFFB382),
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _OperationsSection extends StatelessWidget {
  const _OperationsSection({
    required this.pendingOrders,
    required this.newUsers,
    required this.onOrders,
    required this.onDelivery,
  });

  final String pendingOrders;
  final String newUsers;
  final VoidCallback onOrders;
  final VoidCallback onDelivery;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Tình hình vận hành',
            subtitle: 'Các chỉ số cần quan tâm trong ngày',
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _SnapshotMetric(
                  label: 'Chờ xử lý',
                  value: pendingOrders,
                  icon: Icons.pending_actions_outlined,
                  accent: _DashboardColors.orange,
                  softAccent: _DashboardColors.orangeSoft,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SnapshotMetric(
                  label: 'User mới',
                  value: newUsers,
                  icon: Icons.group_add_outlined,
                  accent: _DashboardColors.purple,
                  softAccent: _DashboardColors.purpleSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _OperationButton(
                  icon: Icons.receipt_long_outlined,
                  label: 'Đơn hàng',
                  primary: true,
                  onPressed: onOrders,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _OperationButton(
                  icon: Icons.local_shipping_outlined,
                  label: 'Giao hàng',
                  onPressed: onDelivery,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnapshotMetric extends StatelessWidget {
  const _SnapshotMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.softAccent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final Color softAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _DashboardColors.subtle,
        borderRadius: BorderRadius.circular(_DashboardStyle.radius),
      ),
      child: Row(
        children: [
          _IconBadge(
            icon: icon,
            background: softAccent,
            foreground: accent,
            size: 38,
            iconSize: 19,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    color: _DashboardColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: _DashboardColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationButton extends StatelessWidget {
  const _OperationButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      scale: 1.01,
      dy: -1,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 48,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              gradient: primary
                  ? const LinearGradient(
                      colors: [
                        _DashboardColors.blue,
                        _DashboardColors.blueDark,
                      ],
                    )
                  : null,
              color: primary ? null : _DashboardColors.blueSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              onTap: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 19,
                    color: primary ? Colors.white : _DashboardColors.blue,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.button.copyWith(
                        color: primary ? Colors.white : _DashboardColors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
