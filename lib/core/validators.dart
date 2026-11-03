import 'package:rachas/core/config/app_strings.dart';

/// Validadores de formularios
abstract final class Validators {
  static const int minPasswordLength = 6;

  static final RegExp _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$',
  );

  // login y crear cuenta ---

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppStrings.emailRequired;
    if (!_emailPattern.hasMatch(text)) return AppStrings.emailInvalid;
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return AppStrings.passwordRequired;
    if (text.length < minPasswordLength) return AppStrings.passwordTooShort;
    return null;
  }

  /// Validación cruzada: compara con el texto actual del campo contraseña.
  static String? confirmPassword(String? value, String password) {
    final text = value ?? '';
    if (text.isEmpty) return AppStrings.confirmPasswordRequired;
    if (text != password) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  static const int maxPersonNameLength = 50;
  static String? personName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppStrings.nameRequired;
    if (text.length < 2) return AppStrings.nameTooShort;
    if (text.length > maxPersonNameLength) return AppStrings.nameTooLong;
    return null;
  }
}
