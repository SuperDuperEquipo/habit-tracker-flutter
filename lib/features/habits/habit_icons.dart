import 'package:flutter/material.dart';

const Map<String, IconData> _habitIcons = {
  'menu_book': Icons.menu_book,
  'water_drop': Icons.water_drop,
  'headphones': Icons.headphones,
  'directions_bike': Icons.directions_bike,
  'directions_walk': Icons.directions_walk,
  'fitness_center': Icons.fitness_center,
  'self_improvement': Icons.self_improvement,
  'bedtime': Icons.bedtime,
  'restaurant': Icons.restaurant,
  'edit': Icons.edit,
  'music_note': Icons.music_note,
  'code': Icons.code,
};

IconData habitIcon(String key) =>
    _habitIcons[key] ?? Icons.local_fire_department;
