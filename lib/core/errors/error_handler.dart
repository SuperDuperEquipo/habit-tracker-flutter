import 'package:dio/dio.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';

abstract final class ErrorHandler {
  // recibe el error de Dio y devuelve un AppException.
  static AppException fromDio(DioException e) {
    switch (e.type) {
      // Sin internet o servidor que no responde a tiempo.
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const AppException(
          AppStrings.noConnection,
          type: AppErrorType.noConnection,
        );
      // El servidor sí respondió, pero con un código de error (400, 401, 500...).
      case DioExceptionType.badResponse:
        return _fromResponse(e);
      // La petición se canceló a propósito.
      case DioExceptionType.cancel:
        return const AppException(
          AppStrings.cancelled,
          type: AppErrorType.cancelled,
        );
      // Cualquier otra cosa rara.
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return AppException(
          AppStrings.unexpectedError,
          statusCode: e.response?.statusCode,
        );
    }
  }

  // Decide por el código HTTP: 400, 401, 5xx u otro.
  static AppException _fromResponse(DioException e) {
    final status = e.response?.statusCode;

    if (status == 400) return _badRequest(e);

    if (status == 401) {
      return const AppException(
        AppStrings.sessionExpired,
        type: AppErrorType.sessionExpired,
        statusCode: 401,
      );
    }

    if (status != null && status >= 500) {
      return AppException(
        AppStrings.serverError,
        type: AppErrorType.server,
        statusCode: status,
      );
    }

    return AppException(AppStrings.unexpectedError, statusCode: status);
  }

  // Para un 400, mira el mensaje que manda Firebase y elige el texto.
  static AppException _badRequest(DioException e) {
    final message = switch (_firebaseCode(e.response?.data)) {
      'EMAIL_EXISTS' => AppStrings.emailExists,
      'INVALID_LOGIN_CREDENTIALS' ||
      'EMAIL_NOT_FOUND' ||
      'INVALID_PASSWORD' => AppStrings.wrongCredentials,
      'WEAK_PASSWORD' => AppStrings.passwordTooShort,
      'INVALID_EMAIL' => AppStrings.emailInvalid,
      'TOO_MANY_ATTEMPTS_TRY_LATER' => AppStrings.tooManyAttempts,
      _ => AppStrings.invalidData,
    };
    return AppException(
      message,
      type: AppErrorType.invalidData,
      statusCode: 400,
    );
  }

  // Firebase manda un error
  static String? _firebaseCode(dynamic data) {
    if (data is Map) {
      final error = data['error'];
      if (error is Map && error['message'] is String) {
        return (error['message'] as String).split(' : ').first.trim();
      }
    }
    return null;
  }
}
