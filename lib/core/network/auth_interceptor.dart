import 'package:dio/dio.dart';
import 'package:rachas/features/login/auth_service.dart';
import 'package:rachas/features/login/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    required AuthService authService,
  }) : _dio = dio,
       _tokenStorage = tokenStorage,
       _authService = authService;

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final AuthService _authService;

  static const String _retriedKey = 'auth_retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readIdToken();
    if (token != null) {
      options.queryParameters['auth'] = token;
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = request.extra[_retriedKey] == true;

    if (!isUnauthorized || alreadyRetried) {
      handler.next(err);
      return;
    }

    try {
      final newToken = await _authService.refresh();
      request.extra[_retriedKey] = true;
      request.queryParameters['auth'] = newToken;
      final response = await _dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    } catch (_) {
      handler.next(err);
    }
  }
}
