import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/features/habit_form/create_habit_screen.dart';
import 'package:rachas/features/habit_form/edit_habit_screen.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_detail_screen.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/habits/in_memory_habit_repository.dart';

const _openLabel = 'abrir';

Habit _habit() {
  final today = DateTime.now();
  return Habit(
    id: 'h1',
    name: 'Leer 20 minutos',
    iconKey: Habit.defaultIconKey,
    colorValue: Habit.defaultColorValue,
    reminderTime: '08:30',
    streak: 2,
    jokersLeft: 2,
    completedDates: [
      DateTime(today.year, today.month, today.day),
      DateTime(today.year, today.month, today.day - 1),
    ],
    createdAt: DateTime(2026, 1, 1),
  );
}

/// Abre [screen] encima de una pantalla vacía, para poder comprobar que
/// regresa (pop) después de guardar o eliminar.
Future<void> _open(
  WidgetTester tester,
  Widget screen,
  HabitRepository repository,
) async {
  await tester.pumpWidget(
    Provider<HabitRepository>.value(
      value: repository,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => screen),
                ),
                child: const Text(_openLabel),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text(_openLabel));
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  group('Crear hábito', () {
    testWidgets('sin nombre no guarda y muestra el error del campo', (
      tester,
    ) async {
      final repository = InMemoryHabitRepository(
        seed: const [],
        latency: Duration.zero,
      );
      await _open(
        tester,
        CreateHabitScreen(habitRepository: repository),
        repository,
      );

      await _tapText(tester, AppStrings.saveHabit);

      expect(find.text(AppStrings.habitNameRequired), findsOneWidget);
      expect((await tester.runAsync(() => repository.getAll())), isEmpty);
    });

    testWidgets('con nombre guarda lo escrito y regresa', (tester) async {
      final repository = _Recording();
      await _open(
        tester,
        CreateHabitScreen(habitRepository: repository),
        repository,
      );

      await tester.enterText(find.byType(TextFormField), 'Tomar agua');
      await tester.pump();
      await _tapText(tester, AppStrings.saveHabit);

      final habits = (await tester.runAsync(() => repository.getAll()))!;
      expect(habits.single.name, 'Tomar agua');
      expect(habits.single.reminderTime, '08:30');
      expect(find.text(_openLabel), findsOneWidget);
    });
  });

  group('Editar hábito', () {
    testWidgets('guarda los cambios y conserva la racha', (tester) async {
      final habit = _habit();
      final repository = InMemoryHabitRepository(
        seed: [habit],
        latency: Duration.zero,
      );
      await _open(tester, EditHabitScreen(habit: habit), repository);

      expect(find.text(AppStrings.saveChanges), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Leer 30 minutos');
      await tester.pump();
      await _tapText(tester, AppStrings.saveChanges);

      final saved = (await tester.runAsync(() => repository.getById(habit.id)));
      expect(saved!.name, 'Leer 30 minutos');
      expect(saved.streak, habit.streak);
      expect(saved.jokersLeft, habit.jokersLeft);
      expect(saved.completedDates, habit.completedDates);
      expect(find.text(_openLabel), findsOneWidget);
    });

    testWidgets('un nombre de 2 letras no se guarda', (tester) async {
      final habit = _habit();
      final repository = InMemoryHabitRepository(
        seed: [habit],
        latency: Duration.zero,
      );
      await _open(tester, EditHabitScreen(habit: habit), repository);

      await tester.enterText(find.byType(TextFormField), 'Le');
      await tester.pump();
      await _tapText(tester, AppStrings.saveChanges);

      expect(find.text(AppStrings.habitNameTooShort), findsOneWidget);
      expect(
        ((await tester.runAsync(() => repository.getById(habit.id))))!.name,
        habit.name,
      );
    });
  });

  group('Eliminar desde el detalle', () {
    testWidgets('pide confirmación, borra y regresa', (tester) async {
      final habit = _habit();
      final repository = InMemoryHabitRepository(
        seed: [habit],
        latency: Duration.zero,
      );
      await _open(tester, HabitDetailScreen(habit: habit), repository);

      await _tapText(tester, AppStrings.deleteHabit);
      expect(find.text(AppStrings.deleteDialogTitle), findsOneWidget);
      await tester.tap(find.text(AppStrings.delete));
      await tester.pumpAndSettle();

      expect(
        (await tester.runAsync(() => repository.getById(habit.id))),
        isNull,
      );
      expect(find.text(_openLabel), findsOneWidget);
    });

    testWidgets('cancelar no borra nada', (tester) async {
      final habit = _habit();
      final repository = InMemoryHabitRepository(
        seed: [habit],
        latency: Duration.zero,
      );
      await _open(tester, HabitDetailScreen(habit: habit), repository);

      await _tapText(tester, AppStrings.deleteHabit);
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();

      expect(
        (await tester.runAsync(() => repository.getById(habit.id))),
        isNotNull,
      );
      expect(find.text(AppStrings.deleteHabit), findsOneWidget);
    });
  });
}

class _Recording extends InMemoryHabitRepository {
  _Recording() : super(seed: const [], latency: Duration.zero);
  int creates = 0;

  @override
  Future<Habit> create(Habit habit) {
    creates++;
    return super.create(habit);
  }
}
