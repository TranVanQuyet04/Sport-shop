import '../../core/network/api_client.dart';
import '../../model/admin/leave_request_model.dart';
import '../../model/admin/work_shift_model.dart';

abstract interface class AdminStaffOperationsService {
  Future<List<WorkShiftModel>> getWorkShifts({
    String? userId,
    String? startDate,
    String? endDate,
  });

  Future<WorkShiftModel> createWorkShift({
    required String userId,
    required String shiftDate,
    required String shiftCode,
    String? note,
  });

  Future<WorkShiftModel> updateWorkShift({
    required String id,
    required String userId,
    required String shiftDate,
    required String shiftCode,
    String? note,
  });

  Future<void> deleteWorkShift(String id);

  Future<List<LeaveRequestModel>> getLeaveRequests();

  Future<LeaveRequestModel> createLeaveRequest({
    required String userId,
    required String startDate,
    required int days,
    required String reason,
  });

  Future<LeaveRequestModel> updateLeaveRequest({
    required String id,
    required String userId,
    required String startDate,
    required int days,
    required String reason,
  });

  Future<LeaveRequestModel> decideLeaveRequest({
    required String id,
    required String status,
  });

  Future<void> deleteLeaveRequest(String id);
}

class AdminStaffOperationsApiService implements AdminStaffOperationsService {
  const AdminStaffOperationsApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<WorkShiftModel>> getWorkShifts({
    String? userId,
    String? startDate,
    String? endDate,
  }) async {
    final query = <String, dynamic>{
      if (userId != null && userId.isNotEmpty) 'userId': userId,
      if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
      if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
    };
    final json = await _apiClient.getJson(
      '/admin/work-shifts',
      queryParameters: query.isEmpty ? null : query,
    );
    return _parseList(
      json,
    ).map((item) => WorkShiftModel.fromJson(item)).toList();
  }

  @override
  Future<WorkShiftModel> createWorkShift({
    required String userId,
    required String shiftDate,
    required String shiftCode,
    String? note,
  }) async {
    final json = await _apiClient.postJson(
      '/admin/work-shifts',
      data: {
        'userId': int.tryParse(userId),
        'shiftDate': shiftDate,
        'shiftCode': shiftCode,
        'note': note ?? '',
      },
    );
    return WorkShiftModel.fromJson(_parseObject(json));
  }

  @override
  Future<WorkShiftModel> updateWorkShift({
    required String id,
    required String userId,
    required String shiftDate,
    required String shiftCode,
    String? note,
  }) async {
    final json = await _apiClient.putJson(
      '/admin/work-shifts/$id',
      data: {
        'userId': int.tryParse(userId),
        'shiftDate': shiftDate,
        'shiftCode': shiftCode,
        'note': note ?? '',
      },
    );
    return WorkShiftModel.fromJson(_parseObject(json));
  }

  @override
  Future<void> deleteWorkShift(String id) async {
    await _apiClient.deleteJson('/admin/work-shifts/$id');
  }

  @override
  Future<List<LeaveRequestModel>> getLeaveRequests() async {
    final json = await _apiClient.getJson('/admin/leave-requests');
    return _parseList(
      json,
    ).map((item) => LeaveRequestModel.fromJson(item)).toList();
  }

  @override
  Future<LeaveRequestModel> createLeaveRequest({
    required String userId,
    required String startDate,
    required int days,
    required String reason,
  }) async {
    final json = await _apiClient.postJson(
      '/user/leave-requests',
      data: {
        'userId': int.tryParse(userId),
        'startDate': startDate,
        'days': days,
        'reason': reason,
      },
    );
    return LeaveRequestModel.fromJson(_parseObject(json));
  }

  @override
  Future<LeaveRequestModel> updateLeaveRequest({
    required String id,
    required String userId,
    required String startDate,
    required int days,
    required String reason,
  }) async {
    final json = await _apiClient.putJson(
      '/admin/leave-requests/$id',
      data: {
        'userId': int.tryParse(userId),
        'startDate': startDate,
        'days': days,
        'reason': reason,
      },
    );
    return LeaveRequestModel.fromJson(_parseObject(json));
  }

  @override
  Future<LeaveRequestModel> decideLeaveRequest({
    required String id,
    required String status,
  }) async {
    final json = await _apiClient.patchJson(
      '/admin/leave-requests/$id/decision',
      data: {'status': status},
    );
    return LeaveRequestModel.fromJson(_parseObject(json));
  }

  @override
  Future<void> deleteLeaveRequest(String id) async {
    await _apiClient.deleteJson('/admin/leave-requests/$id');
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
