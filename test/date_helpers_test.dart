import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/core/utils/date_helpers.dart';

void main() {
  test('dateKey formatea como yyyy-MM-dd', () {
    expect(dateKey(DateTime(2026, 3, 5, 23, 59)), '2026-03-05');
  });

  test('parseDateKey devuelve solo la fecha o null', () {
    expect(parseDateKey('2026-10-12'), DateTime(2026, 10, 12));
    expect(parseDateKey('no es fecha'), isNull);
  });

  test('dateOnly descarta la hora', () {
    expect(dateOnly(DateTime(2026, 10, 12, 18, 45)), DateTime(2026, 10, 12));
  });

  test('formatReminderTime rellena con ceros', () {
    expect(formatReminderTime(8, 5), '08:05');
  });

  test('parseReminderTime valida el formato HH:mm', () {
    expect(parseReminderTime('08:30'), (hour: 8, minute: 30));
    expect(parseReminderTime('23:59'), (hour: 23, minute: 59));
    expect(parseReminderTime(null), isNull);
    expect(parseReminderTime('24:00'), isNull);
    expect(parseReminderTime('8:30'), isNull);
    expect(parseReminderTime('abc'), isNull);
  });
}
