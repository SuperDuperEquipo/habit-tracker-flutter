import 'package:flutter/material.dart';
import 'package:rachas/core/widgets/habit_icon_picker.dart';


IconData habitIcon(String key) {
  for (final option in HabitIconPicker.options) {
    if (option.key == key) return option.icon;
  }
  return Icons.local_fire_department;
}