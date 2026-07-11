import '../../core/network/api_client.dart';
import '../../model/delivery/delivery_assignment_model.dart';
import '../../model/delivery/delivery_report_model.dart';

abstract interface class DeliveryOperationsService {
  Future<List<DeliveryAssignmentModel>> getAssignments({String? staffId});

  Future<DeliveryAssignmentModel> assignOrder({
    required String orderId,
    required String staffId,
    String? note,
  });

  Future<DeliveryAssignmentModel> updateAssignment({
    required String id,
    required String orderId,
    required String staffId,
    String? note,
  });

  Future<void> deleteAssignment(String id);

  Future<List<DeliveryReportModel>> getAllReports();

  Future<List<DeliveryReportModel>> getReportsByOrder(String orderId);

  Future<DeliveryReportModel> createReport({
    required String orderId,
    required String status,
    required String reason,
    String? note,
    String? evidenceImageUrl,
  });

  Future<DeliveryReportModel> updateReport({
    required String id,
    required String status,
    required String reason,
    String? note,
    String? evidenceImageUrl,
  });

  Future<void> deleteReport(String id);
}

class DeliveryOperationsApiService implements DeliveryOperationsService {
  const DeliveryOperationsApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<DeliveryAssignmentModel>> getAssignments({
    String? staffId,
  }) async {
    final json = await _apiClient.getJson(
      '/admin/order-assignments',
      queryParameters: staffId == null || staffId.isEmpty
          ? null
          : {'staffId': staffId},
    );
    return _parseList(
      json,
    ).map((item) => DeliveryAssignmentModel.fromJson(item)).toList();
  }

  @override
  Future<DeliveryAssignmentModel> assignOrder({
    required String orderId,
    required String staffId,
    String? note,
  }) async {
    final json = await _apiClient.putJson(
      '/admin/order-assignments/orders/$orderId',
      data: {'staffId': int.tryParse(staffId), 'note': note ?? ''},
    );
    return DeliveryAssignmentModel.fromJson(_parseObject(json));
  }

  @override
  Future<DeliveryAssignmentModel> updateAssignment({
    required String id,
    required String orderId,
    required String staffId,
    String? note,
  }) async {
    final json = await _apiClient.putJson(
      '/admin/order-assignments/$id',
      data: {
        'orderId': int.tryParse(orderId.replaceAll('#', '')),
        'staffId': int.tryParse(staffId),
        'note': note ?? '',
      },
    );
    return DeliveryAssignmentModel.fromJson(_parseObject(json));
  }

  @override
  Future<void> deleteAssignment(String id) async {
    await _apiClient.deleteJson('/admin/order-assignments/$id');
  }

  @override
  Future<List<DeliveryReportModel>> getAllReports() async {
    final json = await _apiClient.getJson('/admin/delivery-reports');
    return _parseList(
      json,
    ).map((item) => DeliveryReportModel.fromJson(item)).toList();
  }

  @override
  Future<List<DeliveryReportModel>> getReportsByOrder(String orderId) async {
    final json = await _apiClient.getJson(
      '/orders/${orderId.replaceAll('#', '')}/delivery-reports',
    );
    return _parseList(
      json,
    ).map((item) => DeliveryReportModel.fromJson(item)).toList();
  }

  @override
  Future<DeliveryReportModel> createReport({
    required String orderId,
    required String status,
    required String reason,
    String? note,
    String? evidenceImageUrl,
  }) async {
    final json = await _apiClient.postJson(
      '/orders/${orderId.replaceAll('#', '')}/delivery-reports',
      data: {
        'status': status,
        'reason': reason,
        'note': note ?? '',
        'evidenceImageUrl': evidenceImageUrl ?? '',
      },
    );
    return DeliveryReportModel.fromJson(_parseObject(json));
  }

  @override
  Future<DeliveryReportModel> updateReport({
    required String id,
    required String status,
    required String reason,
    String? note,
    String? evidenceImageUrl,
  }) async {
    final json = await _apiClient.putJson(
      '/admin/delivery-reports/$id',
      data: {
        'status': status,
        'reason': reason,
        'note': note ?? '',
        'evidenceImageUrl': evidenceImageUrl ?? '',
      },
    );
    return DeliveryReportModel.fromJson(_parseObject(json));
  }

  @override
  Future<void> deleteReport(String id) async {
    await _apiClient.deleteJson('/admin/delivery-reports/$id');
  }

  List<Map<String, dynamic>> _parseList(Map<String, dynamic> json) {
    final rawItems = json['result'] ?? json['data'] ?? json['content'] ?? json;
    if (rawItems is! List) {
      return const [];
    }
    return rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Map<String, dynamic> _parseObject(Map<String, dynamic> json) {
    final rawItem = json['result'] ?? json['data'] ?? json;
    if (rawItem is Map) {
      return Map<String, dynamic>.from(rawItem);
    }
    return const {};
  }
}
