import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/features/habits/calendar_logic.dart';
import 'package:rachas/features/habits/widgets/month_calendar.dart';

void main() {
  testWidgets('marca exactamente los días que están en completedDates', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final october = DateTime(2026, 10);
    final expected = {3, 4, 20};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: MonthCalendar(
              month: october,
              completedDates: [
                DateTime(2026, 10, 3),
                DateTime(2026, 10, 4),
                DateTime(2026, 10, 20),
                DateTime(2026, 9, 30),
                DateTime(2026, 11, 1),
                DateTime(2025, 10, 15),
              ],
              today: DateTime(2026, 10, 14),
            ),
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.monthTitle(october)), findsOneWidget);
    for (var day = 1; day <= daysInMonth(october); day++) {
      expect(
        find.byKey(ValueKey('done-$day')),
        expected.contains(day) ? findsOneWidget : findsNothing,
        reason: 'día $day',
      );
    }
  });
}
