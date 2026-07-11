class DeliveryAssignmentModel {
  const DeliveryAssignmentModel({
    required this.id,
    required this.orderId,
    required this.staffId,
    required this.staffName,
    required this.staffRole,
    required this.assignedById,
    required this.assignedAt,
    required this.note,
  });

  final String id;
  final String orderId;
  final String staffId;
  final String staffName;
  final String staffRole;
  final String assignedById;
  final DateTime? assignedAt;
  final String note;

  factory DeliveryAssignmentModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAssignmentModel(
      id: (json['id'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      staffId: (json['staffId'] ?? '').toString(),
      staffName: (json['staffName'] ?? '').toString(),
      staffRole: (json['staffRole'] ?? '').toString(),
      assignedById: (json['assignedById'] ?? '').toString(),
      assignedAt: DateTime.tryParse((json['assignedAt'] ?? '').toString()),
      note: (json['note'] ?? '').toString(),
    );
  }
}
