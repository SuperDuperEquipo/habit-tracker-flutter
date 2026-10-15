import 'package:flutter/material.dart';
import 'package:rachas/features/habits/habit.dart';

// Asegúrate de importar tus widgets compartidos desde la ruta correcta:
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/habit_icon_picker.dart';
import '../../core/widgets/habit_color_picker.dart';
import '../../core/widgets/habit_time_picker_field.dart';
import '../../core/utils/validators.dart';

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

  late String _selectedIcon;
  late int _selectedColorValue;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialHabit?.name ?? '',
    );
    _selectedIcon = widget.initialHabit?.iconKey ?? 'menu_book';
    _selectedColorValue = widget.initialHabit?.colorValue ?? 0xFF2F4058;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de Nombre (hasta 40 caracteres, mínimo 3 por validador)
          TextFormField(
            controller: _nameController,
            maxLength: 40,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              labelText: 'Nombre de tu hábito',
              hintText: 'Ej. Leer 20 páginas',
              counterText: '',
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.secondary.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.secondary.withValues(alpha: 0.4),
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.cancel_outlined,
                  color: colorScheme.secondary,
                  size: 20,
                ),
                onPressed: () => _nameController.clear(),
              ),
            ),
            validator: Validators.validateHabitName,
          ),
          const SizedBox(height: 24),

          // Selector de 12 Íconos
          HabitIconPicker(
            selectedKey: _selectedIcon,
            onSelected: (option) {
              setState(() => _selectedIcon = option.key);
            },
          ),
          const SizedBox(height: 24),

          // Selector de 8 Colores de identidad
          HabitColorPicker(
            selectedColorValue: _selectedColorValue,
            onSelected: (option) {
              setState(() => _selectedColorValue = option.colorValue);
            },
          ),
          const SizedBox(height: 24),

          // Selector de Hora de recordatorio
          HabitTimePickerField(
            selectedTime: _selectedTime,
            onTimeChanged: (newTime) {
              setState(() => _selectedTime = newTime);
            },
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final habit = Habit(
                    id: widget.initialHabit?.id ?? '',
                    name: _nameController.text.trim(),
                    iconKey: _selectedIcon,
                    colorValue: _selectedColorValue,
                    reminderTime: _formatTimeToString(_selectedTime),
                    streak: widget.initialHabit?.streak ?? 0,
                    jokersLeft: widget.initialHabit?.jokersLeft ?? 3,
                    completedDates: widget.initialHabit?.completedDates ?? [],
                    createdAt: widget.initialHabit?.createdAt ?? DateTime.now(),
                  );
                  widget.onSubmit(habit);
                }
              },
              child: Text(
                widget.submitLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
