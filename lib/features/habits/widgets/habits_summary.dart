import 'package:flutter/material.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/theme/theme_data.dart';

class HabitsSummary extends StatelessWidget {
  const HabitsSummary({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  double get _progress => total == 0 ? 0 : completed / total;

  String get _message {
    if (completed == 0) return AppStrings.summaryNoProgress;
    if (completed >= total) return AppStrings.summaryAllDone;
    return AppStrings.summaryInProgress;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = AppTheme.slateBlue; 

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.skyBlue.withValues(alpha: 0.3),
        border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: _progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, _) => SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 3.5,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppTheme.skyBlue,
                      color: AppTheme.navy,
                    ),
                  ),
                  Text(
                    '${(_progress * 100).round()}%',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppTheme.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.completedOf(completed, total),
                  style: textTheme.labelLarge?.copyWith(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _message,
                  style: textTheme.bodySmall?.copyWith(color: secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}