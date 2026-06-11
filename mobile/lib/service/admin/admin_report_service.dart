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
    final json = await _apiClient.getJson(
      '/admin/reports/dashboard',
      queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
    return DashboardReportModel.fromJson(json);
  }
}
