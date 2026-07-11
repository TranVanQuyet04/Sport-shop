import 'package:flutter/material.dart';

import '../../model/admin/dashboard_report_model.dart';
import '../../repository/admin/admin_report_repository.dart';

class AdminRevenueReportPresenter extends ChangeNotifier {
  AdminRevenueReportPresenter({required this.adminReportRepository}) {
    dateRange = _currentMonthRange();
  }

  final AdminReportRepository adminReportRepository;

  static const int maxCustomRangeDays = 30;

  // Exposed fields for the view
  DashboardReportModel? dashboardReport;
  DateTimeRange? dateRange;
  String selectedPreset = 'month';

  bool isLoading = false;
  String? errorMessage;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  Future<void> loadReport() async {
    isLoading = true;
    errorMessage = null;
    _safeNotifyListeners();

    // In case dateRange wasn't initialized
    dateRange ??= _currentMonthRange();

    try {
      final model = await adminReportRepository.getDashboardReport(
        startDate: dateRange!.start,
        endDate: dateRange!.end,
      );
      dashboardReport = model;
    } catch (e) {
      dashboardReport = null;
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Quick range selection helper
  void selectQuickRange(String identifier) {
    final now = DateTime.now();
    DateTime start;
    switch (identifier) {
      case 'day':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        final today = DateTime(now.year, now.month, now.day);
        start = today.subtract(Duration(days: today.weekday - 1));
        break;
      case 'month':
        start = DateTime(now.year, now.month);
        break;
      case 'quarter':
        final quarterStartMonth = (((now.month - 1) ~/ 3) * 3) + 1;
        start = DateTime(now.year, quarterStartMonth);
        break;
      case 'year':
        start = DateTime(now.year);
        break;
      default:
        start = DateTime(now.year, now.month);
        identifier = 'month';
    }
    selectedPreset = identifier;
    dateRange = DateTimeRange(start: start, end: now);
    loadReport();
  }

  String? validateDateRange(DateTimeRange range, {String preset = 'custom'}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    if (start.isAfter(end)) {
      return 'Ngày bắt đầu phải trước ngày kết thúc.';
    }
    if (end.isAfter(today)) {
      return 'Không thể xem báo cáo cho thời gian trong tương lai.';
    }
    if (preset == 'custom' &&
        end.difference(start).inDays + 1 > maxCustomRangeDays) {
      return 'Khoảng tùy chỉnh không được vượt quá $maxCustomRangeDays ngày.';
    }
    return null;
  }

  // Update date range from UI picker after validating reporting rules.
  bool updateDateRange(DateTimeRange range, {String preset = 'custom'}) {
    if (validateDateRange(range, preset: preset) != null) return false;
    selectedPreset = preset;
    dateRange = range;
    loadReport();
    return true;
  }

  DateTimeRange _currentMonthRange() {
    final now = DateTime.now();
    return DateTimeRange(start: DateTime(now.year, now.month), end: now);
  }
}
