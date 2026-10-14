import 'package:rachas/features/habits/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getAll();

  Future<Habit?> getById(String id);

  Future<Habit> create(Habit habit);

  Future<Habit> update(Habit habit);

  Future<Habit> toggleComplete(String id, DateTime date);

  Future<Habit> useJoker(String id, DateTime date);

  Future<void> delete(String id);
}
