import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportswear_shop_mobile/model/admin/dashboard_report_model.dart';
import 'package:sportswear_shop_mobile/presenter/admin/admin_revenue_report_presenter.dart';
import 'package:sportswear_shop_mobile/repository/admin/admin_report_repository.dart';

void main() {
  group('AdminRevenueReportPresenter date range validation', () {
    late AdminRevenueReportPresenter presenter;

    setUp(() {
      presenter = AdminRevenueReportPresenter(
        adminReportRepository: const _FakeAdminReportRepository(),
      );
    });

    tearDown(() => presenter.dispose());

    test('accepts a custom range of exactly 30 days', () {
      final range = DateTimeRange(
        start: DateTime(2026, 5, 1),
        end: DateTime(2026, 5, 30),
      );

      expect(presenter.validateDateRange(range, preset: 'custom'), isNull);
    });

    test('rejects a custom range longer than 30 days', () {
      final range = DateTimeRange(
        start: DateTime(2026, 5, 1),
        end: DateTime(2026, 5, 31),
      );

      expect(
        presenter.validateDateRange(range, preset: 'custom'),
        contains('30 ngày'),
      );
    });

    test('allows month and quarter presets to exceed 30 days', () {
      final quarter = DateTimeRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 3, 31),
      );

      expect(presenter.validateDateRange(quarter, preset: 'quarter'), isNull);
    });

    test('rejects ranges ending in the future', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final range = DateTimeRange(start: DateTime.now(), end: tomorrow);

      expect(
        presenter.validateDateRange(range, preset: 'day'),
        contains('tương lai'),
      );
    });
  });
}

class _FakeAdminReportRepository implements AdminReportRepository {
  const _FakeAdminReportRepository();

  @override
  Future<DashboardReportModel> getDashboardReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return const DashboardReportModel(
      totalRevenue: 0,
      totalOrders: 0,
      newUsers: 0,
      pendingOrders: 0,
      dailyRevenues: [],
    );
  }
}
