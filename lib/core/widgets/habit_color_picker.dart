import 'package:flutter/material.dart';

class HabitColorOption {
  final int colorValue;
  final String name;

  const HabitColorOption(this.colorValue, this.name);
}

class HabitColorPicker extends StatelessWidget {
  final int selectedColorValue;
  final ValueChanged<HabitColorOption> onSelected;

  static const List<HabitColorOption> options = [
    HabitColorOption(0xFF2F4058, 'Navy (#2F4058)'),
    HabitColorOption(0xFFC8D9E6, 'Sky Blue (#C8D9E6)'),
    HabitColorOption(0xFFFFE1E6, 'Pale Pink (#FFE1E6)'),
    HabitColorOption(0xFFF7C9D4, 'Azalea (#F7C9D4)'),
    HabitColorOption(0xFFF5EFEB, 'Beige (#F5EFEB)'),
    HabitColorOption(0xFFC45B78, 'Rosa oscuro (#C45B78)'),
    HabitColorOption(0xFF5F7F99, 'Azul grisáceo (#5F7F99)'),
    HabitColorOption(0xFF1B2636, 'Navy oscuro (#1B2636)'),
  ];

  const HabitColorPicker({
    super.key,
    required this.selectedColorValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedOption = options.firstWhere(
      (opt) => opt.colorValue == selectedColorValue,
      orElse: () => options.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tono de identidad',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              selectedOption.name,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 48,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = option.colorValue == selectedColorValue;
            final isDark =
                option.colorValue == 0xFF2F4058 ||
                option.colorValue == 0xFF1B2636 ||
                option.colorValue == 0xFFC45B78 ||
                option.colorValue == 0xFF5F7F99;

            return GestureDetector(
              onTap: () => onSelected(option),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(option.colorValue),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.primary.withOpacity(0.1),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: isDark ? Colors.white : colorScheme.primary,
                        size: 22,
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
}
