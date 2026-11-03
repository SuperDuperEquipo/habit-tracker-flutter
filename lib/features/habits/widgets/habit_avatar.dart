import 'package:flutter/material.dart';
import 'package:rachas/core/theme/app_theme.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/habit_icons.dart';

class HabitAvatar extends StatelessWidget {
  const HabitAvatar({super.key, required this.habit, this.size = 44});

  final Habit habit;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);
    final isDark =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.slateBlue.withValues(alpha: 0.25)),
      ),
      child: Icon(
        habitIcon(habit.iconKey),
        size: size / 2,
        color: isDark ? Colors.white : AppTheme.navy,
      ),
    );
  }
}
