import 'package:flutter/material.dart';
import 'package:rachas/app/app_routes.dart';
import 'package:rachas/app/home_shell.dart';
import 'package:rachas/features/habit_form/create_habit_screen.dart';
import 'package:rachas/features/habit_form/edit_habit_screen.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/login/login_screen.dart';

abstract final class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _route(settings, const LoginScreen());
      case AppRoutes.home:
        return _route(settings, const HomeShell());
      case AppRoutes.createHabit:
        return _route(settings, const CreateHabitScreen());
      case AppRoutes.editHabit:
        final habit = settings.arguments;
        if (habit is! Habit) return null;
        return _route(settings, EditHabitScreen(habit: habit));
    }
    return null;
  }

  static MaterialPageRoute<dynamic> _route(
    RouteSettings settings,
    Widget page,
  ) {
    return MaterialPageRoute<dynamic>(settings: settings, builder: (_) => page);
  }
}
