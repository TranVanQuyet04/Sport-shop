import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/view/splash/splash_page.dart';

void main() {
  testWidgets('Splash screen renders app brand and start action', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));

    expect(find.text('SPORTSHOP'), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
  });
}
