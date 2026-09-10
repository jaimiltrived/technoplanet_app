// This is a basic Flutter widget test for the RK University app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:technoplanet_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const RKUniversityApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Verify the app renders without throwing.
    expect(tester.takeException(), isNull);

    // Settle timers (splash screen navigation)
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
  });
}
