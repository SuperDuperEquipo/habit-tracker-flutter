import 'package:flutter/material.dart';
import 'package:rachas/features/habits/habit.dart';

// Stub: la Persona 4 lo reemplaza conservando esta firma.
class HabitForm extends StatelessWidget {
  const HabitForm({
    super.key,
    this.initialHabit,
    required this.onSubmit,
    required this.submitLabel,
  });

  final Habit? initialHabit;
  final Function(Habit) onSubmit;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    final habit = initialHabit ?? Habit.draft(name: 'Hábito de prueba');
    return Center(
      child: FilledButton(
        onPressed: () => onSubmit(habit),
        child: Text(submitLabel),
      ),
    );
  }
}
