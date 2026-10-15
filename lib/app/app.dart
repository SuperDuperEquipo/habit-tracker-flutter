import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rachas/app/app_router.dart';
import 'package:rachas/app/app_routes.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/network/api_client.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/login/auth_service.dart';
import 'package:rachas/features/notifications/notification_service.dart';

class RachasApp extends StatelessWidget {
  const RachasApp({
    super.key,
    required this.apiClient,
    required this.authService,
    required this.habitRepository,
    required this.notifications,
    this.initialRoute = AppRoutes.login,
  });

  final ApiClient apiClient;
  final AuthService authService;
  final HabitRepository habitRepository;
  final NotificationService notifications;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthService>.value(value: authService),
        Provider<HabitRepository>.value(value: habitRepository),
        Provider<NotificationService>.value(value: notifications),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        initialRoute: initialRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
