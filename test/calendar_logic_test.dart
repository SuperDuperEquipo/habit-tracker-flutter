import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/features/habits/calendar_logic.dart';

void main() {
  test('daysInMonth: meses de 30 y 31 días, febrero normal y bisiesto', () {
    expect(daysInMonth(DateTime(2026, 4)), 30);
    expect(daysInMonth(DateTime(2026, 10)), 31);
    expect(daysInMonth(DateTime(2026, 2)), 28);
    expect(daysInMonth(DateTime(2028, 2)), 29);
  });

  test('monthCells: octubre de 2026 empieza en jueves (3 huecos)', () {
    final cells = monthCells(DateTime(2026, 10));

    expect(cells.length, 34);
    expect(cells.take(3).toList(), [null, null, null]);
    expect(cells[3], 1);
    expect(cells.last, 31);
  });

  test('completedDaysOfMonth: solo incluye los días del mes pedido', () {
    final dates = [
      DateTime(2026, 10, 3),
      DateTime(2026, 10, 4, 18, 30),
      DateTime(2026, 10, 20),
      DateTime(2026, 9, 30),
      DateTime(2026, 11, 1),
      DateTime(2025, 10, 15),
    ];

    expect(completedDaysOfMonth(dates, DateTime(2026, 10)), {3, 4, 20});
    expect(completedDaysOfMonth(const [], DateTime(2026, 10)), isEmpty);
  });
}
