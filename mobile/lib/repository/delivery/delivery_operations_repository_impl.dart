import '../../model/delivery/delivery_assignment_model.dart';
import '../../model/delivery/delivery_report_model.dart';
import '../../service/delivery/delivery_operations_service.dart';
import 'delivery_operations_repository.dart';

class DeliveryOperationsRepositoryImpl implements DeliveryOperationsRepository {
  const DeliveryOperationsRepositoryImpl(this._service);

  final DeliveryOperationsService _service;

  @override
  Future<List<DeliveryAssignmentModel>> getAssignments({String? staffId}) {
    return _service.getAssignments(staffId: staffId);
  }

  @override
  Future<DeliveryAssignmentModel> assignOrder({
    required String orderId,
    required String staffId,
    String? note,
  }) {
    return _service.assignOrder(orderId: orderId, staffId: staffId, note: note);
  }

  @override
  Future<DeliveryAssignmentModel> updateAssignment({
    required String id,
    required String orderId,
    required String staffId,
    String? note,
  }) {
    return _service.updateAssignment(
      id: id,
      orderId: orderId,
      staffId: staffId,
      note: note,
    );
  }

  @override
  Future<void> deleteAssignment(String id) {
    return _service.deleteAssignment(id);
  }

  @override
  Future<List<DeliveryReportModel>> getAllReports() {
    return _service.getAllReports();
  }

  @override
  Future<List<DeliveryReportModel>> getReportsByOrder(String orderId) {
    return _service.getReportsByOrder(orderId);
  }

  @override
  Future<DeliveryReportModel> createReport({
    required String orderId,
    required String status,
    required String reason,
    String? note,
    String? evidenceImageUrl,
  }) {
    return _service.createReport(
      orderId: orderId,
      status: status,
      reason: reason,
      note: note,
      evidenceImageUrl: evidenceImageUrl,
    );
  }

  @override
  Future<DeliveryReportModel> updateReport({
    required String id,
    required String status,
    required String reason,
    String? note,
    String? evidenceImageUrl,
  }) {
    return _service.updateReport(
      id: id,
      status: status,
      reason: reason,
      note: note,
      evidenceImageUrl: evidenceImageUrl,
    );
  }

  @override
  Future<void> deleteReport(String id) {
    return _service.deleteReport(id);
  }
}
