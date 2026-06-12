import '../../model/admin/dashboard_report_model.dart';

abstract final class AdminDemoData {
  static const dashboardReport = DashboardReportModel(
    totalRevenue: 128450000,
    totalOrders: 64,
    newUsers: 18,
    pendingOrders: 12,
  );
}
