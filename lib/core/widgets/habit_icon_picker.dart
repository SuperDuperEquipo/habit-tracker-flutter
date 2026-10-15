import 'package:flutter/material.dart';

class HabitIconOption {
  final String key;
  final String label;
  final IconData icon;

  const HabitIconOption(this.key, this.label, this.icon);
}

class HabitIconPicker extends StatelessWidget {
  final String selectedKey;
  final ValueChanged<HabitIconOption> onSelected;

  static const List<HabitIconOption> options = [
    HabitIconOption('menu_book', 'Libro', Icons.menu_book),
    HabitIconOption('coffee', 'Café', Icons.coffee),
    HabitIconOption('water_drop', 'Agua', Icons.water_drop),
    HabitIconOption('bedtime', 'Descanso', Icons.bedtime),
    HabitIconOption('fitness_center', 'Deporte', Icons.fitness_center),
    HabitIconOption('nutrition', 'Nutrición', Icons.apple),
    HabitIconOption('draw', 'Lápiz', Icons.draw),
    HabitIconOption('headphones', 'Música', Icons.headphones),
    HabitIconOption('self_improvement', 'Meditación', Icons.self_improvement),
    HabitIconOption('directions_bike', 'Bicicleta', Icons.directions_bike),
    HabitIconOption('lightbulb', 'Ideas', Icons.lightbulb),
    HabitIconOption('potted_plant', 'Crecimiento', Icons.local_florist),
  ];

  const HabitIconPicker({
    super.key,
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedOption = options.firstWhere(
      (opt) => opt.key == selectedKey,
      orElse: () => options.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Elige un ícono de acompañamiento',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              selectedOption.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
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
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 48,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = option.key == selectedKey;

            return InkWell(
              onTap: () => onSelected(option),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.secondary
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Icon(
                  option.icon,
                  color: isSelected
                      ? colorScheme.onSecondary
                      : colorScheme.secondary,
                  size: 24,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
