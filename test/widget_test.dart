import 'package:flutter_test/flutter_test.dart';

import 'package:smart_gift_finder/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartGiftFinderApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Home'), findsOneWidget);
  });
}
