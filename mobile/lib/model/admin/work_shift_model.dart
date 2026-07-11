class WorkShiftModel {
  const WorkShiftModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.roleName,
    required this.shiftDate,
    required this.shiftCode,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String fullName;
  final String roleName;
  final DateTime? shiftDate;
  final String shiftCode;
  final String note;
  final DateTime? createdAt;

  factory WorkShiftModel.fromJson(Map<String, dynamic> json) {
    return WorkShiftModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      roleName: (json['roleName'] ?? '').toString(),
      shiftDate: DateTime.tryParse((json['shiftDate'] ?? '').toString()),
      shiftCode: (json['shiftCode'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}
