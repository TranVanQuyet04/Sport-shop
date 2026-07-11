import '../../model/admin/leave_request_model.dart';
import '../../model/admin/work_shift_model.dart';
import '../../service/admin/admin_staff_operations_service.dart';
import 'admin_staff_operations_repository.dart';

class AdminStaffOperationsRepositoryImpl
    implements AdminStaffOperationsRepository {
  const AdminStaffOperationsRepositoryImpl(this._service);

  final AdminStaffOperationsService _service;

  @override
  Future<List<WorkShiftModel>> getWorkShifts({
    String? userId,
    String? startDate,
    String? endDate,
  }) {
    return _service.getWorkShifts(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<WorkShiftModel> createWorkShift({
    required String userId,
    required String shiftDate,
    required String shiftCode,
    String? note,
  }) {
    return _service.createWorkShift(
      userId: userId,
      shiftDate: shiftDate,
      shiftCode: shiftCode,
      note: note,
    );
  }

  @override
  Future<WorkShiftModel> updateWorkShift({
    required String id,
    required String userId,
    required String shiftDate,
    required String shiftCode,
    String? note,
  }) {
    return _service.updateWorkShift(
      id: id,
      userId: userId,
      shiftDate: shiftDate,
      shiftCode: shiftCode,
      note: note,
    );
  }

  @override
  Future<void> deleteWorkShift(String id) {
    return _service.deleteWorkShift(id);
  }

  @override
  Future<List<LeaveRequestModel>> getLeaveRequests() {
    return _service.getLeaveRequests();
  }

  @override
  Future<LeaveRequestModel> createLeaveRequest({
    required String userId,
    required String startDate,
    required int days,
    required String reason,
  }) {
    return _service.createLeaveRequest(
      userId: userId,
      startDate: startDate,
      days: days,
      reason: reason,
    );
  }

  @override
  Future<LeaveRequestModel> updateLeaveRequest({
    required String id,
    required String userId,
    required String startDate,
    required int days,
    required String reason,
  }) {
    return _service.updateLeaveRequest(
      id: id,
      userId: userId,
      startDate: startDate,
      days: days,
      reason: reason,
    );
  }

  @override
  Future<LeaveRequestModel> decideLeaveRequest({
    required String id,
    required String status,
  }) {
    return _service.decideLeaveRequest(id: id, status: status);
  }

  @override
  Future<void> deleteLeaveRequest(String id) {
    return _service.deleteLeaveRequest(id);
  }
}
