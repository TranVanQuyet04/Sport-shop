import '../../core/network/api_client.dart';
import '../../model/admin/dashboard_report_model.dart';

abstract interface class AdminReportService {
  Future<DashboardReportModel> getDashboardReport({
    required DateTime startDate,
    required DateTime endDate,
  });
}

class AdminReportApiService implements AdminReportService {
  const AdminReportApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DashboardReportModel> getDashboardReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEnd = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
      999,
    );
    final json = await _apiClient.getJson(
      '/admin/reports/dashboard',
      queryParameters: {
        'startDate': normalizedStart.toIso8601String(),
        'endDate': normalizedEnd.toIso8601String(),
      },
    );
    return DashboardReportModel.fromJson(json);
  }
}
