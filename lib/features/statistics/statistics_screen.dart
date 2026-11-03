import 'package:flutter/material.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/statistics/statistics_logic.dart';
 
const double _wideBreakpoint = 600;
 
/// Pantalla de estadísticas de la semana.
///
/// Solo recibe la lista de hábitos: no conoce el Provider. Quien la use
class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key, required this.habits, this.today});
 
  final List<Habit> habits;
 
  final DateTime? today;
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.statsTitle)),
      body: SafeArea(
        child: habits.isEmpty
            ? const _EmptyStats()
            : _StatsBody(
                stats: computeWeeklyStats(
                  habits,
                  today: today ?? DateTime.now(),
                ),
              ),
      ),
    );
  }
}
 
class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});
 
  final WeeklyStats stats;
 
  @override
  Widget build(BuildContext context) {
    final rateCard = _RateCard(stats: stats);
    final streakCard = _InfoCard(
      icon: Icons.local_fire_department,
      title: AppStrings.statsBestStreak,
      value: AppStrings.statsDays(stats.bestStreak),
      detail: stats.bestStreakHabit,
    );
    final consistentCard = _InfoCard(
      icon: Icons.emoji_events_outlined,
      title: AppStrings.statsMostConsistent,
      value: stats.mostConsistentHabit ?? AppStrings.statsNoData,
      detail: stats.mostConsistentHabit == null
          ? null
          : AppStrings.statsConsistentDetail(
              (stats.mostConsistentRate * 100).round(),
            ),
    );
 
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideBreakpoint;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: rateCard),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          streakCard,
                          const SizedBox(height: 16),
                          consistentCard,
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    rateCard,
                    const SizedBox(height: 16),
                    streakCard,
                    const SizedBox(height: 16),
                    consistentCard,
                  ],
                ),
        );
      },
    );
  }
}
 
class _RateCard extends StatelessWidget {
  const _RateCard({required this.stats});
 
  final WeeklyStats stats;
 
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (stats.completionRate * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              AppStrings.statsWeekRate,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: stats.completionRate,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text('$percent%', style: theme.textTheme.headlineMedium),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.statsDaysOf(stats.completed, stats.expected),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
 
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.detail,
  });
 
  final IconData icon;
  final String title;
  final String value;
  final String? detail;
 
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (detail != null)
                    Text(
                      detail!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _EmptyStats extends StatelessWidget {
  const _EmptyStats();
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          AppStrings.statsEmpty,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}