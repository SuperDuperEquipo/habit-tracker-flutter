import 'package:flutter/material.dart';
import 'package:rachas/features/habit_form/habit_form.dart';
import 'package:rachas/features/habits/habit.dart';

class EditHabitScreen extends StatelessWidget {
  const EditHabitScreen({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar hábito')),
      body: HabitForm(
        initialHabit: habit,
        submitLabel: 'Guardar cambios',
        onSubmit: (_) => Navigator.pop(context, true),
      ),
    );
  }
}
