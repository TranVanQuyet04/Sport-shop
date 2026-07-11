import '../../model/admin/leave_request_model.dart';
import '../../model/admin/work_shift_model.dart';

abstract interface class AdminStaffOperationsRepository {
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
