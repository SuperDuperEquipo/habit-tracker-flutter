import 'package:flutter/widgets.dart';
import 'package:rachas/app/app.dart';
import 'package:rachas/core/network/api_client.dart';
import 'package:rachas/features/habits/api_habit_repository.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/habits/in_memory_habit_repository.dart';
import 'package:rachas/features/login/auth_service.dart';
import 'package:rachas/features/login/token_storage.dart';
import 'package:rachas/features/notifications/notification_service.dart';

const bool _useApi = bool.fromEnvironment('USE_API');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notifications = NotificationService();
  await notifications.init();

  final tokenStorage = TokenStorage();
  final authService = AuthService(tokenStorage: tokenStorage);
  final apiClient = ApiClient(
    tokenStorage: tokenStorage,
    authService: authService,
  );
  final HabitRepository habitRepository = _useApi
      ? ApiHabitRepository(
          apiClient: apiClient,
          uidProvider: tokenStorage.readUid,
        )
      : InMemoryHabitRepository();

  runApp(
    RachasApp(
      apiClient: apiClient,
      authService: authService,
      habitRepository: habitRepository,
      notifications: notifications,
    ),
  );
}
