import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportswear_shop_mobile/core/widgets/app_button.dart';
import 'package:sportswear_shop_mobile/view/customer/onboarding_page.dart';

import 'pixel7_test_view.dart';

void main() {
  testWidgets('OnboardingPage renders content and primary action', (
    tester,
  ) async {
    usePixel7TestView(tester);

    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));

    expect(find.byType(AppButton), findsOneWidget);
    expect(find.byIcon(Icons.sports_gymnastics_rounded), findsOneWidget);
  });
}
