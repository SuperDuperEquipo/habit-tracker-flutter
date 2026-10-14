import 'package:flutter/widgets.dart';
import 'package:rachas/app/app.dart';
import 'package:rachas/core/network/api_client.dart';
import 'package:rachas/features/habits/api_habit_repository.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/habits/in_memory_habit_repository.dart';
import 'package:rachas/features/notifications/notification_service.dart';

const bool _useApi = bool.fromEnvironment('USE_API');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notifications = NotificationService();
  await notifications.init();

  final apiClient = ApiClient();
  final HabitRepository habitRepository = _useApi
      ? ApiHabitRepository(apiClient: apiClient, uidProvider: _currentUid)
      : InMemoryHabitRepository();

  runApp(
    RachasApp(
      apiClient: apiClient,
      habitRepository: habitRepository,
      notifications: notifications,
    ),
  );
}

// Stub: la Persona 2 lo reemplaza con el uid guardado en TokenStorage.
Future<String?> _currentUid() async => null;
