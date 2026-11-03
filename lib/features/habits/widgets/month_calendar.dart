import 'package:flutter/material.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/theme/app_theme.dart';
import 'package:rachas/core/utils/date_helpers.dart';
import 'package:rachas/features/habits/calendar_logic.dart';

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.completedDates,
    required this.today,
  });

  final DateTime month;
  final List<DateTime> completedDates;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completedDays = completedDaysOfMonth(completedDates, month);
    final cells = monthCells(month);
    final todayOnly = dateOnly(today);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.monthTitle(month),
                style: textTheme.titleMedium?.copyWith(
                  color: AppTheme.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.completedCount(completedDays.length),
              style: textTheme.labelMedium?.copyWith(
                color: AppTheme.slateBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: AppStrings.weekdayInitials
              .map(
                (letter) => Expanded(
                  child: Center(
                    child: Text(
                      letter,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppTheme.slateBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: cells.length,
          itemBuilder: (context, index) {
            final day = cells[index];
            if (day == null) return const SizedBox.shrink();

            final completed = completedDays.contains(day);
            return _DayCell(
              key: ValueKey(completed ? 'done-$day' : 'day-$day'),
              day: day,
              completed: completed,
              isToday: DateTime(month.year, month.month, day) == todayOnly,
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    super.key,
    required this.day,
    required this.completed,
    required this.isToday,
  });

  final int day;
  final bool completed;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.calendarDay(day, completed: completed),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isToday ? AppTheme.slateBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed ? AppTheme.navy : null,
          ),

          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$day',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: completed ? Colors.white : AppTheme.navy,
                fontWeight: completed || isToday
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
