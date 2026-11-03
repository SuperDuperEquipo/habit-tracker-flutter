import 'package:flutter/material.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/core/widgets/app_text_field.dart';

import '../../core/widgets/habit_icon_picker.dart';
import '../../core/widgets/habit_color_picker.dart';
import '../../core/widgets/habit_time_picker_field.dart';

class HabitForm extends StatefulWidget {
  final Habit? initialHabit;
  final Function(Habit) onSubmit;
  final String submitLabel;

  const HabitForm({
    super.key,
    this.initialHabit,
    required this.onSubmit,
    required this.submitLabel,
  });

  @override
  HabitFormState createState() => HabitFormState(); // Quitamos el guion bajo
}

class HabitFormState extends State<HabitForm> {
  // Quitamos el guion bajo
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _timeFocusNode = FocusNode();

  late String _selectedIcon;
  late int _selectedColorValue;
  late TimeOfDay _selectedTime;

  String? _serverErrorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialHabit?.name ?? '',
    );
    _selectedIcon = widget.initialHabit?.iconKey ?? Habit.defaultIconKey;
    _selectedColorValue =
        widget.initialHabit?.colorValue ?? Habit.defaultColorValue;

    final initialReminder = widget.initialHabit?.reminderTime;
    if (initialReminder != null && initialReminder.contains(':')) {
      final parts = initialReminder.split(':');
      _selectedTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts[1]) ?? 30,
      );
    } else {
      _selectedTime = const TimeOfDay(hour: 8, minute: 30);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _timeFocusNode.dispose();
    super.dispose();
  }

  String _formatTimeToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Getters públicos para que CreateHabitScreen lea los valores del usuario
  String get habitName => _nameController.text.trim();
  String get iconKey => _selectedIcon;
  int get colorValue => _selectedColorValue;
  String get reminderTime => _formatTimeToString(_selectedTime);

  bool validate() => _formKey.currentState?.validate() ?? false;

  void setServerValidationError(String? error) {
    setState(() => _serverErrorMessage = error);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Nombre de tu hábito',
            placeholder: 'Ej. Leer 20 páginas',
            controller: _nameController,
            maxLength: 40,
            focusNode: _nameFocusNode,
            textInputAction: TextInputAction.next,
            errorMessage: _serverErrorMessage,
            onChanged: (value) {
              if (_serverErrorMessage != null) {
                setState(() => _serverErrorMessage = null);
              }
            },
            onClear: () => _nameController.clear(),
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_timeFocusNode);
            },
          ),
          const SizedBox(height: 24),
          HabitIconPicker(
            selectedKey: _selectedIcon,
            onSelected: (option) => setState(() => _selectedIcon = option.key),
          ),
          const SizedBox(height: 24),
          HabitColorPicker(
            selectedColorValue: _selectedColorValue,
            onSelected: (option) =>
                setState(() => _selectedColorValue = option.colorValue),
          ),
          const SizedBox(height: 24),
          HabitTimePickerField(
            selectedTime: _selectedTime,
            onTimeChanged: (newTime) => setState(() => _selectedTime = newTime),
          ),
        ],
      ),
    );
  }
}
