import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/features/login/auth_service.dart';
import 'package:rachas/features/login/login_screen.dart';
import 'package:rachas/features/login/token_storage.dart';

class _FakeAuthService extends AuthService {
  _FakeAuthService({this.onSignIn}) : super(tokenStorage: TokenStorage());

  final Future<void> Function()? onSignIn;

  @override
  Future<void> signIn(String email, String password) =>
      onSignIn?.call() ?? Future<void>.value();
}

Future<void> _pumpLogin(
  WidgetTester tester, {
  Future<void> Function()? onSignIn,
}) async {
  await tester.pumpWidget(
    Provider<AuthService>.value(
      value: _FakeAuthService(onSignIn: onSignIn),
      child: const MaterialApp(home: LoginScreen()),
    ),
  );
}

Future<void> _fillAndSubmit(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'clara@campus.edu');
  await tester.enterText(find.byType(TextFormField).at(1), '123456');
  await tester.tap(find.byType(FilledButton));
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('al volver de Crear cuenta cada error se queda en su campo', (
    tester,
  ) async {
    await _pumpLogin(tester);

    // Crear cuenta con todo vacío: aparecen los cuatro errores.
    await _tapText(tester, AppStrings.createAccount);
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.nameRequired), findsOneWidget);
    expect(find.text(AppStrings.emailRequired), findsOneWidget);

    // De regreso a Iniciar sesión, el campo Nombre ya no está y su error
    // no debe pasar al correo.
    await _tapText(tester, AppStrings.signIn);
    expect(find.text(AppStrings.nameRequired), findsNothing);
    expect(find.text(AppStrings.emailRequired), findsOneWidget);
    expect(find.text(AppStrings.passwordRequired), findsOneWidget);
  });

  testWidgets('Iniciar sesión muestra el enlace de recuperar contraseña', (
    tester,
  ) async {
    await _pumpLogin(tester);

    expect(find.text(AppStrings.forgotPassword), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('mientras inicia sesión muestra el texto de carga y bloquea '
      'los campos', (tester) async {
    final pending = Completer<void>();
    await _pumpLogin(tester, onSignIn: () => pending.future);

    await _fillAndSubmit(tester);
    await tester.pump();

    expect(find.text(AppStrings.signingIn), findsOneWidget);
    final email = tester.widget<TextFormField>(
      find.byType(TextFormField).at(0),
    );
    expect(email.enabled, isFalse);

    pending.completeError(const AppException(AppStrings.wrongCredentials));
    await tester.pump();
  });

  testWidgets('con credenciales incorrectas muestra el aviso e '
      '"Intentar de nuevo"', (tester) async {
    await _pumpLogin(
      tester,
      onSignIn: () =>
          Future<void>.error(const AppException(AppStrings.wrongCredentials)),
    );

    await _fillAndSubmit(tester);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.wrongCredentials), findsOneWidget);
    expect(find.text(AppStrings.tryAgain), findsOneWidget);
  });
}
