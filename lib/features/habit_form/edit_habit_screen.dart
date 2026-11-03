
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/theme/app_theme.dart';
import 'package:rachas/core/widgets/app_logo.dart';
import 'package:rachas/features/habit_form/habit_form.dart';
import 'package:rachas/features/habit_form/habit_form_card.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/notifications/notification_service.dart';

/// Edita nombre, ícono, color y recordatorio con PUT. La racha, los comodines
/// y el historial no cambian. Eliminar está en el detalle, como en Stitch.
class EditHabitScreen extends StatefulWidget {
  const EditHabitScreen({super.key, required this.habit});

  final Habit habit;

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<HabitFormState>();
  bool _busy = false;

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (_busy || form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();
    final repository = context.read<HabitRepository>();
    final notifications = context.read<NotificationService?>();
    final edited = widget.habit.copyWith(
      name: form.habitName,
      iconKey: form.iconKey,
      colorValue: form.colorValue,
      reminderTime: form.reminderTime,
    );

    setState(() => _busy = true);

    try {
      final saved = await repository.update(edited);
      await notifications?.schedule(saved);
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
      appBar: AppBar(title: const AppBarTitle(AppStrings.editHabitTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: HabitFormCard(
            children: [
              const HabitFormHeader(
                icon: Icons.edit_outlined,
                title: AppStrings.editHabitTitle,
                subtitle: AppStrings.editHabitSubtitle,
              ),
              const SizedBox(height: 20),
              const _StreakNotice(),
              const SizedBox(height: 20),
              HabitForm(key: _formKey, initialHabit: widget.habit),
              const SizedBox(height: 24),
              const HabitTipCard(),
              const SizedBox(height: 24),
              HabitFormActions(
                label: AppStrings.saveChanges,
                busyLabel: AppStrings.savingChanges,
                busy: _busy,
                onSave: _save,
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.skyBlue.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.skyBlue),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined, size: 20, color: AppTheme.navy),
          const SizedBox(width: 10),
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
