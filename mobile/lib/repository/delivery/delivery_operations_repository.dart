import '../../model/delivery/delivery_assignment_model.dart';
import '../../model/delivery/delivery_report_model.dart';

abstract interface class DeliveryOperationsRepository {
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
