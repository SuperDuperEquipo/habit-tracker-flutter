import 'package:flutter/material.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/widgets/app_dialogs.dart';
import 'package:rachas/core/widgets/app_logo.dart';
import 'package:rachas/features/habit_form/habit_form.dart';
import 'package:rachas/features/habit_form/habit_form_card.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/notifications/notification_service.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({
    super.key,
    required this.habitRepository,
    this.notificationService,
  });

  final HabitRepository habitRepository;
  final NotificationService? notificationService;

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<HabitFormState>();
  bool _isSaving = false;

  Future<void> _handleSave() async {
    final form = _formKey.currentState;
    if (_isSaving || form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();
    form.setServerValidationError(null);
    setState(() => _isSaving = true);

    try {
      final created = await widget.habitRepository.create(
        Habit.draft(
          name: form.habitName,
          iconKey: form.iconKey,
          colorValue: form.colorValue,
          reminderTime: form.reminderTime,
        ),
      );
      await widget.notificationService?.schedule(created);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      // Un 400 es un dato inválido: se marca el campo. Lo demás, diálogo.
      if (e.type == AppErrorType.invalidData || e.statusCode == 400) {
        form.setServerValidationError(e.message);
      } else {
        _showServerError();
      }
    } on Object {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showServerError();
    }
  }

  void _showServerError() {
    AppDialogs.showServerErrorDialog(context: context, onRetry: _handleSave);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppBarTitle(AppStrings.newHabit)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: HabitFormCard(
            children: [
              const HabitFormHeader(
                icon: Icons.edit_note,
                title: AppStrings.newHabit,
                subtitle: AppStrings.newHabitSubtitle,
              ),
              const SizedBox(height: 24),
              HabitForm(key: _formKey),
              const SizedBox(height: 24),
              const HabitTipCard(),
              const SizedBox(height: 24),
              HabitFormActions(
                label: AppStrings.saveHabit,
                busyLabel: AppStrings.savingHabit,
                busy: _isSaving,
                onSave: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
