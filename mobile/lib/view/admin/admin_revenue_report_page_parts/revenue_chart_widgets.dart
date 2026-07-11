import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../model/admin/dashboard_report_model.dart';
import '../widgets/admin_design_system.dart';
import 'revenue_chart_components.dart';

// ── DAILY CHART CARD (INTERACTIVE) ──────────────────────────────────────────
class RevenueDailyChartCard extends StatefulWidget {
  const RevenueDailyChartCard({super.key, required this.report});

  final DashboardReportModel report;

  @override
  State<RevenueDailyChartCard> createState() => RevenueDailyChartCardState();
}

class RevenueDailyChartCardState extends State<RevenueDailyChartCard> {
  int _selectedIndex = 6; // Default to Sunday (CN)

  @override
  Widget build(BuildContext context) {
    final moneyFmt = NumberFormat.decimalPattern('vi_VN');

    // Load dynamic daily revenues or fallback to empty template if API returns empty
    final rawRevenues = widget.report.dailyRevenues;
    final List<DailyRevenueModel> revenues = rawRevenues.isNotEmpty
        ? rawRevenues
        : List.generate(7, (index) {
            final days = [
              'Thứ Hai',
              'Thứ Ba',
              'Thứ Tư',
              'Thứ Năm',
              'Thứ Sáu',
              'Thứ Bảy',
              'Chủ Nhật',
            ];
            final shortDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
            return DailyRevenueModel(
              dayOfWeek: days[index],
              dateStr: shortDays[index],
              revenueCurrent: 0,
              revenuePrevious: 0,
              ordersCount: 0,
            );
          });

    final activeIndex = _selectedIndex >= revenues.length
        ? revenues.length - 1
        : _selectedIndex;

    // Find the maximum revenue value to normalize bar heights
    int maxRevenueVal = 1000;
    for (final day in revenues) {
      if (day.revenueCurrent > maxRevenueVal) {
        maxRevenueVal = day.revenueCurrent;
      }
      if (day.revenuePrevious > maxRevenueVal) {
        maxRevenueVal = day.revenuePrevious;
      }
    }

    final selectedDay = revenues[activeIndex];
    final currentRev = selectedDay.revenueCurrent;
    final prevRev = selectedDay.revenuePrevious;
    final ordersCount = selectedDay.ordersCount;

    // Calculate percentage increase
    final double changePercent = prevRev > 0
        ? ((currentRev - prevRev) / prevRev) * 100
        : 0.0;
    final hasPreviousRevenue = prevRev > 0;
    final changeText = hasPreviousRevenue
        ? (changePercent >= 0
              ? '+${changePercent.toStringAsFixed(1)}%'
              : '${changePercent.toStringAsFixed(1)}%')
        : 'Mới';
    final changeColor = changePercent >= 0
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AdminColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stacked_bar_chart_rounded,
                  color: Color(0xFF1E40AF),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phân bố doanh thu theo thứ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Gom các đơn hoàn tất theo thứ trong kỳ đã chọn',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              RevenueLegendItem(
                color: const Color(0xFF2563EB),
                label: 'Kỳ này',
              ),
              RevenueLegendItem(color: Colors.grey.shade400, label: 'Kỳ trước'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Interactive Tooltip Panel showing exact numbers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDay.dayOfWeek,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    // Growth Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: changeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: changeColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            changePercent >= 0
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 11,
                            color: changeColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            changeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: changeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Kỳ này Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kỳ này',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${moneyFmt.format(currentRev)}đ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$ordersCount đơn hàng',
                            style: TextStyle(
                              fontSize: 11,
                              color: AdminColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Vertical divider line
                    Container(
                      width: 1,
                      height: 40,
                      color: AdminColors.inputBorder,
                    ),
                    const SizedBox(width: 16),
                    // Kỳ trước Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kỳ trước',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasPreviousRevenue
                                ? '${moneyFmt.format(prevRev)}đ'
                                : 'Chưa có',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '—',
                            style: TextStyle(
                              fontSize: 11,
                              color: AdminColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Beautiful Bar Chart Representation
          SizedBox(
            height: 166,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(revenues.length, (index) {
                final dayData = revenues[index];
                final isSelected = index == activeIndex;
                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: 'Xem doanh thu ${dayData.dayOfWeek}',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: RevenueBarItem(
                        day: dayData.dateStr,
                        valueCurrent: dayData.revenueCurrent / maxRevenueVal,
                        valuePrev: dayData.revenuePrevious / maxRevenueVal,
                        isSelected: isSelected,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
