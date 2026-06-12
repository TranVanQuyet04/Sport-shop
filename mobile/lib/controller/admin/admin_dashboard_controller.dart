import 'package:flutter/foundation.dart';

import '../../core/mock/admin_demo_data.dart';
import '../../model/admin/dashboard_report_model.dart';
import '../../repository/admin/admin_report_repository.dart';

class AdminDashboardController extends ChangeNotifier {
  AdminDashboardController({required this.adminReportRepository});

  final AdminReportRepository adminReportRepository;

  DashboardReportModel? report;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      report = await adminReportRepository.getDashboardReport(
        startDate: startOfDay,
        endDate: now,
      );
    } catch (error) {
      report = AdminDemoData.dashboardReport;
      errorMessage =
          'Đang hiển thị dashboard mẫu vì chưa kết nối được backend.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
