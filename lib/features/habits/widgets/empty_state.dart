import 'package:flutter/material.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/theme/app_theme.dart';
import 'package:rachas/core/widgets/primary_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.palePink,
        border: Border.all(color: AppTheme.azalea.withValues(alpha: 0.8)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  right: 4,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.azalea.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.8),
                    border: Border.all(
                      color: AppTheme.skyBlue.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 40,
                    color: AppTheme.darkPink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.emptyTitle,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: AppTheme.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.emptyBody,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppTheme.slateBlue),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: AppStrings.createFirstHabit,
            icon: Icons.add,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}
