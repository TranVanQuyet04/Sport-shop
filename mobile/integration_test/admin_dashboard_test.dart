// integration_test/admin_dashboard_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:sportswear_shop_mobile/view/admin/admin_dashboard_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Admin Dashboard loads and shows KPI cards', (WidgetTester tester) async {
    // Build the dashboard page directly.
    await tester.pumpWidget(const MaterialApp(
      home: AdminDashboardPage(),
    ));
    // Allow any async loading to settle.
    await tester.pumpAndSettle();

    // Verify that the four KPI titles are present.
    expect(find.text('Tổng doanh thu'), findsOneWidget);
    expect(find.text('Tổng đơn hàng'), findsOneWidget);
    expect(find.text('Người dùng mới'), findsOneWidget);
    expect(find.text('Đơn chờ xử lý'), findsOneWidget);

    // Verify that the quick actions are present.
    expect(find.text('Thêm SP'), findsOneWidget);
    expect(find.text('Đơn hàng'), findsOneWidget);
    expect(find.text('Nhân viên'), findsOneWidget);
    expect(find.text('Báo cáo'), findsOneWidget);
  });
}
