class DeliveryReportModel {
  const DeliveryReportModel({
    required this.id,
    required this.orderId,
    required this.reportedById,
    required this.reportedByName,
    required this.status,
    required this.reason,
    required this.note,
    required this.evidenceImageUrl,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final String reportedById;
  final String reportedByName;
  final String status;
  final String reason;
  final String note;
  final String evidenceImageUrl;
  final DateTime? createdAt;

  factory DeliveryReportModel.fromJson(Map<String, dynamic> json) {
    return DeliveryReportModel(
      id: (json['id'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      reportedById: (json['reportedById'] ?? '').toString(),
      reportedByName: (json['reportedByName'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      evidenceImageUrl: (json['evidenceImageUrl'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}
