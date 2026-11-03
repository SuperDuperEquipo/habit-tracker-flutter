import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/features/login/auth_service.dart';
import 'package:rachas/features/login/forgot_password_screen.dart';
import 'package:rachas/features/login/token_storage.dart';

class _FakeAuthService extends AuthService {
  _FakeAuthService({this.error}) : super(tokenStorage: TokenStorage());

  final AppException? error;
  final List<String> sentEmails = [];

  @override
  Future<void> sendPasswordReset(String email) async {
    sentEmails.add(email);
    if (error != null) throw error!;
  }
}

Widget _buildScreen(AuthService auth) {
  return Provider<AuthService>.value(
    value: auth,
    child: const MaterialApp(home: ForgotPasswordScreen()),
  );
}

Future<void> _enterEmailAndSubmit(WidgetTester tester, String email) async {
  await tester.enterText(find.byType(TextFormField), email);
  await tester.ensureVisible(find.byType(FilledButton));
  await tester.tap(find.byType(FilledButton));
}

void main() {
  testWidgets('con un correo inválido no envía nada', (tester) async {
    final auth = _FakeAuthService();
    await tester.pumpWidget(_buildScreen(auth));

    await _enterEmailAndSubmit(tester, 'correo-invalido');
    await tester.pump();

    expect(auth.sentEmails, isEmpty);
    expect(find.text(AppStrings.emailInvalid), findsOneWidget);
    expect(find.text(AppStrings.resetEmailSentTitle), findsNothing);
  });

  testWidgets('con un correo válido envía una vez y muestra el éxito', (
    tester,
  ) async {
    final auth = _FakeAuthService();
    await tester.pumpWidget(_buildScreen(auth));

    await _enterEmailAndSubmit(tester, 'tiffany@correo.com');
    await tester.pumpAndSettle();

    expect(auth.sentEmails, ['tiffany@correo.com']);
    expect(find.text(AppStrings.resetEmailSentTitle), findsOneWidget);
  });

  testWidgets('si falla el envío muestra el error y no el éxito', (
    tester,
  ) async {
    final auth = _FakeAuthService(
      error: const AppException(
        AppStrings.emailNotRegistered,
        type: AppErrorType.invalidData,
        statusCode: 400,
      ),
    );
    await tester.pumpWidget(_buildScreen(auth));

    await _enterEmailAndSubmit(tester, 'nadie@correo.com');
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.emailNotRegistered), findsOneWidget);
    expect(find.text(AppStrings.resetEmailSentTitle), findsNothing);
  });
}
