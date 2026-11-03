import 'package:rachas/core/utils/date_helpers.dart';
import 'package:rachas/features/habits/habit.dart';

/// Tamaño de la ventana de "la semana": hoy y los 6 días anteriores.
const int statsWindowDays = 7;

class WeeklyStats {
  const WeeklyStats({
    required this.completed,
    required this.expected,
    required this.bestStreak,
    this.bestStreakHabit,
    this.mostConsistentHabit,
    this.mostConsistentRate = 0,
  });

  static const WeeklyStats empty = WeeklyStats(
    completed: 0,
    expected: 0,
    bestStreak: 0,
  );

  /// Días completados en la ventana, sumando todos los hábitos.
  final int completed;

  /// Días que se podían completar (cada hábito cuenta desde que se creó).
  final int expected;

  /// Racha más larga de todos los hábitos, en días.
  final int bestStreak;
  final String? bestStreakHabit;

  /// Hábito con mayor porcentaje de cumplimiento en la ventana.
  final String? mostConsistentHabit;
  final double mostConsistentRate;

  /// Entre 0 y 1. Nunca es NaN: sin días esperados devuelve 0.
  double get completionRate => expected == 0 ? 0 : completed / expected;
}

/// Calcula las estadísticas de la semana que termina en [today].
WeeklyStats computeWeeklyStats(
  List<Habit> habits, {
  required DateTime today,
}) {
  if (habits.isEmpty) return WeeklyStats.empty;
  final day = dateOnly(today);

  final expected = habits.fold<int>(
    0,
    (sum, habit) => sum + _eligibleDays(habit, day).length,
  );
  final completed = habits.fold<int>(
    0,
    (sum, habit) => sum + _completedIn(habit, _eligibleDays(habit, day)),
  );

  Habit? streakHabit;
  var bestStreak = 0;
  Habit? consistentHabit;
  var consistentRate = 0.0;

  for (final habit in habits) {
    final streak = longestStreak(habit.completedDates);
    if (streak > bestStreak) {
      bestStreak = streak;
      streakHabit = habit;
    }
    final rate = habitWeeklyRate(habit, day);
    if (rate > consistentRate) {
      consistentRate = rate;
      consistentHabit = habit;
    }
  }

  return WeeklyStats(
    completed: completed,
    expected: expected,
    bestStreak: bestStreak,
    bestStreakHabit: streakHabit?.name,
    mostConsistentHabit: consistentHabit?.name,
    mostConsistentRate: consistentRate,
  );
}

/// Porcentaje (0 a 1) de cumplimiento de un hábito en la ventana.
double habitWeeklyRate(Habit habit, DateTime today) {
  final days = _eligibleDays(habit, dateOnly(today));
  if (days.isEmpty) return 0;
  return _completedIn(habit, days) / days.length;
}

/// Mayor número de días seguidos en [dates]. Ignora duplicados y el orden.
int longestStreak(Iterable<DateTime> dates) {
  final sorted = dates.map(dateOnly).toSet().toList()..sort();
  var best = 0;
  var run = 0;
  DateTime? previous;
  for (final day in sorted) {
    final continues =
        previous != null &&
        day == DateTime(previous.year, previous.month, previous.day + 1);
    run = continues ? run + 1 : 1;
    if (run > best) best = run;
    previous = day;
  }
  return best;
}

List<DateTime> _eligibleDays(Habit habit, DateTime today) {
  final created = dateOnly(habit.createdAt);
  final window = List<DateTime>.generate(
    statsWindowDays,
    (i) => DateTime(
      today.year,
      today.month,
      today.day - (statsWindowDays - 1 - i),
    ),
  );
  return window.where((day) => !day.isBefore(created)).toList();
}

int _completedIn(Habit habit, List<DateTime> days) {
  final done = habit.completedDates.toSet();
  return days.where(done.contains).length;
}