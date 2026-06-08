import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/sportshop_app.dart';

void main() {
  testWidgets('Sportshop app starts on splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SportshopApp());

    expect(find.text('SPORTSHOP'), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
  });
}
