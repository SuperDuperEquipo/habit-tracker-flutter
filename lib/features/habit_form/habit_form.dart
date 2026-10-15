import 'package:flutter/material.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/core/widgets/app_text_field.dart';

// Descomenta los imports de tus selectores cuando los tengas listos:
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
  State<HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends State<HabitForm> {
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

  GlobalKey<FormState> get formKey => _formKey;

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
          // Campo de texto reutilizable (AppTextField) con validación de mínimo 3 caracteres
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
              // Validación local de mínimo 3 caracteres
              if (value.trim().isNotEmpty && value.trim().length < 3) {
                // Puedes manejar un mensaje local si gustas
              }
            },
            onClear: () => _nameController.clear(),
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_timeFocusNode);
            },
          ),
          const SizedBox(height: 24),

          // Selector de Íconos (Descomentar al integrar el widget del equipo)
          HabitIconPicker(
            selectedKey: _selectedIcon,
            onSelected: (option) => setState(() => _selectedIcon = option.key),
          ),
          const SizedBox(height: 24),

          // Selector de Colores (Descomentar al integrar el widget del equipo)
          HabitColorPicker(
            selectedColorValue: _selectedColorValue,
            onSelected: (option) =>
                setState(() => _selectedColorValue = option.colorValue),
          ),
          const SizedBox(height: 24),

          // Selector de Hora (Descomentar al integrar el widget del equipo)
          HabitTimePickerField(
            // focusNode: _timeFocusNode,
            selectedTime: _selectedTime,
            onTimeChanged: (newTime) => setState(() => _selectedTime = newTime),
          ),
        ],
      ),
    );
  }
}
