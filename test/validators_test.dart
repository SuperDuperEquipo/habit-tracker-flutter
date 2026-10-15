import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/validators.dart';

void main() {
  group('Validators.email', () {
    test('acepta correos válidos', () {
      expect(Validators.email('tiffany@correo.com'), isNull);
      expect(Validators.email('  a.b+c@mail.esen.edu.sv  '), isNull);
    });

    test('rechaza vacío o nulo', () {
      expect(Validators.email(null), AppStrings.emailRequired);
      expect(Validators.email('   '), AppStrings.emailRequired);
    });

    test('rechaza formatos inválidos', () {
      for (final value in [
        'hola',
        'a@b',
        '@correo.com',
        'a@correo.',
        'a b@c.com',
      ]) {
        expect(Validators.email(value), AppStrings.emailInvalid, reason: value);
      }
    });
  });

  group('Validators.password', () {
    test('acepta 6 caracteres o más', () {
      expect(Validators.password('123456'), isNull);
    });

    test('rechaza vacío o nulo', () {
      expect(Validators.password(null), AppStrings.passwordRequired);
      expect(Validators.password(''), AppStrings.passwordRequired);
    });

    test('rechaza menos de 6 caracteres', () {
      expect(Validators.password('12345'), AppStrings.passwordTooShort);
    });
  });

  group('Validators.confirmPassword', () {
    test('acepta contraseñas iguales', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });

    test('rechaza vacío', () {
      expect(
        Validators.confirmPassword('', 'abc123'),
        AppStrings.confirmPasswordRequired,
      );
    });

    test('rechaza contraseñas distintas', () {
      expect(
        Validators.confirmPassword('abc124', 'abc123'),
        AppStrings.passwordsDoNotMatch,
      );
    });
  });
  group('Validators.personName', () {
    test('acepta nombres válidos', () {
      expect(Validators.personName('Ana'), isNull);
      expect(Validators.personName('  Tiffany Meléndez  '), isNull);
    });

    test('rechaza vacío o nulo', () {
      expect(Validators.personName(null), AppStrings.nameRequired);
      expect(Validators.personName('   '), AppStrings.nameRequired);
    });

    test('rechaza un solo carácter', () {
      expect(Validators.personName('A'), AppStrings.nameTooShort);
    });

    test('rechaza más de 50 caracteres', () {
      expect(Validators.personName('a' * 51), AppStrings.nameTooLong);
    });
  });
}
