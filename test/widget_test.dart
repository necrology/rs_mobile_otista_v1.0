import 'package:flutter_test/flutter_test.dart';

import 'package:rs_mobile_otista_v1_0/app.dart';

void main() {
  testWidgets('App shell loads with home services', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RsMobileApp());
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('Halo, Tamu'), findsOneWidget);
  });
}
