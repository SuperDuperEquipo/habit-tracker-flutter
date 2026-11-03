import 'package:flutter/material.dart';
import 'package:rachas/core/theme/app_theme.dart';

/// Logo de Rachas: llama rosa sobre navy. Se usa en el login, en la
/// recuperación de contraseña y en los encabezados de las pantallas.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 32, this.circle = false});

  final double size;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.navy,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        Icons.local_fire_department_rounded,
        size: size * 0.6,
        color: AppTheme.azalea,
      ),
    );
  }
}

/// Título de las pantallas internas: logo pequeño y nombre de la pantalla,
/// alineados a la izquierda como en el diseño de Stitch.
class AppBarTitle extends StatelessWidget {
  const AppBarTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogo(size: 32),
        const SizedBox(width: 10),
        Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
