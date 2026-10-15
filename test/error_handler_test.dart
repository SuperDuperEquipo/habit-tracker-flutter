import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/errors/error_handler.dart';

// Fabrica una DioException falsa para probar.
DioException _error(DioExceptionType type, {int? status, dynamic data}) {
  final request = RequestOptions(path: '/x');
  return DioException(
    requestOptions: request,
    type: type,
    response: status == null
        ? null
        : Response(requestOptions: request, statusCode: status, data: data),
  );
}

// Arma el cuerpo que manda Firebase en un 400.
Map<String, dynamic> _firebaseBody(String message) => {
  'error': {'code': 400, 'message': message},
};

void main() {
  group('errores de red', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.transformTimeout,
      DioExceptionType.connectionError,
    ]) {
      test('$type da Sin conexión', () {
        final result = ErrorHandler.fromDio(_error(type));
        expect(result.message, AppStrings.noConnection);
        expect(result.type, AppErrorType.noConnection);
      });
    }
  });

  group('400 con mensajes de Firebase', () {
    final casos = {
      'EMAIL_EXISTS': AppStrings.emailExists,
      'INVALID_LOGIN_CREDENTIALS': AppStrings.wrongCredentials,
      'EMAIL_NOT_FOUND': AppStrings.wrongCredentials,
      'INVALID_PASSWORD': AppStrings.wrongCredentials,
      'WEAK_PASSWORD': AppStrings.passwordTooShort,
      'INVALID_EMAIL': AppStrings.emailInvalid,
      'TOO_MANY_ATTEMPTS_TRY_LATER': AppStrings.tooManyAttempts,
    };

    casos.forEach((codigo, esperado) {
      test('$codigo da su mensaje', () {
        final result = ErrorHandler.fromDio(
          _error(
            DioExceptionType.badResponse,
            status: 400,
            data: _firebaseBody(codigo),
          ),
        );
        expect(result.message, esperado);
        expect(result.type, AppErrorType.invalidData);
      });
    });

    test('WEAK_PASSWORD con texto extra también funciona', () {
      final result = ErrorHandler.fromDio(
        _error(
          DioExceptionType.badResponse,
          status: 400,
          data: _firebaseBody('WEAK_PASSWORD : Password should be at least 6'),
        ),
      );
      expect(result.message, AppStrings.passwordTooShort);
    });

    test('un código desconocido da dato inválido', () {
      final result = ErrorHandler.fromDio(
        _error(
          DioExceptionType.badResponse,
          status: 400,
          data: _firebaseBody('ALGO_NUEVO'),
        ),
      );
      expect(result.message, AppStrings.invalidData);
    });

    test('un 400 sin cuerpo no truena', () {
      final result = ErrorHandler.fromDio(
        _error(DioExceptionType.badResponse, status: 400),
      );
      expect(result.message, AppStrings.invalidData);
    });
  });

  group('otros códigos', () {
    test('401 da sesión vencida', () {
      final result = ErrorHandler.fromDio(
        _error(DioExceptionType.badResponse, status: 401),
      );
      expect(result.message, AppStrings.sessionExpired);
      expect(result.type, AppErrorType.sessionExpired);
    });

    test('500 da error del servidor', () {
      final result = ErrorHandler.fromDio(
        _error(DioExceptionType.badResponse, status: 500),
      );
      expect(result.message, AppStrings.serverError);
      expect(result.type, AppErrorType.server);
    });

    test('cancel da cancelado', () {
      final result = ErrorHandler.fromDio(_error(DioExceptionType.cancel));
      expect(result.message, AppStrings.cancelled);
      expect(result.type, AppErrorType.cancelled);
    });

    test('unknown da error inesperado', () {
      final result = ErrorHandler.fromDio(_error(DioExceptionType.unknown));
      expect(result.message, AppStrings.unexpectedError);
    });
  });
}
