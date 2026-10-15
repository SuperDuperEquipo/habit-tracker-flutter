import 'package:flutter/material.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_icons.dart';
import 'package:rachas/features/habits/streak_logic.dart';
import 'package:rachas/core/theme/app_theme.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.today,
    required this.onToggle,
    required this.onUseJoker,
    required this.onOpen,
  });

  final Habit habit;
  final DateTime today;
  final VoidCallback onToggle;
  final VoidCallback onUseJoker;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final completed = isCompletedOn(habit, today);
    final showJoker = !completed && canUseJoker(habit, today);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: completed
              ? AppTheme.azalea.withValues(alpha: 0.45)
              : AppTheme.skyBlue.withValues(alpha: 0.35),
          border: Border.all(
            color: completed
                ? AppTheme.azalea
                : AppTheme.skyBlue.withValues(alpha: 0.7),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _HabitIcon(habit: habit),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _CheckButton(
                  completed: completed,
                  label: completed
                      ? AppStrings.unmarkHabit(habit.name)
                      : AppStrings.markHabit(habit.name),
                  onPressed: onToggle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _StreakChip(days: currentStreak(habit, today)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _JokerDots(left: habit.jokersLeft),
                    if (showJoker) ...[
                      const SizedBox(width: 8),
                      _JokerButton(onPressed: onUseJoker),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitIcon extends StatelessWidget {
  const _HabitIcon({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);
    final isDark = ThemeData.estimateBrightnessForColor(color) == Brightness.dark;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.slateBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Icon(
        habitIcon(habit.iconKey),
        size: 22,
        color: isDark ? Colors.white : AppTheme.navy,
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.azalea,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 16,
            color: AppTheme.darkPink,
          ),
          const SizedBox(width: 6),
          Text(
            AppStrings.streakDays(days),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _JokerDots extends StatelessWidget {
  const _JokerDots({required this.left});

  final int left;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.jokersLabel,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppTheme.slateBlue),
        ),
        const SizedBox(width: 6),
        for (var i = 0; i < Habit.maxJokers; i++)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < left
                  ? AppTheme.azalea
                  : AppTheme.slateBlue.withValues(alpha: 0.4),
            ),
          ),
      ],
    );
  }
}

class _JokerButton extends StatelessWidget {
  const _JokerButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.shield, size: 16, color: AppTheme.darkPink),
      label: const Text(AppStrings.useJoker),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navy,
        side: BorderSide(color: AppTheme.skyBlue.withValues(alpha: 0.7)),
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Botón circular de marcar/desmarcar. Al completar, el check aparece con un
/// pequeño rebote y un destello rosa que se expande y se desvanece.
class _CheckButton extends StatefulWidget {
  const _CheckButton({
    required this.completed,
    required this.label,
    required this.onPressed,
  });

  final bool completed;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_CheckButton> createState() => _CheckButtonState();
}

class _CheckButtonState extends State<_CheckButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void didUpdateWidget(_CheckButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.completed && widget.completed) {
      _glow.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: AnimatedBuilder(
            animation: _glow,
            builder: (context, child) {
              final t = _glow.value;
              return DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (_glow.isAnimating)
                      BoxShadow(
                        color: AppTheme.azalea.withValues(
                          alpha: 0.7 * (1 - t),
                        ),
                        spreadRadius: 12 * t,
                      ),
                  ],
                ),
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.completed ? AppTheme.navy : Colors.white,
                border: widget.completed
                    ? null
                    : Border.all(
                        color: AppTheme.skyBlue.withValues(alpha: 0.5),
                      ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.elasticOut,
                  ),
                  child: child,
                ),
                child: Icon(
                  widget.completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  key: ValueKey(widget.completed),
                  size: 24,
                  color: widget.completed
                      ? AppTheme.azalea
                      : AppTheme.slateBlue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}