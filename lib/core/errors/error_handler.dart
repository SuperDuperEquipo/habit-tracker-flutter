import 'package:dio/dio.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';

abstract final class ErrorHandler {
  // Stub: la Persona 2 lo reemplaza con el mapeo por tipo de DioException.
  static AppException fromDio(DioException e) {
    return AppException(
      AppStrings.unexpectedError,
      statusCode: e.response?.statusCode,
    );
  }
}
