import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_tracker/app.dart';

void main() {
  testWidgets('shows habit dashboard shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const HabitTrackerApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Good '), findsOneWidget);
  });
}
