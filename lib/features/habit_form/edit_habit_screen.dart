import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/theme/theme_data.dart';
import 'package:rachas/core/widgets/app_dialogs.dart';
import 'package:rachas/features/habit_form/habit_form.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/notifications/notification_service.dart';

class EditHabitScreen extends StatefulWidget {
  const EditHabitScreen({super.key, required this.habit});

  final Habit habit;

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  bool _busy = false;

  /// Guarda los cambios y actualiza el recordatorio.
  Future<void> _save(Habit edited) async {
    if (_busy) return;

    final repository = context.read<HabitRepository>();
    final notifications = context.read<NotificationService>();

    final updated = widget.habit.copyWith(
      name: edited.name,
      iconKey: edited.iconKey,
      colorValue: edited.colorValue,
      reminderTime: edited.reminderTime,
      clearReminderTime: edited.reminderTime == null,
    );

    await _run(() async {
      final savedHabit = await repository.update(updated);

      // Un fallo del recordatorio no debe deshacer el hábito ya guardado.
      try {
        await notifications.schedule(savedHabit);
      } on Object {
        debugPrint('No se pudo actualizar el recordatorio del hábito.');
      }

      return savedHabit;
    });
  }

  /// Elimina el hábito después de confirmar y cancela su recordatorio.
  Future<void> _delete() async {
    if (_busy) return;

    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: AppStrings.deleteDialogTitle,
      message: AppStrings.deleteDialogBody(widget.habit.name),
      confirmLabel: AppStrings.delete,
      cancelLabel: AppStrings.cancel,
      icon: Icons.delete_outline,
    );

    if (confirmed != true || !mounted) return;

    final repository = context.read<HabitRepository>();
    final notifications = context.read<NotificationService>();

    await _run(() async {
      await repository.delete(widget.habit.id);

      // La eliminación se conserva aunque falle la cancelación local.
      try {
        await notifications.cancel(widget.habit.id);
      } on Object {
        debugPrint('No se pudo cancelar el recordatorio del hábito.');
      }

      return null;
    });
  }

  Future<void> _run(Future<Object?> Function() action) async {
    if (_busy) return;

    setState(() => _busy = true);

    try {
      await action();

      if (!mounted) return;

      Navigator.pop(context, true);
    } on AppException catch (error) {
      _fail(error.message);
    } on Object {
      _fail(AppStrings.unexpectedError);
    }
  }

  void _fail(String message) {
    if (!mounted) return;

    setState(() => _busy = false);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.editHabitTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StreakNotice(),
            const SizedBox(height: 20),
            HabitForm(
              initialHabit: widget.habit,
              submitLabel: _busy
                  ? AppStrings.savingChanges
                  : AppStrings.saveChanges,
              onSubmit: _save,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton.icon(
                onPressed: _busy ? null : _delete,
                icon: const Icon(Icons.delete_outline),
                label: const Text(AppStrings.deleteHabit),
                style: TextButton.styleFrom(foregroundColor: AppTheme.darkPink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakNotice extends StatelessWidget {
  const _StreakNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.palePink,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.azalea),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 20,
            color: AppTheme.darkPink,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.editStreakNotice,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
