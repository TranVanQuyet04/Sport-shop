import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportswear_shop_mobile/view/admin/admin_revenue_report_page_parts/revenue_filter_widgets.dart';

void main() {
  testWidgets('revenue period options stay in one horizontal row', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: DateFilterRow(
                selectedRange: DateTimeRange(
                  start: DateTime(2026, 7, 1),
                  end: DateTime(2026, 7, 7),
                ),
                selectedPreset: 'week',
                onQuickSelect: (_) {},
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final horizontalScroll = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    expect(horizontalScroll.scrollDirection, Axis.horizontal);
    for (final label in ['Ngày', 'Tuần', 'Tháng', 'Quý', 'Năm', 'Tùy chỉnh']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(
      tester.getTopLeft(find.text('Tuần')).dy,
      lessThan(tester.getTopLeft(find.textContaining('Tuần 1')).dy),
    );
    expect(tester.takeException(), isNull);
  });
}
