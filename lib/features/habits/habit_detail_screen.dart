import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rachas/app/app_routes.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/theme/app_theme.dart';
import 'package:rachas/core/utils/date_helpers.dart';
import 'package:rachas/core/widgets/app_dialogs.dart';
import 'package:rachas/core/widgets/app_logo.dart';
import 'package:rachas/features/notifications/notification_service.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/habits/streak_logic.dart' show currentStreak;
import 'package:rachas/features/habits/widgets/habit_avatar.dart';
import 'package:rachas/features/habits/widgets/month_calendar.dart';

class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({super.key, required this.habit});

  final Habit habit;

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habit _habit;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
  }

  Future<void> _delete() async {
    final repository = context.read<HabitRepository>();
    final notifications = context.read<NotificationService?>();
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: AppStrings.deleteDialogTitle,
      message: AppStrings.deleteDialogBody(_habit.name),
      confirmLabel: AppStrings.delete,
      icon: Icons.delete_outline,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await repository.delete(_habit.id);
      await notifications?.cancel(_habit.id);
      if (!mounted) return;
      // Mis hábitos recarga la lista al volver.
      Navigator.pop(context, true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _deleting = false);
      final message = error is AppException
          ? error.message
          : AppStrings.unexpectedError;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            action: SnackBarAction(label: AppStrings.retry, onPressed: _delete),
          ),
        );
    }
  }

  Future<void> _openEdit() async {
    await Navigator.pushNamed(context, AppRoutes.editHabit, arguments: _habit);

    if (!mounted) return;
    await _reload();
  }

  Future<void> _reload() async {
    final repository = context.read<HabitRepository>();
    try {
      final updated = await repository.getById(_habit.id);
      if (!mounted) return;
      if (updated == null) {
        Navigator.pop(context);
      } else {
        setState(() => _habit = updated);
      }
    } on AppException catch (_) {}
  }

  String? _reminderText(BuildContext context) {
    final parsed = parseReminderTime(_habit.reminderTime);
    if (parsed == null) return null;
    final time = TimeOfDay(hour: parsed.hour, minute: parsed.minute);
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final streak = currentStreak(_habit, today);
    final reminder = _reminderText(context);

    return Scaffold(
      appBar: AppBar(title: const AppBarTitle(AppStrings.habitDetailTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(habit: _habit, streak: streak),
                    const SizedBox(height: 20),
                    _StreakPanel(streak: streak),
                    const SizedBox(height: 14),
                    _JokersPanel(left: _habit.jokersLeft),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                child: MonthCalendar(
                  month: today,
                  completedDates: _habit.completedDates,
                  today: today,
                ),
              ),
              if (reminder != null) ...[
                const SizedBox(height: 16),
                _ReminderTile(time: reminder),
              ],
              const SizedBox(height: 16),

              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  key: const ValueKey('edit-button'),
                  onPressed: _deleting ? null : _openEdit,
                  icon: const Icon(Icons.tune, size: 20),
                  label: const Text(AppStrings.editLabel),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.beige,
                    foregroundColor: AppTheme.navy,
                    side: const BorderSide(color: AppTheme.skyBlue),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const ValueKey('delete-button'),
                onPressed: _deleting ? null : _delete,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.darkPink,
                  disabledBackgroundColor: AppTheme.darkPink.withValues(
                    alpha: 0.7,
                  ),
                  disabledForegroundColor: Colors.white,
                ),
                icon: _deleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete_outline),
                label: Text(
                  _deleting ? AppStrings.deleting : AppStrings.deleteHabit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.beige,
        border: Border.all(color: AppTheme.skyBlue),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.habit, required this.streak});

  final Habit habit;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            HabitAvatar(habit: habit, size: 56),
            if (streak > 0)
              const Positioned(right: -6, bottom: -6, child: _FlameBadge()),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            habit.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _FlameBadge extends StatelessWidget {
  const _FlameBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.azalea,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.beige, width: 2),
      ),
      child: const Icon(
        Icons.local_fire_department,
        size: 14,
        color: AppTheme.darkPink,
      ),
    );
  }
}

class _StreakPanel extends StatelessWidget {
  const _StreakPanel({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.azalea.withValues(alpha: 0.6),
        border: Border.all(color: AppTheme.azalea),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              border: Border.all(color: AppTheme.azalea),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: AppTheme.darkPink,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.streakDays(streak),
                  style: textTheme.titleMedium?.copyWith(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  AppStrings.currentStreakLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppTheme.slateBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JokersPanel extends StatelessWidget {
  const _JokersPanel({required this.left});

  final int left;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.azalea.withValues(alpha: 0.4),
        border: Border.all(color: AppTheme.azalea.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield, size: 18, color: AppTheme.darkPink),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.jokersLeftOf(left, Habit.maxJokers),
                      style: textTheme.titleMedium?.copyWith(
                        color: AppTheme.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AppStrings.jokersLeftLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.slateBlue,
                      ),
                    ),
                  ],
                ),
              ),

              for (var i = 0; i < Habit.maxJokers; i++)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.verified,
                    size: 18,
                    color: i < left
                        ? AppTheme.darkPink
                        : AppTheme.slateBlue.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.jokersHint,
            style: textTheme.bodySmall?.copyWith(color: AppTheme.slateBlue),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.beige,
        border: Border.all(color: AppTheme.skyBlue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            size: 20,
            color: AppTheme.navy,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.dailyReminderLabel,
              style: textTheme.labelLarge?.copyWith(
                color: AppTheme.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.skyBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: textTheme.labelLarge?.copyWith(
                color: AppTheme.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
