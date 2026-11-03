import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/theme/theme_data.dart';
import 'package:rachas/core/widgets/app_dialogs.dart';
import 'package:rachas/features/habit_form/habit_form.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_repository.dart';

class EditHabitScreen extends StatefulWidget {
  const EditHabitScreen({super.key, required this.habit});

  final Habit habit;

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  bool _busy = false;

  /// Guarda los cambios con PUT
  Future<void> _save(Habit edited) async {
    if (_busy) return;
    final repository = context.read<HabitRepository>();
    final updated = widget.habit.copyWith(
      name: edited.name,
      iconKey: edited.iconKey,
      colorValue: edited.colorValue,
      reminderTime: edited.reminderTime,
      clearReminderTime: edited.reminderTime == null,
    );
    await _run(() => repository.update(updated));
  }

  Future<void> _delete() async {
    final repository = context.read<HabitRepository>();
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: AppStrings.deleteDialogTitle,
      message: AppStrings.deleteDialogBody(widget.habit.name),
      confirmLabel: AppStrings.delete,
      cancelLabel: AppStrings.cancel,
      icon: Icons.delete_outline,
    );
    if (confirmed != true || !mounted) return;
    await _run(() => repository.delete(widget.habit.id));
  }
  /// (Mis hábitos recarga la lista al volver). Si falla, muestra el error.
  Future<void> _run(Future<Object?> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      Navigator.pop(context, true);
    } on AppException catch (e) {
      _fail(e.message);
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
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.darkPink,
                ),
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