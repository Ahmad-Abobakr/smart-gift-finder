import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_gift_finder/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(SmartGiftFinderApp(prefs: prefs));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Login'), findsOneWidget);
  });
}