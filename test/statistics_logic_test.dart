import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/in_memory_habit_repository.dart';
import 'package:rachas/features/statistics/statistics_logic.dart';

final _today = DateTime(2026, 10, 14);

DateTime _daysAgo(int n) => DateTime(_today.year, _today.month, _today.day - n);

Habit _habit({
  String name = 'Hábito',
  List<DateTime> dates = const [],
  DateTime? createdAt,
}) {
  return Habit(
    id: name,
    name: name,
    iconKey: Habit.defaultIconKey,
    colorValue: Habit.defaultColorValue,
    streak: 0,
    jokersLeft: Habit.maxJokers,
    completedDates: dates,
    createdAt: createdAt ?? _daysAgo(30),
  );
}

void main() {
  group('computeWeeklyStats', () {
    test('sin hábitos devuelve 0 y no da NaN', () {
      final stats = computeWeeklyStats(const [], today: _today);

      expect(stats.completionRate, 0);
      expect(stats.completionRate.isNaN, isFalse);
      expect(stats.bestStreak, 0);
      expect(stats.bestStreakHabit, isNull);
      expect(stats.mostConsistentHabit, isNull);
    });

    test('con los hábitos de ejemplo da 22 de 28 días', () {
      final stats = computeWeeklyStats(sampleHabits(), today: DateTime.now());

      expect(stats.completed, 22);
      expect(stats.expected, 28);
      expect(stats.completionRate, closeTo(22 / 28, 1e-9));
    });

    test('con los hábitos de ejemplo elige mejor racha y más constante', () {
      final stats = computeWeeklyStats(sampleHabits(), today: DateTime.now());

      expect(stats.bestStreak, 18);
      expect(stats.bestStreakHabit, 'Repaso con Pomodoro');
      expect(stats.mostConsistentHabit, 'Lectura de apuntes');
      expect(stats.mostConsistentRate, 1);
    });

    test('un hábito creado hoy solo cuenta desde su creación', () {
      final pending = _habit(createdAt: _today);
      final done = _habit(createdAt: _today, dates: [_today]);

      expect(computeWeeklyStats([pending], today: _today).expected, 1);
      expect(computeWeeklyStats([pending], today: _today).completionRate, 0);
      expect(computeWeeklyStats([done], today: _today).completionRate, 1);
    });

    test('si nadie completó nada no hay hábito más constante', () {
      final stats = computeWeeklyStats([_habit()], today: _today);

      expect(stats.completionRate, 0);
      expect(stats.mostConsistentHabit, isNull);
    });
  });

  group('longestStreak', () {
    test('lista vacía da 0', () {
      expect(longestStreak(const []), 0);
    });

    test('cuenta la racha más larga aunque haya huecos', () {
      final dates = [_daysAgo(6), _daysAgo(5), _daysAgo(3), _daysAgo(2), _daysAgo(1)];

      expect(longestStreak(dates), 3);
    });

    test('ignora duplicados y desorden', () {
      final dates = [_daysAgo(1), _daysAgo(2), _daysAgo(2), _daysAgo(3)];

      expect(longestStreak(dates), 3);
    });
  });
}