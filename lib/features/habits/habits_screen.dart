import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rachas/app/app_routes.dart';
import 'package:rachas/features/habits/habit_repository.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  Future<void> _openEdit(BuildContext context) async {
    final navigator = Navigator.of(context);
    final habits = await context.read<HabitRepository>().getAll();
    if (habits.isEmpty) return;
    await navigator.pushNamed(AppRoutes.editHabit, arguments: habits.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis hábitos')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            FilledButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.createHabit),
              child: const Text('Nuevo hábito'),
            ),
            OutlinedButton(
              onPressed: () => _openEdit(context),
              child: const Text('Editar hábito de prueba'),
            ),
          ],
        ),
      ),
    );
  }
}
