import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_repository.dart';

Future<List<Habit>> fetchHabits(HabitRepository repository) async {
  final habits = await repository.getAll();
  return List<Habit>.unmodifiable(habits);
}
