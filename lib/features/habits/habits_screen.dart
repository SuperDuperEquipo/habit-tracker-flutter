import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rachas/app/app_routes.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/state/view_state.dart';
import 'package:rachas/core/theme/app_theme.dart';
import 'package:rachas/core/widgets/app_dialogs.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_repository.dart';
import 'package:rachas/features/habits/habits_provider.dart';
import 'package:rachas/features/habits/widgets/empty_state.dart';
import 'package:rachas/features/habits/widgets/habit_card.dart';
import 'package:rachas/features/habits/widgets/offline_state.dart';
import 'package:rachas/features/habits/widgets/habits_summary.dart';
import 'package:rachas/features/login/token_storage.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key, this.userName});

  /// El saludo no lleva nombre por defecto; acepta uno opcional.
  final String? userName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          HabitsProvider(repository: context.read<HabitRepository>(),
          readUserName: TokenStorage().readDisplayName,
        )..loadUserName(),
      child: _HabitsView(userName: userName),
    );
  }
}

class _HabitsView extends StatefulWidget {
  const _HabitsView({this.userName});

  final String? userName;

  @override
  State<_HabitsView> createState() => _HabitsViewState();
}

class _HabitsViewState extends State<_HabitsView> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = context.read<HabitsProvider>().load();
  }

  void _retry() {
    setState(() => _loadFuture = context.read<HabitsProvider>().load());
  }

  Future<void> _openCreate() async {
    await Navigator.pushNamed(context, AppRoutes.createHabit);
    if (mounted) await context.read<HabitsProvider>().refresh();
  }

  Future<void> _openEdit(Habit habit) async {
    await Navigator.pushNamed(context, AppRoutes.editHabit, arguments: habit);
    if (mounted) await context.read<HabitsProvider>().refresh();
  }

  Future<void> _toggle(Habit habit) async {
    final error = await context.read<HabitsProvider>().toggle(habit.id);
    _showError(error);
  }

  Future<void> _useJoker(Habit habit) async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: AppStrings.jokerDialogTitle,
      message: AppStrings.jokerDialogBody,
      confirmLabel: AppStrings.use,
      cancelLabel: AppStrings.cancel,
      icon: Icons.shield,
    );
    if (confirmed != true || !mounted) return;
    final error = await context.read<HabitsProvider>().useJoker(habit.id);
    _showError(error);
  }

  void _showError(AppException? error) {
    if (error == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error.message)));
  }

  ViewState<List<Habit>> _toViewState(
    AsyncSnapshot<void> snapshot,
    List<Habit> habits,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const ViewLoading();
    }
    if (snapshot.hasError) {
      final error = snapshot.error;
      return ViewError(
        error is AppException
            ? error
            : const AppException(AppStrings.unexpectedError),
      );
    }
    return habits.isEmpty ? const ViewEmpty() : ViewData(habits);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitsProvider>();

    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        final state = _toViewState(snapshot, provider.habits);
        final hasData = state is ViewData<List<Habit>>;

        final content = switch (state) {
          ViewLoading() => <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
          ViewEmpty() => <Widget>[EmptyState(onCreate: _openCreate)],
          ViewError(:final error) => <Widget>[
            OfflineState(error: error, onRetry: _retry),
          ],
          ViewData(:final data) => <Widget>[
            HabitsSummary(
              completed: provider.completedToday,
              total: provider.total,
            ),
            const SizedBox(height: 16),
            for (final habit in data)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: HabitCard(
                  key: ValueKey(habit.id),
                  habit: habit,
                  today: provider.today,
                  onToggle: () => _toggle(habit),
                  onUseJoker: () => _useJoker(habit),
                  onOpen: () => _openEdit(habit),
                ),
              ),
          ],
        };

        return Scaffold(
          floatingActionButton: hasData
              ? FloatingActionButton.extended(
                  onPressed: _openCreate,
                  backgroundColor: AppTheme.navy,
                  foregroundColor: AppTheme.background,
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.newHabit),
                )
              : null,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              children: [
                const _Header(),
                const SizedBox(height: 16),
                _Greeting(
                  name: widget.userName ?? provider.userName,
                  subtitle: hasData
                      ? AppStrings.habitsScheduled(provider.total)
                      : AppStrings.habitsCalmSubtitle,
                ),
                const SizedBox(height: 16),
                ...content,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.navy,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.local_fire_department,
            size: 20,
            color: AppTheme.azalea,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appName,
              style: textTheme.titleMedium?.copyWith(
                color: AppTheme.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              AppStrings.navHabits,
              style: textTheme.bodySmall?.copyWith(color: AppTheme.slateBlue),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppTheme.navy,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 20, color: AppTheme.background),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name, required this.subtitle});

  final String? name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.greeting(name),
          style: textTheme.headlineSmall?.copyWith(
            color: AppTheme.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(color: AppTheme.slateBlue),
        ),
      ],
    );
  }
}
