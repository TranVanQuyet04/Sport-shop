import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportswear_shop_mobile/core/widgets/app_button.dart';
import 'package:sportswear_shop_mobile/core/widgets/app_text_field.dart';
import 'package:sportswear_shop_mobile/view/customer/customer_support_page.dart';

import 'pixel7_test_view.dart';

void main() {
  testWidgets('CustomerSupportPage renders support controls', (tester) async {
    usePixel7TestView(tester);

    await tester.pumpWidget(const MaterialApp(home: CustomerSupportPage()));

    expect(find.byType(AppTextField), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);
  });
}
