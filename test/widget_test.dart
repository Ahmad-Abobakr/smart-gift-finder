import 'package:flutter_test/flutter_test.dart';

import 'package:smart_gift_finder/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartGiftFinderApp());

    expect(find.text('Smart Gift Finder'), findsOneWidget);
  });
}
