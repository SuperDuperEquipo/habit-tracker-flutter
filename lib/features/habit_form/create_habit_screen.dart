import 'package:flutter/material.dart';
import 'package:rachas/features/habit_form/habit_form.dart';

class CreateHabitScreen extends StatelessWidget {
  const CreateHabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo hábito')),
      body: HabitForm(
        submitLabel: 'Guardar hábito',
        onSubmit: (_) => Navigator.pop(context, true),
      ),
    );
  }
}
