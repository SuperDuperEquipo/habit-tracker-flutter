import 'package:flutter/material.dart';
import 'package:rachas/core/validators.dart';
import 'package:rachas/core/widgets/app_text_field.dart';
import 'package:rachas/core/widgets/habit_color_picker.dart';
import 'package:rachas/core/widgets/habit_icon_picker.dart';
import 'package:rachas/core/widgets/habit_time_picker_field.dart';
import 'package:rachas/features/habits/habit.dart';

/// Campos compartidos de Crear y Editar hábito. Cada pantalla pone su propio
/// botón de guardar y lee los valores con un `GlobalKey<HabitFormState>`.
class HabitForm extends StatefulWidget {
  const HabitForm({super.key, this.initialHabit});

  final Habit? initialHabit;

  @override
  HabitFormState createState() => HabitFormState();
}

class HabitFormState extends State<HabitForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

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
    super.dispose();
  }

  String _formatTimeToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Valores que leen Crear y Editar al guardar.
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
            maxLength: Validators.maxHabitNameLength,
            textInputAction: TextInputAction.done,
            errorMessage: _serverErrorMessage,
            validator: Validators.habitName,
            // setState también muestra u oculta el botón de borrar el texto.
            onChanged: (_) => setState(() => _serverErrorMessage = null),
            onClear: () => setState(_nameController.clear),
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
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
