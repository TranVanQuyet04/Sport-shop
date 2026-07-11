class DashboardReportModel {
  const DashboardReportModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.newUsers,
    required this.pendingOrders,
    required this.dailyRevenues,
  });

  final int totalRevenue;
  final int totalOrders;
  final int newUsers;
  final int pendingOrders;
  final List<DailyRevenueModel> dailyRevenues;

  factory DashboardReportModel.fromJson(Map<String, dynamic> json) {
    final source = json['result'] is Map
        ? Map<String, dynamic>.from(json['result'] as Map)
        : json;

    final dailyRaw = source['dailyRevenues'];
    final List<DailyRevenueModel> dailyList = [];
    if (dailyRaw is List) {
      for (final item in dailyRaw) {
        if (item is Map) {
          dailyList.add(
            DailyRevenueModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return DashboardReportModel(
      totalRevenue: _toInt(source['totalRevenue']),
      totalOrders: _toInt(source['totalOrders']),
      newUsers: _toInt(source['newUsers']),
      pendingOrders: _toInt(source['pendingOrders']),
      dailyRevenues: dailyList,
    );
  }
}

class DailyRevenueModel {
  const DailyRevenueModel({
    required this.dayOfWeek,
    required this.dateStr,
    required this.revenueCurrent,
    required this.revenuePrevious,
    required this.ordersCount,
  });

  final String dayOfWeek;
  final String dateStr;
  final int revenueCurrent;
  final int revenuePrevious;
  final int ordersCount;

  factory DailyRevenueModel.fromJson(Map<String, dynamic> json) {
    return DailyRevenueModel(
      dayOfWeek: json['dayOfWeek']?.toString() ?? '',
      dateStr: json['dateStr']?.toString() ?? '',
      revenueCurrent: _toInt(json['revenueCurrent']),
      revenuePrevious: _toInt(json['revenuePrevious']),
      ordersCount: _toInt(json['ordersCount']),
    );
  }
}

int _toInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse((value ?? '0').toString()) ?? 0;
}
