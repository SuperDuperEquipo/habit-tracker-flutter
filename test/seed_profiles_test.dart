import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/streak_logic.dart';
import 'package:rachas/features/statistics/statistics_logic.dart';

import '../tool/seed_profiles.dart';

// Comprueba que cada perfil del seed muestra lo que dice el README.
void main() {
  // Día 3: la racha vieja de Ana cruza al mes anterior.
  final today = DateTime(2026, 11, 3);
  final profiles = {for (final p in seedProfiles(today)) p.email: p};

  List<Habit> habitsOf(String email) => profiles[email]!.habits;
  Habit habit(String email, String id) =>
      habitsOf(email).firstWhere((h) => h.id == id);
  int doneToday(String email) =>
      habitsOf(email).where((h) => isCompletedOn(h, today)).length;

  test('las rachas guardadas son las que calcula la app', () {
    for (final h in profiles.values.expand((p) => p.habits)) {
      expect(h.streak, currentStreak(h, today), reason: h.id);
      expect(h.completedDates.every((d) => !d.isAfter(today)), isTrue);
      expect(
        h.completedDates.every((d) => !d.isBefore(h.createdAt)),
        isTrue,
        reason: h.id,
      );
    }
  });

  test('Ana: día a medias con todos los casos de comodín', () {
    const ana = 'ana@rachas.test';
    expect(doneToday(ana), 2);
    expect(canUseJoker(habit(ana, 'ana-agua'), today), isTrue);
    expect(habit(ana, 'ana-meditar').jokersLeft, 0);
    expect(canUseJoker(habit(ana, 'ana-meditar'), today), isFalse);
    expect(currentStreak(habit(ana, 'ana-caminar'), today), 0);
    expect(habit(ana, 'ana-caminar').reminderTime, isNull);
    final stats = computeWeeklyStats(habitsOf(ana), today: today);
    expect(stats.bestStreak, 21);
    expect(stats.bestStreakHabit, 'Repaso con Pomodoro');
    expect(stats.mostConsistentHabit, 'Lectura de apuntes');
  });

  test('Luis: todo completado hoy y toda la semana', () {
    const luis = 'luis@rachas.test';
    expect(doneToday(luis), habitsOf(luis).length);
    expect(computeWeeklyStats(habitsOf(luis), today: today).completionRate, 1);
  });

  test('Sofía: nada completado hoy y un hábito recién creado', () {
    const sofia = 'sofia@rachas.test';
    expect(doneToday(sofia), 0);
    expect(canUseJoker(habit(sofia, 'sofia-ingles'), today), isTrue);
    expect(habit(sofia, 'sofia-dormir').completedDates, isEmpty);
  });

  test('nuevo: sin nombre y sin hábitos', () {
    final nuevo = profiles['nuevo@rachas.test']!;
    expect(nuevo.name, isNull);
    expect(nuevo.habits, isEmpty);
  });
}
