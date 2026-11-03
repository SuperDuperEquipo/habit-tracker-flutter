import 'package:rachas/core/utils/date_helpers.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/streak_logic.dart' show currentStreak;

/// Contraseña de todas las cuentas de prueba.
const String seedPassword = 'rachas123';

class SeedProfile {
  const SeedProfile({required this.email, this.name, required this.habits});

  final String email;

  /// Nombre que se muestra en el saludo y en Perfil. Null = cuenta sin nombre.
  final String? name;
  final List<Habit> habits;
}

/// Perfiles de prueba. Las fechas salen de [today], así que el seed hay que
/// correrlo el mismo día en que se va a probar. El README explica qué
/// pantalla cubre cada perfil; test/seed_profiles_test.dart lo comprueba.
List<SeedProfile> seedProfiles(DateTime today) {
  final day = dateOnly(today);
  DateTime ago(int days) => DateTime(day.year, day.month, day.day - days);

  // [length] días seguidos que terminan hace [endingDaysAgo] días.
  List<DateTime> run(int length, {int endingDaysAgo = 0}) => [
    for (var i = 0; i < length; i++) ago(endingDaysAgo + i),
  ];

  Habit habit(
    String id,
    String name, {
    required String icon,
    required int color,
    String? reminder,
    required int jokers,
    required List<DateTime> done,
    required int createdDaysAgo,
  }) {
    final habit = Habit(
      id: id,
      name: name,
      iconKey: icon,
      colorValue: color,
      reminderTime: reminder,
      streak: 0,
      jokersLeft: jokers,
      completedDates: done..sort(),
      createdAt: ago(createdDaysAgo),
    );
    // La racha guardada es la misma que calcula la app.
    return habit.copyWith(streak: currentStreak(habit, day));
  }

  return [
    // Día a medias: todos los casos de racha y comodín.
    SeedProfile(
      email: 'ana@rachas.test',
      name: 'Ana',
      habits: [
        habit(
          'ana-lectura',
          'Lectura de apuntes',
          icon: 'menu_book',
          color: 0xFF2F4058,
          reminder: '08:30',
          jokers: 3,
          done: run(12),
          createdDaysAgo: 40,
        ),
        habit(
          'ana-pomodoro',
          'Repaso con Pomodoro',
          icon: 'headphones',
          color: 0xFFF7C9D4,
          reminder: '16:00',
          jokers: 2,
          // Racha vieja de 21 días: es la "Mejor racha" de Estadísticas.
          done: [...run(4), ...run(21, endingDaysAgo: 12)],
          createdDaysAgo: 35,
        ),
        habit(
          'ana-agua',
          'Tomar 2L de agua',
          icon: 'water_drop',
          color: 0xFFC8D9E6,
          reminder: '10:00',
          jokers: 2,
          done: run(6, endingDaysAgo: 1),
          createdDaysAgo: 30,
        ),
        habit(
          'ana-caminar',
          'Caminar 20 minutos',
          icon: 'directions_bike',
          color: 0xFFC45B78,
          jokers: 1,
          done: run(5, endingDaysAgo: 3),
          createdDaysAgo: 20,
        ),
        habit(
          'ana-meditar',
          'Meditar 5 minutos',
          icon: 'self_improvement',
          color: 0xFF5F7F99,
          reminder: '21:00',
          jokers: 0,
          done: run(8, endingDaysAgo: 1),
          createdDaysAgo: 15,
        ),
      ],
    ),
    // Todo completado hoy y toda la semana.
    SeedProfile(
      email: 'luis@rachas.test',
      name: 'Luis',
      habits: [
        habit(
          'luis-ejercicio',
          'Rutina de ejercicio',
          icon: 'fitness_center',
          color: 0xFF1B2636,
          reminder: '06:30',
          jokers: 3,
          done: run(30),
          createdDaysAgo: 45,
        ),
        habit(
          'luis-desayuno',
          'Desayunar antes de clase',
          icon: 'nutrition',
          color: 0xFFFFE1E6,
          reminder: '07:00',
          jokers: 2,
          done: run(15),
          createdDaysAgo: 30,
        ),
        habit(
          'luis-dibujo',
          'Dibujar 15 minutos',
          icon: 'draw',
          color: 0xFFF5EFEB,
          jokers: 3,
          done: run(9),
          createdDaysAgo: 10,
        ),
      ],
    ),
    // Nada completado hoy, con un hábito recién creado.
    SeedProfile(
      email: 'sofia@rachas.test',
      name: 'Sofía',
      habits: [
        habit(
          'sofia-ingles',
          'Practicar inglés',
          icon: 'lightbulb',
          color: 0xFFC8D9E6,
          reminder: '18:00',
          jokers: 1,
          done: run(10, endingDaysAgo: 1),
          createdDaysAgo: 20,
        ),
        habit(
          'sofia-dormir',
          'Dormir antes de las 11',
          icon: 'bedtime',
          color: 0xFF2F4058,
          reminder: '22:30',
          jokers: 3,
          done: [],
          createdDaysAgo: 0,
        ),
      ],
    ),
    // Cuenta recién creada: sin nombre y sin hábitos.
    const SeedProfile(email: 'nuevo@rachas.test', habits: []),
  ];
}
