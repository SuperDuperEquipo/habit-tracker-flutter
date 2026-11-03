import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rachas/app/app_router.dart';
import 'package:rachas/app/app_routes.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/network/api_client.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/notifications/notification_service.dart';
import 'package:rachas/features/habits/habits_provider.dart';

class RachasApp extends StatelessWidget {
  const RachasApp({
    super.key,
    required this.apiClient,
    required this.habitRepository,
    required this.notifications,
  });

  final ApiClient apiClient;
  final HabitRepository habitRepository;
  final NotificationService notifications;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<HabitRepository>.value(value: habitRepository),
        Provider<NotificationService>.value(value: notifications),
        ChangeNotifierProvider<HabitsProvider>(
          create: (context) => HabitsProvider(
            repository: context.read<HabitRepository>(),
            readUserName: context.read<AuthService>().readDisplayName,
          ),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
