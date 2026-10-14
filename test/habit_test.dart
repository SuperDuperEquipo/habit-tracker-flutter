import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/features/habits/habit.dart';

void main() {
  final habit = Habit(
    id: 'abc',
    name: 'Leer',
    iconKey: 'menu_book',
    colorValue: 0xFF2F4058,
    reminderTime: '20:00',
    streak: 5,
    jokersLeft: 2,
    completedDates: [DateTime(2026, 10, 12), DateTime(2026, 10, 11)],
    createdAt: DateTime(2026, 10, 1, 9, 30),
  );

  test('toJson y fromJson conservan los datos', () {
    final json = habit.toJson();

    expect(json.containsKey('id'), isFalse);
    expect(json['completedDates'], ['2026-10-12', '2026-10-11']);
    expect(Habit.fromJson(json, id: 'abc'), habit);
  });

  test('fromJson usa valores por defecto si faltan campos', () {
    final parsed = Habit.fromJson({'name': 'Solo nombre'}, id: 'x');

    expect(parsed.iconKey, Habit.defaultIconKey);
    expect(parsed.colorValue, Habit.defaultColorValue);
    expect(parsed.reminderTime, isNull);
    expect(parsed.streak, 0);
    expect(parsed.jokersLeft, Habit.maxJokers);
    expect(parsed.completedDates, isEmpty);
  });

  test('fromJson acepta fechas como mapa y limita los comodines', () {
    final parsed = Habit.fromJson({
      'name': 'A',
      'jokersLeft': 9,
      'completedDates': {'0': '2026-10-12', '1': '2026-10-11'},
    }, id: 'x');

    expect(parsed.jokersLeft, Habit.maxJokers);
    expect(parsed.completedDates, [
      DateTime(2026, 10, 12),
      DateTime(2026, 10, 11),
    ]);
  });

  test('completedDates es inmutable y solo guarda la fecha', () {
    expect(
      () => habit.completedDates.add(DateTime(2026)),
      throwsUnsupportedError,
    );

    final source = [DateTime(2026, 10, 12, 18, 45)];
    final copy = habit.copyWith(completedDates: source);
    source.clear();

    expect(copy.completedDates, [DateTime(2026, 10, 12)]);
  });

  test('copyWith cambia solo lo indicado y puede quitar el recordatorio', () {
    expect(habit.copyWith().reminderTime, '20:00');
    expect(habit.copyWith(reminderTime: '09:00').reminderTime, '09:00');
    expect(habit.copyWith(clearReminderTime: true).reminderTime, isNull);
    expect(habit.copyWith(name: 'Otro').streak, habit.streak);
  });

  test('Habit.draft crea un hábito nuevo sin id', () {
    final draft = Habit.draft(name: 'Nuevo');

    expect(draft.isNew, isTrue);
    expect(draft.streak, 0);
    expect(draft.jokersLeft, Habit.maxJokers);
    expect(draft.completedDates, isEmpty);
  });

  test('no admite más de 3 comodines', () {
    expect(() => habit.copyWith(jokersLeft: 4), throwsA(isA<AssertionError>()));
  });
}
