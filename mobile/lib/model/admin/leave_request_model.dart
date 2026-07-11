class LeaveRequestModel {
  const LeaveRequestModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.roleName,
    required this.startDate,
    required this.days,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.decidedAt,
    required this.decidedById,
  });

  final String id;
  final String userId;
  final String fullName;
  final String roleName;
  final DateTime? startDate;
  final int days;
  final String reason;
  final String status;
  final DateTime? createdAt;
  final DateTime? decidedAt;
  final String decidedById;

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      roleName: (json['roleName'] ?? '').toString(),
      startDate: DateTime.tryParse((json['startDate'] ?? '').toString()),
      days: _toInt(json['days']),
      reason: (json['reason'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      decidedAt: DateTime.tryParse((json['decidedAt'] ?? '').toString()),
      decidedById: (json['decidedById'] ?? '').toString(),
    );
  }
}

int _toInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse((value ?? '0').toString()) ?? 0;
}
