import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/habits/streak_logic.dart' as streak;

class InMemoryHabitRepository implements HabitRepository {
  InMemoryHabitRepository({
    List<Habit>? seed,
    this.latency = const Duration(milliseconds: 300),
  }) : _habits = {for (final habit in seed ?? sampleHabits()) habit.id: habit};

  final Duration latency;
  final Map<String, Habit> _habits;
  int _nextId = 1;

  @override
  Future<List<Habit>> getAll() async {
    await _wait();
    return _habits.values.toList(growable: false);
  }

  @override
  Future<Habit?> getById(String id) async {
    await _wait();
    return _habits[id];
  }

  @override
  Future<Habit> create(Habit habit) async {
    await _wait();
    final created = habit.copyWith(id: 'local-${_nextId++}');
    _habits[created.id] = created;
    return created;
  }

  @override
  Future<Habit> update(Habit habit) async {
    await _wait();
    _require(habit.id);
    _habits[habit.id] = habit;
    return habit;
  }

  @override
  Future<Habit> toggleComplete(String id, DateTime date) async {
    await _wait();
    final updated = streak.toggleComplete(_require(id), date);
    _habits[id] = updated;
    return updated;
  }

  @override
  Future<Habit> useJoker(String id, DateTime date) async {
    await _wait();
    final updated = streak.useJoker(_require(id), date);
    _habits[id] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _wait();
    _require(id);
    _habits.remove(id);
  }

  Future<void> _wait() => Future<void>.delayed(latency);

  Habit _require(String id) {
    final habit = _habits[id];
    if (habit == null) {
      throw const AppException(
        AppStrings.habitNotFound,
        type: AppErrorType.notFound,
      );
    }
    return habit;
  }
}

List<Habit> sampleHabits() {
  final now = DateTime.now();
  List<DateTime> lastDays(int count, {required int endingDaysAgo}) => [
    for (var i = 0; i < count; i++)
      DateTime(now.year, now.month, now.day - endingDaysAgo - i),
  ];
  final createdAt = DateTime(now.year, now.month, now.day - 30);

  return [
    Habit(
      id: 'seed-1',
      name: 'Lectura de apuntes',
      iconKey: 'menu_book',
      colorValue: 0xFF2F4058,
      reminderTime: '08:30',
      streak: 13,
      jokersLeft: 3,
      completedDates: lastDays(13, endingDaysAgo: 0),
      createdAt: createdAt,
    ),
    Habit(
      id: 'seed-2',
      name: 'Tomar 2L de agua',
      iconKey: 'water_drop',
      colorValue: 0xFFC8D9E6,
      reminderTime: '10:00',
      streak: 5,
      jokersLeft: 2,
      completedDates: lastDays(5, endingDaysAgo: 1),
      createdAt: createdAt,
    ),
    Habit(
      id: 'seed-3',
      name: 'Repaso con Pomodoro',
      iconKey: 'headphones',
      colorValue: 0xFFF7C9D4,
      reminderTime: '16:00',
      streak: 18,
      jokersLeft: 3,
      completedDates: lastDays(18, endingDaysAgo: 1),
      createdAt: createdAt,
    ),
    Habit(
      id: 'seed-4',
      name: 'Caminar 20 minutos',
      iconKey: 'directions_bike',
      colorValue: 0xFFC45B78,
      reminderTime: '19:30',
      streak: 4,
      jokersLeft: 2,
      completedDates: lastDays(4, endingDaysAgo: 1),
      createdAt: createdAt,
    ),
  ];
}
