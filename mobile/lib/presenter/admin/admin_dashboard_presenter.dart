import 'package:flutter/material.dart';

import '../../model/admin/dashboard_report_model.dart';
import '../../repository/admin/admin_report_repository.dart';

class AdminDashboardPresenter extends ChangeNotifier {
  AdminDashboardPresenter({required this.adminReportRepository});

  // Exposed fields for the view
  DashboardReportModel? dashboardReport;
  DateTimeRange? dateRange;
  String? selectedQuickRange = '30d';

  final AdminReportRepository adminReportRepository;

  // Deprecated internal field (kept for backward compatibility)
  DashboardReportModel? _report;

  bool isLoading = false;
  String? errorMessage;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    _safeNotifyListeners();

    final now = DateTime.now();
    // Default: last 30 days so demo data is visible immediately
    final today = DateTime(now.year, now.month, now.day);
    final startOf30Days = today.subtract(const Duration(days: 29));
    // Keep existing dateRange if user already picked one; otherwise init to 30 days
    dateRange ??= DateTimeRange(start: startOf30Days, end: now);

    try {
      _report = await adminReportRepository.getDashboardReport(
        startDate: dateRange!.start,
        endDate: dateRange!.end,
      );
      dashboardReport = _report;
    } catch (error) {
      _report = null;
      dashboardReport = null;
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Quick range selection helper
  void selectQuickRange(String identifier) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime start;
    switch (identifier) {
      case 'today':
        start = today;
        break;
      case '7d':
        start = today.subtract(const Duration(days: 6));
        break;
      case '30d':
        start = today.subtract(const Duration(days: 29));
        break;
      default:
        return;
    }
    selectedQuickRange = identifier;
    dateRange = DateTimeRange(start: start, end: today);
    // Reload data for the new range
    loadDashboard();
  }

  // Update date range from UI picker
  void updateDateRange(DateTimeRange range) {
    selectedQuickRange = null;
    dateRange = range;
    loadDashboard();
  }
}
