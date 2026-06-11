import '../../model/admin/dashboard_report_model.dart';

abstract interface class AdminReportRepository {
  Future<DashboardReportModel> getDashboardReport({
    required DateTime startDate,
    required DateTime endDate,
  });
}
