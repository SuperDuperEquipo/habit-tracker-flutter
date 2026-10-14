import 'package:dio/dio.dart';
import 'package:rachas/core/config/api_endpoints.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/errors/error_handler.dart';
import 'package:rachas/core/network/api_client.dart';
import 'package:rachas/core/utils/date_helpers.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/habits/streak_logic.dart' as streak;

typedef UidProvider = Future<String?> Function();

/// Hábitos en Firebase Realtime Database, uno por usuario:
///
///     users/{uid}/habits/{habitId}          // habitId lo genera Firebase
///       name: "Leer 20 min"                 -> Habit.name
///       iconKey: "menu_book"                -> Habit.iconKey
///       colorValue: 4281286744              -> Habit.colorValue (ARGB)
///       reminderTime: "20:00"               -> Habit.reminderTime (opcional)
///       streak: 5                           -> Habit.streak
///       jokersLeft: 3                       -> Habit.jokersLeft (0 a 3)
///       completedDates: ["2026-10-12"]      -> Habit.completedDates
///       createdAt: "2026-10-13T11:40:00"    -> Habit.createdAt
///
/// Habit.id es la llave {habitId}; no se guarda dentro del objeto. Firebase
/// omite las listas vacías y los valores null, por eso Habit.fromJson los
/// trata como lista vacía y como "sin recordatorio".
class ApiHabitRepository implements HabitRepository {
  ApiHabitRepository({
    required ApiClient apiClient,
    required UidProvider uidProvider,
  }) : _dio = apiClient.dio,
       _uidProvider = uidProvider;

  final Dio _dio;
  final UidProvider _uidProvider;

  @override
  Future<List<Habit>> getAll() {
    return _guard(() async {
      final uid = await _requireUid();
      final response = await _dio.get<dynamic>(ApiEndpoints.habits(uid));
      return _habitsFromData(response.data);
    });
  }

  @override
  Future<Habit?> getById(String id) {
    return _guard(() async {
      final uid = await _requireUid();
      final response = await _dio.get<dynamic>(ApiEndpoints.habit(uid, id));
      final data = response.data;
      if (data is! Map) return null;
      return Habit.fromJson(Map<String, dynamic>.from(data), id: id);
    });
  }

  @override
  Future<Habit> create(Habit habit) {
    return _guard(() async {
      final uid = await _requireUid();
      final response = await _dio.post<dynamic>(
        ApiEndpoints.habits(uid),
        data: habit.toJson(),
      );
      final data = response.data;
      final newId = data is Map ? data['name'] : null;
      if (newId is! String || newId.isEmpty) {
        throw const AppException(AppStrings.unexpectedError);
      }
      return habit.copyWith(id: newId);
    });
  }

  @override
  Future<Habit> update(Habit habit) async {
    _checkId(habit.id);
    return _guard(() async {
      final uid = await _requireUid();
      await _dio.put<dynamic>(
        ApiEndpoints.habit(uid, habit.id),
        data: habit.toJson(),
      );
      return habit;
    });
  }

  @override
  Future<Habit> toggleComplete(String id, DateTime date) async {
    _checkId(id);
    return _guard(() async {
      final updated = streak.toggleComplete(await _requireHabit(id), date);
      await _patch(id, {
        'streak': updated.streak,
        'completedDates': updated.completedDates.map(dateKey).toList(),
      });
      return updated;
    });
  }

  @override
  Future<Habit> useJoker(String id, DateTime date) async {
    _checkId(id);
    return _guard(() async {
      final updated = streak.useJoker(await _requireHabit(id), date);
      await _patch(id, {
        'jokersLeft': updated.jokersLeft,
        'streak': updated.streak,
        'completedDates': updated.completedDates.map(dateKey).toList(),
      });
      return updated;
    });
  }

  @override
  Future<void> delete(String id) async {
    _checkId(id);
    return _guard(() async {
      final uid = await _requireUid();
      await _dio.delete<dynamic>(ApiEndpoints.habit(uid, id));
    });
  }

  Future<void> _patch(String id, Map<String, Object?> fields) async {
    final uid = await _requireUid();
    await _dio.patch<dynamic>(ApiEndpoints.habit(uid, id), data: fields);
  }

  Future<Habit> _requireHabit(String id) async {
    final habit = await getById(id);
    if (habit == null) {
      throw const AppException(
        AppStrings.habitNotFound,
        type: AppErrorType.notFound,
      );
    }
    return habit;
  }

  Future<String> _requireUid() async {
    final uid = await _uidProvider();
    if (uid == null || uid.isEmpty) {
      throw const AppException(
        AppStrings.sessionExpired,
        type: AppErrorType.sessionExpired,
      );
    }
    return uid;
  }

  List<Habit> _habitsFromData(Object? data) {
    if (data is! Map) return const [];
    final habits = <Habit>[];
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is String && value is Map) {
        habits.add(Habit.fromJson(Map<String, dynamic>.from(value), id: key));
      }
    }
    habits.sort((a, b) {
      final byDate = a.createdAt.compareTo(b.createdAt);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return habits;
  }

  void _checkId(String id) {
    if (id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'El hábito todavía no tiene id');
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      Error.throwWithStackTrace(ErrorHandler.fromDio(e), stackTrace);
    } on Object catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const AppException(AppStrings.unexpectedError),
        stackTrace,
      );
    }
  }
}
