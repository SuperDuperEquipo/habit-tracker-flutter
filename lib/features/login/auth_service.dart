import 'package:dio/dio.dart';
import 'package:rachas/core/config/api_endpoints.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/config/firebase_config.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/errors/error_handler.dart';
import 'package:rachas/core/network/logging_interceptor.dart';
import 'package:rachas/features/login/token_storage.dart';

/// Habla con Firebase Authentication: crear cuenta, iniciar sesión,
/// renovar el token y cerrar sesión.
class AuthService {
  AuthService({required TokenStorage tokenStorage, Dio? dio})
    : _tokenStorage = tokenStorage,
      _dio = dio ?? _buildDio();

  final TokenStorage _tokenStorage;

  // Dio propio, sin AuthInterceptor, para no entrar en un ciclo al renovar.
  final Dio _dio;

  static const Duration _timeout = Duration(seconds: 10);

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: _timeout,
        sendTimeout: _timeout,
        receiveTimeout: _timeout,
      ),
    );
    dio.interceptors.add(LoggingInterceptor());
    return dio;
  }

  Future<void> signIn(String email, String password) async {
    final data = await _authenticate(ApiEndpoints.signIn, email, password);
    // Firebase devuelve el nombre si la cuenta lo tiene.
    await _tokenStorage.saveDisplayName(data['displayName'] as String?);
  }

  Future<void> signUp(String email, String password, {String? name}) async {
    final data = await _authenticate(ApiEndpoints.signUp, email, password);
    final cleanName = name?.trim() ?? '';
    if (cleanName.isEmpty) return;

    await _tokenStorage.saveDisplayName(cleanName);
    await _updateDisplayName(data['idToken'] as String, cleanName);
  }

  Future<String?> readDisplayName() => _tokenStorage.readDisplayName();

  /// Pide un idToken nuevo con el refreshToken guardado y lo devuelve.
  Future<String> refresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) throw _sessionExpired();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        queryParameters: {'key': FirebaseConfig.apiKey},
        data: {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final data = _body(response);
      final idToken = data['id_token'] as String;
      await _tokenStorage.saveSession(
        idToken: idToken,
        refreshToken: data['refresh_token'] as String,
        uid: data['user_id'] as String,
      );
      return idToken;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400 || status == 401) {
        await _tokenStorage.clear();
        throw _sessionExpired();
      }
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<void> signOut() => _tokenStorage.clear();

  // signIn y signUp hacen lo mismo: cambia solo la URL.
  Future<Map<String, dynamic>> _authenticate(
    String url,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        queryParameters: {'key': FirebaseConfig.apiKey},
        data: {
          'email': email.trim(),
          'password': password,
          'returnSecureToken': true,
        },
      );
      final data = _body(response);
      await _tokenStorage.saveSession(
        idToken: data['idToken'] as String,
        refreshToken: data['refreshToken'] as String,
        uid: data['localId'] as String,
      );
      return data;
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  // Pone el nombre en el perfil de Firebase. Es de "mejor esfuerzo": la
  // cuenta ya existe y el nombre ya quedó guardado en el teléfono.
  Future<void> _updateDisplayName(String idToken, String name) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.updateProfile,
        queryParameters: {'key': FirebaseConfig.apiKey},
        data: {
          'idToken': idToken,
          'displayName': name,
          'returnSecureToken': false,
        },
      );
    } on DioException {
      // Se ignora a propósito: no vale la pena mostrar un error por esto.
    }
  }

  Map<String, dynamic> _body(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (data == null) throw const AppException(AppStrings.unexpectedError);
    return data;
  }

  AppException _sessionExpired() {
    return const AppException(
      AppStrings.sessionExpired,
      type: AppErrorType.sessionExpired,
      statusCode: 401,
    );
  }
}
