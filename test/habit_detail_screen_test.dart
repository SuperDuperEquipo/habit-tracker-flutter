import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rachas/app/app_router.dart';
import 'package:rachas/app/app_routes.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_detail_screen.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/habits/habits_provider.dart';
import 'package:rachas/features/habits/habits_screen.dart';
import 'package:rachas/features/habits/in_memory_habit_repository.dart';
import 'package:rachas/features/habits/widgets/habit_card.dart';

Habit _habit({
  String id = 'h1',
  String name = 'Leer 20 minutos',
  int jokersLeft = 2,
  String? reminderTime,
  List<DateTime> completedDates = const [],
}) {
  return Habit(
    id: id,
    name: name,
    iconKey: Habit.defaultIconKey,
    colorValue: Habit.defaultColorValue,
    reminderTime: reminderTime,
    streak: completedDates.length,
    jokersLeft: jokersLeft,
    completedDates: completedDates,
    createdAt: DateTime(2026, 1, 1),
  );
}

Habit _habitWithStreakOfThree() {
  final now = DateTime.now();
  return _habit(
    reminderTime: '08:30',
    completedDates: [
      for (var i = 0; i < 3; i++) DateTime(now.year, now.month, now.day - i),
    ],
  );
}

Widget _app({required Widget home, required HabitRepository repository}) {
  // Igual que app.dart: HabitsScreen usa el HabitsProvider compartido.
  return MultiProvider(
    providers: [
      Provider<HabitRepository>.value(value: repository),
      ChangeNotifierProvider<HabitsProvider>(
        create: (_) => HabitsProvider(repository: repository),
      ),
    ],
    child: MaterialApp(home: home, onGenerateRoute: AppRouter.onGenerateRoute),
  );
}

Widget _detailApp(Habit habit) {
  return _app(
    home: HabitDetailScreen(habit: habit),
    repository: InMemoryHabitRepository(seed: [habit], latency: Duration.zero),
  );
}

void _useNarrowPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('HabitDetailScreen', () {
    testWidgets('muestra nombre, racha, comodines y recordatorio', (
      tester,
    ) async {
      _useNarrowPhone(tester);

      await tester.pumpWidget(_detailApp(_habitWithStreakOfThree()));

      expect(find.text('Leer 20 minutos'), findsOneWidget);
      expect(find.text(AppStrings.streakDays(3)), findsOneWidget);
      expect(
        find.text(AppStrings.jokersLeftOf(2, Habit.maxJokers)),
        findsOneWidget,
      );
      expect(find.textContaining('8:30'), findsOneWidget);
    });

    testWidgets('no se desborda en una pantalla de 360 px', (tester) async {
      _useNarrowPhone(tester);

      final habit = _habitWithStreakOfThree().copyWith(
        name: 'Lectura académica y apuntes de anatomía y fisiología',
        jokersLeft: Habit.maxJokers,
      );
      await tester.pumpWidget(_detailApp(habit));

      expect(tester.takeException(), isNull);
    });

    testWidgets('el botón Editar abre la ruta de editar con el hábito', (
      tester,
    ) async {
      _useNarrowPhone(tester);
      final habit = _habit();

      RouteSettings? opened;
      await tester.pumpWidget(
        Provider<HabitRepository>.value(
          value: InMemoryHabitRepository(seed: [habit], latency: Duration.zero),
          child: MaterialApp(
            home: HabitDetailScreen(habit: habit),
            onGenerateRoute: (settings) {
              opened = settings;
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) =>
                    const Scaffold(body: Text('pantalla de editar')),
              );
            },
          ),
        ),
      );
      final editButton = find.byKey(const ValueKey('edit-button'));
      await tester.ensureVisible(editButton);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(opened?.name, AppRoutes.editHabit);
      expect(opened?.arguments, habit);
      expect(find.text('pantalla de editar'), findsOneWidget);
    });
  });

  group('Lista de hábitos', () {
    testWidgets('tocar una tarjeta abre el detalle del hábito', (tester) async {
      await tester.pumpWidget(
        _app(
          home: const HabitsScreen(),
          repository: InMemoryHabitRepository(latency: Duration.zero),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lectura de apuntes'));
      await tester.pumpAndSettle();

      expect(find.byType(HabitDetailScreen), findsOneWidget);
    });

    testWidgets('solo construye las tarjetas que se ven (ListView.builder)', (
      tester,
    ) async {
      final habits = [
        for (var i = 0; i < 50; i++) _habit(id: 'h$i', name: 'Hábito $i'),
      ];

      await tester.pumpWidget(
        _app(
          home: const HabitsScreen(),
          repository: InMemoryHabitRepository(
            seed: habits,
            latency: Duration.zero,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final built = find.byType(HabitCard).evaluate().length;
      expect(built, greaterThan(0));
      expect(built, lessThan(50));
    });
  });
}
