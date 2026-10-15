import 'package:rachas/core/utils/date_helpers.dart';
import 'package:rachas/features/habits/habit.dart';

/// Reglas de racha y comodines. Son la única fuente de verdad: ni las
/// tarjetas ni el formulario deben repetir esta lógica.
///
/// La racha es el número de días seguidos completados que terminan en [day].
/// Se recalcula desde `completedDates`, así que desmarcar la corrige sola
/// y un día sin completar la reinicia.

Habit toggleComplete(Habit habit, DateTime day) {
  final target = dateOnly(day);
  final dates = habit.completedDates.toSet();

  if (!dates.remove(target)) {
    dates.add(target);
  }

  return habit.copyWith(
    completedDates: _sorted(dates),
    streak: _streakAround(dates, target),
  );
}

/// Un comodín solo se puede usar si hay diponibles,
/// el dia no esta completado y el dia anterior si se completo
bool canUseJoker(Habit habit, DateTime day) {
  final target = dateOnly(day);
  return habit.jokersLeft > 0 &&
      !habit.completedDates.contains(target) &&
      habit.completedDates.contains(_previousDay(target));
}

/// Usar un comodin cuenta como cimpletar el día
Habit useJoker(Habit habit, DateTime day) {
  if (!canUseJoker(habit, day)) return habit;

  final target = dateOnly(day);
  final dates = habit.completedDates.toSet()..add(target);

  return habit.copyWith(
    jokersLeft: habit.jokersLeft - 1,
    completedDates: _sorted(dates),
    streak: _streakAround(dates, target),
  );
}

bool isCompletedOn(Habit habit, DateTime day) =>
    habit.completedDates.contains(dateOnly(day));

// Desmarcar el habito recalcula la racha
int _streakAround(Set<DateTime> dates, DateTime target) {
  final start = dates.contains(target) ? target : _previousDay(target);
  var count = 0;
  var cursor = start;
  while (dates.contains(cursor)) {
    count++;
    cursor = _previousDay(cursor);
  }
  return count;
}

// Se construye con DateTime(y, m, d - 1) y no con subtract(Duration(days: 1))
// para no fallar en cambios de horario.
DateTime _previousDay(DateTime day) =>
    DateTime(day.year, day.month, day.day - 1);

List<DateTime> _sorted(Set<DateTime> dates) => dates.toList()..sort();

int currentStreak(Habit habit, DateTime day) =>
    _streakAround(habit.completedDates.toSet(), dateOnly(day));
