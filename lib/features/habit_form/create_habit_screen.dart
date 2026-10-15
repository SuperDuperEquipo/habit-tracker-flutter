import 'package:flutter/material.dart';
import 'package:rachas/features/habit_form/habit_form.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/api_habit_repository.dart';
import 'package:rachas/core/errors/app_exception.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key, required this.habitRepository});

  final ApiHabitRepository habitRepository;

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  bool _isSaving = false;
  String? _fieldErrorMessage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
      _fieldErrorMessage = null;
    });

    try {
      final newHabit = Habit.draft(name: 'Nuevo hábito');
      final createdHabit = await widget.habitRepository.create(newHabit);

      if (createdHabit.id.isNotEmpty) {
        debugPrint('POST Exitoso - Código 200 - ID nuevo: ${createdHabit.id}');
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      if (e.type == AppErrorType.invalidData || e.statusCode == 400) {
        setState(() {
          _fieldErrorMessage = e.message;
        });
      } else {
        _showServerErrorDialog(e.message);
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      debugPrint('Error inesperado: $e\n$stackTrace');
      _showServerErrorDialog(
        'No pudimos guardar tu hábito. Inténtalo de nuevo.',
      );
    }
  }

  void _showServerErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Error del servidor'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _handleSave();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo hábito')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: HabitForm(
                submitLabel: _isSaving
                    ? 'Guardando hábito...'
                    : 'Guardar hábito',
                onSubmit: (_) {},
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta de "Consejo de constancia"
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.eco_outlined,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consejo de constancia',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enlaza este hábito inmediatamente después del desayuno para que tu memoria lo active de forma natural.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botón primario: Guardar hábito
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor: colorScheme.primary.withValues(
                    alpha: 0.6,
                  ),
                  disabledForegroundColor: colorScheme.onPrimary.withValues(
                    alpha: 0.8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Icon(
                        Icons.check_circle_outline,
                        color: colorScheme.onPrimary,
                      ),
                label: Text(
                  _isSaving ? 'Guardando hábito...' : 'Guardar hábito',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botón secundario: Cancelar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                child: Text(
                  'Cancelar',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
