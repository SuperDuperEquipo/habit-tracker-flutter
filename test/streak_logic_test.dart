import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/streak_logic.dart';

final _today = DateTime(2026, 10, 14);

DateTime _daysAgo(int n) => DateTime(_today.year, _today.month, _today.day - n);

Habit _habit({
  List<DateTime> dates = const [],
  int streak = 0,
  int jokers = Habit.maxJokers,
}) {
  return Habit(
    id: 'h1',
    name: 'Lectura de apuntes',
    iconKey: Habit.defaultIconKey,
    colorValue: Habit.defaultColorValue,
    streak: streak,
    jokersLeft: jokers,
    completedDates: dates,
    createdAt: DateTime(2026, 9, 1),
  );
}

void main() {
  group('toggleComplete', () {
    test('completar un día nuevo deja la racha en 1', () {
      final result = toggleComplete(_habit(), _today);

      expect(result.streak, 1);
      expect(result.completedDates, [_today]);
    });

    test('continúa una racha existente', () {
      final habit = _habit(
        dates: [_daysAgo(3), _daysAgo(2), _daysAgo(1)],
        streak: 3,
      );

      expect(toggleComplete(habit, _today).streak, 4);
    });

    test('un día sin completar reinicia la racha a 1', () {
      final habit = _habit(dates: [_daysAgo(4), _daysAgo(3)], streak: 2);

      expect(toggleComplete(habit, _today).streak, 1);
    });

    test('desmarcar el mismo día corrige la racha', () {
      final run = List.generate(12, (i) => _daysAgo(i + 1));
      final completed = toggleComplete(_habit(dates: run, streak: 12), _today);
      expect(completed.streak, 13);

      final undone = toggleComplete(completed, _today);
      expect(undone.streak, 12);
      expect(undone.completedDates.contains(_today), isFalse);
    });

    test('desmarcar el único día deja la racha en 0', () {
      final completed = toggleComplete(_habit(), _today);

      expect(toggleComplete(completed, _today).streak, 0);
    });

    test('no modifica el hábito original', () {
      final habit = _habit();
      toggleComplete(habit, _today);

      expect(habit.completedDates, isEmpty);
      expect(habit.streak, 0);
    });
  });

  group('useJoker', () {
    test('gasta un comodín, cubre el día y continúa la racha', () {
      final habit = _habit(dates: [_daysAgo(2), _daysAgo(1)], streak: 2);

      final result = useJoker(habit, _today);

      expect(result.jokersLeft, Habit.maxJokers - 1);
      expect(result.completedDates.contains(_today), isTrue);
      expect(result.streak, 3);
    });

    test('sin comodines devuelve el hábito sin cambios', () {
      final habit = _habit(dates: [_daysAgo(1)], streak: 1, jokers: 0);

      expect(canUseJoker(habit, _today), isFalse);
      expect(useJoker(habit, _today), habit);
    });

    test('no se usa en un día ya completado', () {
      final habit = _habit(dates: [_daysAgo(1), _today], streak: 2);

      expect(canUseJoker(habit, _today), isFalse);
      expect(useJoker(habit, _today), habit);
    });

    test('no se usa si no hay una racha viva que proteger', () {
      final habit = _habit(dates: [_daysAgo(3)], streak: 1);

      expect(canUseJoker(habit, _today), isFalse);
      expect(useJoker(habit, _today), habit);
    });
  });

  group('currentStreak', () {
    test('cuenta desde ayer si hoy sigue pendiente', () {
      final habit = _habit(dates: [_daysAgo(2), _daysAgo(1)], streak: 2);

      expect(currentStreak(habit, _today), 2);
    });

    test('es 0 si ayer tampoco se completó', () {
      final habit = _habit(dates: [_daysAgo(3), _daysAgo(2)], streak: 2);

      expect(currentStreak(habit, _today), 0);
    });
  });
}
