import 'package:flutter/material.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/theme/app_theme.dart';

/// Diálogos del catálogo de Stitch: tarjeta blanca, ícono y título a la
/// izquierda, y dos botones (cancelar y confirmar).
class AppDialogs {
  /// Devuelve `true` si el usuario confirma. Con [destructive] el botón de
  /// confirmar va en Rosa Oscuro (eliminar); si no, en navy (usar comodín).
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = AppStrings.cancel,
    IconData icon = Icons.help_outline,
    bool destructive = false,
  }) {
    final accent = destructive ? AppTheme.darkPink : AppTheme.navy;
    return showDialog<bool>(
      context: context,
      barrierColor: AppTheme.navy.withValues(alpha: 0.6),
      builder: (context) => _DialogCard(
        icon: icon,
        iconColor: accent,
        iconBackground: destructive ? AppTheme.palePink : AppTheme.skyBlue,
        title: title,
        message: message,
        cancelLabel: cancelLabel,
        onCancel: () => Navigator.of(context).pop(false),
        confirmLabel: confirmLabel,
        confirmColor: accent,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  static Future<void> showServerErrorDialog({
    required BuildContext context,
    required VoidCallback onRetry,
    String title = AppStrings.saveHabitErrorTitle,
    String message = AppStrings.saveHabitErrorBody,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: AppTheme.navy.withValues(alpha: 0.6),
      builder: (context) => _DialogCard(
        icon: Icons.warning_amber_rounded,
        iconColor: AppTheme.darkPink,
        iconBackground: AppTheme.palePink,
        title: title,
        message: message,
        cancelLabel: AppStrings.close,
        onCancel: () => Navigator.of(context).pop(),
        confirmLabel: AppStrings.retry,
        confirmColor: AppTheme.darkPink,
        onConfirm: () {
          Navigator.of(context).pop();
          onRetry();
        },
      ),
    );
  }
}

class _DialogCard extends StatelessWidget {
  const _DialogCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.onCancel,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final String cancelLabel;
  final VoidCallback onCancel;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppTheme.navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.slateBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppTheme.beige,
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: confirmColor,
                      minimumSize: const Size(64, 48),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
