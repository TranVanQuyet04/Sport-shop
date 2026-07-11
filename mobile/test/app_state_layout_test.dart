import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportswear_shop_mobile/core/widgets/app_state.dart';

void main() {
  testWidgets(
    'AppEmptyState can render inside a ListView without layout errors',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                AppEmptyState(
                  title: 'Chưa có đơn đang giao',
                  message: 'Đơn mới được điều phối sẽ xuất hiện tại đây.',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Chưa có đơn đang giao'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
