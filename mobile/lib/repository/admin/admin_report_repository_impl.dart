import '../../model/admin/dashboard_report_model.dart';
import '../../service/admin/admin_report_service.dart';
import 'admin_report_repository.dart';

class AdminReportRepositoryImpl implements AdminReportRepository {
  const AdminReportRepositoryImpl(this._adminReportService);

  final AdminReportService _adminReportService;

  @override
  Future<DashboardReportModel> getDashboardReport({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _adminReportService.getDashboardReport(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
