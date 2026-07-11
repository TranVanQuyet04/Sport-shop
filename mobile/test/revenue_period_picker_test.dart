import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportswear_shop_mobile/view/admin/admin_revenue_report_page_parts/revenue_period_picker.dart';

void main() {
  testWidgets('week picker lists five reporting weeks for May', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => RevenuePeriodPicker.show(
                context: context,
                preset: 'week',
                currentRange: DateTimeRange(
                  start: DateTime(2026, 5, 1),
                  end: DateTime(2026, 5, 7),
                ),
              ),
              child: const Text('Mở bộ chọn'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mở bộ chọn'));
    await tester.pumpAndSettle();

    expect(find.text('Chọn tuần theo tháng'), findsOneWidget);
    expect(find.text('Tuần 1'), findsOneWidget);
    expect(find.text('Tuần 5'), findsOneWidget);
    expect(find.text('01/05 – 07/05/2026'), findsOneWidget);
    expect(find.text('29/05 – 31/05/2026'), findsOneWidget);
  });

  testWidgets('month picker renders future months disabled without crashing', (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => RevenuePeriodPicker.show(
                context: context,
                preset: 'month',
                currentRange: DateTimeRange(
                  start: DateTime(now.year, now.month),
                  end: now,
                ),
              ),
              child: const Text('Mở tháng'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mở tháng'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    if (now.month < 12) {
      final futureMonth = find.widgetWithText(
        OutlinedButton,
        'Tháng ${now.month + 1}',
      );
      expect(futureMonth, findsOneWidget);
      expect(tester.widget<OutlinedButton>(futureMonth).onPressed, isNull);
    }
  });
}
