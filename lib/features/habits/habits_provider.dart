import 'package:flutter/foundation.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/utils/date_helpers.dart';
import 'package:rachas/features/habits/fetch_habits.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/habits/streak_logic.dart' as streak;

class HabitsProvider extends ChangeNotifier {
  HabitsProvider({
    required HabitRepository repository,
    DateTime Function()? clock,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now;

  final HabitRepository _repository;
  final DateTime Function() _clock;
  final Set<String> _pending = {};

  List<Habit> _habits = const [];

  List<Habit> get habits => _habits;

  DateTime get today => dateOnly(_clock());

  int get total => _habits.length;

  /// El resumen se calcula siempre desde los hábitos, nunca a mano.
  int get completedToday =>
      _habits.where((h) => streak.isCompletedOn(h, today)).length;

  /// Carga la lista. Lanza [AppException] si falla.
  Future<void> load() async {
    _habits = await fetchHabits(_repository);
    notifyListeners();
  }

  /// Recarga sin mostrar errores: si falla, se conserva la lista actual.
  Future<void> refresh() async {
    try {
      await load();
    } on AppException {
      // Se queda con lo que ya se ve.
    }
  }

  Future<AppException?> toggle(String id) {
    return _apply(
      id,
      (habit) => streak.toggleComplete(habit, today),
      () => _repository.toggleComplete(id, today),
    );
  }

  Future<AppException?> useJoker(String id) {
    return _apply(
      id,
      (habit) => streak.useJoker(habit, today),
      () => _repository.useJoker(id, today),
    );
  }

  /// Aplica [rule] al instante y guarda en segundo plano con [persist].
  /// Devuelve el error si el guardado falla (y revierte el cambio).
  Future<AppException?> _apply(
    String id,
    Habit Function(Habit) rule,
    Future<Habit> Function() persist,
  ) async {
    if (!_pending.add(id)) return null; // ya hay una operación en curso
    final index = _habits.indexWhere((h) => h.id == id);
    if (index < 0) {
      _pending.remove(id);
      return null;
    }

    final previous = _habits[index];
    _replace(id, rule(previous));

    try {
      _replace(id, await persist());
      return null;
    } on AppException catch (e) {
      _replace(id, previous);
      return e;
    } on Object {
      _replace(id, previous);
      return const AppException(AppStrings.unexpectedError);
    } finally {
      _pending.remove(id);
    }
  }

  void _replace(String id, Habit habit) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index < 0) return;
    _habits = [..._habits]..[index] = habit;
    notifyListeners();
  }
}
