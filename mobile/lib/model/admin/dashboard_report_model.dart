class DashboardReportModel {
  const DashboardReportModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.newUsers,
    required this.pendingOrders,
  });

  final int totalRevenue;
  final int totalOrders;
  final int newUsers;
  final int pendingOrders;

  factory DashboardReportModel.fromJson(Map<String, dynamic> json) {
    final source = json['result'] is Map
        ? Map<String, dynamic>.from(json['result'] as Map)
        : json;
    return DashboardReportModel(
      totalRevenue: _toInt(source['totalRevenue']),
      totalOrders: _toInt(source['totalOrders']),
      newUsers: _toInt(source['newUsers']),
      pendingOrders: _toInt(source['pendingOrders']),
    );
  }
}

int _toInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse((value ?? '0').toString()) ?? 0;
}
