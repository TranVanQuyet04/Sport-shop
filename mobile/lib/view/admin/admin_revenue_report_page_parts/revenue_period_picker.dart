import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/admin_design_system.dart';

part 'revenue_period_picker_widgets.dart';

class RevenuePeriodSelection {
  const RevenuePeriodSelection({required this.preset, required this.range});

  final String preset;
  final DateTimeRange range;
}

class RevenuePeriodPicker {
  const RevenuePeriodPicker._();

  static const int earliestYear = 2020;

  static Future<RevenuePeriodSelection?> show({
    required BuildContext context,
    required String preset,
    required DateTimeRange? currentRange,
  }) {
    return switch (preset) {
      'day' => _pickDay(context, currentRange),
      'week' => _pickWeek(context, currentRange),
      'month' => _pickMonth(context, currentRange),
      'quarter' => _pickQuarter(context, currentRange),
      'year' => _pickYear(context, currentRange),
      _ => _pickCustomRange(context, currentRange),
    };
  }

  static Future<RevenuePeriodSelection?> _pickDay(
    BuildContext context,
    DateTimeRange? currentRange,
  ) async {
    final now = _today();
    final result = await showDatePicker(
      context: context,
      firstDate: DateTime(earliestYear),
      lastDate: now,
      initialDate: _clampDate(currentRange?.start ?? now),
      helpText: 'Chọn ngày báo cáo',
      cancelText: 'Hủy',
      confirmText: 'Xem doanh thu',
    );
    if (result == null) return null;
    return RevenuePeriodSelection(
      preset: 'day',
      range: DateTimeRange(start: result, end: result),
    );
  }

  static Future<RevenuePeriodSelection?> _pickWeek(
    BuildContext context,
    DateTimeRange? currentRange,
  ) {
    final now = _today();
    var selectedYear = _clampYear(currentRange?.start.year ?? now.year);
    var selectedMonth = currentRange?.start.month ?? now.month;
    if (selectedYear == now.year && selectedMonth > now.month) {
      selectedMonth = now.month;
    }

    return showModalBottomSheet<RevenuePeriodSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final weeks = _weeksInMonth(selectedYear, selectedMonth, now);
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PickerHeader(
                  icon: Icons.calendar_view_week_outlined,
                  title: 'Chọn tuần theo tháng',
                  subtitle: 'Mỗi tuần được chia theo mốc 01–07, 08–14, ...',
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _YearDropdown(
                        value: selectedYear,
                        onChanged: (year) {
                          setSheetState(() {
                            selectedYear = year;
                            if (year == now.year && selectedMonth > now.month) {
                              selectedMonth = now.month;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        key: ValueKey(
                          'week-month-$selectedYear-$selectedMonth',
                        ),
                        initialValue: selectedMonth,
                        decoration: const InputDecoration(
                          labelText: 'Tháng',
                          prefixIcon: Icon(Icons.calendar_month_outlined),
                        ),
                        items: List.generate(12, (index) {
                          final month = index + 1;
                          final enabled =
                              selectedYear < now.year || month <= now.month;
                          return DropdownMenuItem(
                            value: month,
                            enabled: enabled,
                            child: Text('Tháng $month'),
                          );
                        }),
                        onChanged: (month) {
                          if (month != null) {
                            setSheetState(() => selectedMonth = month);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: weeks.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final week = weeks[index];
                    final selected = _sameRange(currentRange, week.range);
                    return _PeriodOptionTile(
                      title: 'Tuần ${index + 1}',
                      subtitle:
                          '${DateFormat('dd/MM').format(week.range.start)} – ${DateFormat('dd/MM/yyyy').format(week.range.end)}',
                      selected: selected,
                      enabled: week.enabled,
                      onTap: () => Navigator.of(context).pop(
                        RevenuePeriodSelection(
                          preset: 'week',
                          range: week.range,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Future<RevenuePeriodSelection?> _pickMonth(
    BuildContext context,
    DateTimeRange? currentRange,
  ) {
    final now = _today();
    return _showGridPeriodPicker(
      context: context,
      currentRange: currentRange,
      preset: 'month',
      title: 'Chọn tháng báo cáo',
      subtitle: 'Chọn năm, sau đó chọn một tháng',
      icon: Icons.calendar_month_outlined,
      itemCount: 12,
      labelBuilder: (index) => 'Tháng ${index + 1}',
      enabledBuilder: (year, index) =>
          year < now.year || index + 1 <= now.month,
      rangeBuilder: (year, index) {
        final month = index + 1;
        return DateTimeRange(
          start: DateTime(year, month),
          end: _minDate(DateTime(year, month + 1, 0), now),
        );
      },
    );
  }

  static Future<RevenuePeriodSelection?> _pickQuarter(
    BuildContext context,
    DateTimeRange? currentRange,
  ) {
    final now = _today();
    return _showGridPeriodPicker(
      context: context,
      currentRange: currentRange,
      preset: 'quarter',
      title: 'Chọn quý báo cáo',
      subtitle: 'Chọn năm, sau đó chọn quý cần xem',
      icon: Icons.date_range_outlined,
      itemCount: 4,
      crossAxisCount: 2,
      labelBuilder: (index) => 'Quý ${index + 1}',
      enabledBuilder: (year, index) {
        final quarterStartMonth = index * 3 + 1;
        return year < now.year || quarterStartMonth <= now.month;
      },
      rangeBuilder: (year, index) {
        final startMonth = index * 3 + 1;
        return DateTimeRange(
          start: DateTime(year, startMonth),
          end: _minDate(DateTime(year, startMonth + 3, 0), now),
        );
      },
    );
  }

  static Future<RevenuePeriodSelection?> _pickYear(
    BuildContext context,
    DateTimeRange? currentRange,
  ) {
    final now = _today();
    return _showGridPeriodPicker(
      context: context,
      currentRange: currentRange,
      preset: 'year',
      title: 'Chọn năm báo cáo',
      subtitle: 'Dữ liệu được tính từ đầu năm đến hết kỳ đã chọn',
      icon: Icons.event_note_outlined,
      itemCount: now.year - earliestYear + 1,
      crossAxisCount: 3,
      showYearDropdown: false,
      labelBuilder: (index) => '${now.year - index}',
      enabledBuilder: (_, _) => true,
      rangeBuilder: (_, index) {
        final year = now.year - index;
        return DateTimeRange(
          start: DateTime(year),
          end: _minDate(DateTime(year, 12, 31), now),
        );
      },
    );
  }

  static Future<RevenuePeriodSelection?> _pickCustomRange(
    BuildContext context,
    DateTimeRange? currentRange,
  ) async {
    final now = _today();
    var initial =
        currentRange ??
        DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now);
    if (initial.duration.inDays + 1 > 30) {
      initial = DateTimeRange(
        start: initial.end.subtract(const Duration(days: 29)),
        end: initial.end,
      );
    }
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(earliestYear),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: _clampDate(initial.start),
        end: _clampDate(initial.end),
      ),
      helpText: 'Chọn khoảng tối đa 30 ngày',
      cancelText: 'Hủy',
      saveText: 'Xem doanh thu',
    );
    if (result == null) return null;
    return RevenuePeriodSelection(preset: 'custom', range: result);
  }

  static Future<RevenuePeriodSelection?> _showGridPeriodPicker({
    required BuildContext context,
    required DateTimeRange? currentRange,
    required String preset,
    required String title,
    required String subtitle,
    required IconData icon,
    required int itemCount,
    required String Function(int index) labelBuilder,
    required bool Function(int year, int index) enabledBuilder,
    required DateTimeRange Function(int year, int index) rangeBuilder,
    int crossAxisCount = 3,
    bool showYearDropdown = true,
  }) {
    final now = _today();
    var selectedYear = _clampYear(currentRange?.start.year ?? now.year);

    return showModalBottomSheet<RevenuePeriodSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.78,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PickerHeader(icon: icon, title: title, subtitle: subtitle),
                if (showYearDropdown) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _YearDropdown(
                    value: selectedYear,
                    onChanged: (year) =>
                        setSheetState(() => selectedYear = year),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itemCount,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.85,
                  ),
                  itemBuilder: (context, index) {
                    final enabled = enabledBuilder(selectedYear, index);
                    final range = enabled
                        ? rangeBuilder(selectedYear, index)
                        : null;
                    final selected =
                        range != null && _sameRange(currentRange, range);
                    return _GridPeriodButton(
                      label: labelBuilder(index),
                      selected: selected,
                      enabled: enabled,
                      onPressed: range == null
                          ? null
                          : () => Navigator.of(context).pop(
                              RevenuePeriodSelection(
                                preset: preset,
                                range: range,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static List<_WeekOption> _weeksInMonth(int year, int month, DateTime now) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final weekCount = (daysInMonth / 7).ceil();
    return List.generate(weekCount, (index) {
      final startDay = index * 7 + 1;
      final naturalEndDay = math.min(startDay + 6, daysInMonth);
      final start = DateTime(year, month, startDay);
      final enabled = !start.isAfter(now);
      final end = _minDate(DateTime(year, month, naturalEndDay), now);
      return _WeekOption(
        range: DateTimeRange(start: start, end: enabled ? end : start),
        enabled: enabled,
      );
    });
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static int _clampYear(int year) {
    final currentYear = DateTime.now().year;
    return year.clamp(earliestYear, currentYear);
  }

  static DateTime _clampDate(DateTime date) {
    final earliest = DateTime(earliestYear);
    final now = _today();
    if (date.isBefore(earliest)) return earliest;
    if (date.isAfter(now)) return now;
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime _minDate(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

  static bool _sameRange(DateTimeRange? a, DateTimeRange b) {
    if (a == null) return false;
    return DateUtils.isSameDay(a.start, b.start) &&
        DateUtils.isSameDay(a.end, b.end);
  }
}

class _WeekOption {
  const _WeekOption({required this.range, required this.enabled});

  final DateTimeRange range;
  final bool enabled;
}
