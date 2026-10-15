class Validators {
  static String? validateHabitName(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Escribe un nombre para tu hábito';
    }
    if (trimmed.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }
}
