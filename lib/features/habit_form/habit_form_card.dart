import 'package:flutter/material.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/theme/app_theme.dart';

/// Tarjeta blanca que envuelve el formulario de Crear y Editar (Stitch).
class HabitFormCard extends StatelessWidget {
  const HabitFormCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.navy.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withValues(alpha: 0.07),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Encabezado de la tarjeta: ícono en círculo, título y subtítulo.
class HabitFormHeader extends StatelessWidget {
  const HabitFormHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppTheme.skyBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.navy, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  color: AppTheme.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.slateBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta "Consejo de constancia".
class HabitTipCard extends StatelessWidget {
  const HabitTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.beige,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.skyBlue),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.spa_outlined, color: AppTheme.navy, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.habitTipTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.habitTipBody,
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

/// Botón principal (Guardar) con su estado de carga y el botón Cancelar.
class HabitFormActions extends StatelessWidget {
  const HabitFormActions({
    super.key,
    required this.label,
    required this.busyLabel,
    required this.busy,
    required this.onSave,
  });

  final String label;
  final String busyLabel;
  final bool busy;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: busy ? null : onSave,
          style: FilledButton.styleFrom(
            disabledBackgroundColor: AppTheme.navy.withValues(alpha: 0.7),
            disabledForegroundColor: Colors.white,
          ),
          icon: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.skyBlue,
                  ),
                )
              : const Icon(Icons.check_circle_outline),
          label: Text(busy ? busyLabel : label),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: AppTheme.slateBlue),
          child: const Text(AppStrings.cancel),
        ),
      ],
    );
  }
}
