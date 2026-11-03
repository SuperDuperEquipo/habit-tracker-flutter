import 'package:dio/dio.dart';
import 'package:rachas/core/config/firebase_config.dart';
import 'package:rachas/core/network/auth_interceptor.dart';
import 'package:rachas/core/network/logging_interceptor.dart';
import 'package:rachas/features/login/auth_service.dart';
import 'package:rachas/features/login/token_storage.dart';

class ApiClient {
  ApiClient({Dio? dio, TokenStorage? tokenStorage, AuthService? authService})
    : dio = dio ?? _buildDio(tokenStorage, authService);

  static const Duration _timeout = Duration(seconds: 10);

  final Dio dio;

  static Dio _buildDio(TokenStorage? tokenStorage, AuthService? authService) {
    final dio = Dio(
      BaseOptions(
        baseUrl: FirebaseConfig.dbUrl,
        connectTimeout: _timeout,
        sendTimeout: _timeout,
        receiveTimeout: _timeout,
        contentType: Headers.jsonContentType,
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(LoggingInterceptor());
    if (tokenStorage != null && authService != null) {
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          tokenStorage: tokenStorage,
          authService: authService,
        ),
      );
    }
    return dio;
  }
}
