import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/network/auth_interceptor.dart';
import 'package:rachas/features/login/auth_service.dart';
import 'package:rachas/features/login/token_storage.dart';

// Guarda el token en una variable en vez del almacenamiento seguro.
class FakeTokenStorage extends TokenStorage {
  FakeTokenStorage(this.token);

  String? token;

  @override
  Future<String?> readIdToken() async => token;
}

// refresh() devuelve 'nuevo' (o falla) y cuenta cuántas veces se llamó.
class FakeAuthService extends AuthService {
  FakeAuthService(this.storage, {this.fails = false})
    : super(tokenStorage: storage);

  final FakeTokenStorage storage;
  final bool fails;
  int refreshCalls = 0;

  @override
  Future<String> refresh() async {
    refreshCalls++;
    if (fails) {
      throw const AppException(
        'Sesión vencida',
        type: AppErrorType.sessionExpired,
      );
    }
    storage.token = 'nuevo';
    return 'nuevo';
  }
}

// Servidor falso: responde 200 solo si ?auth= trae el token válido.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter({this.validToken});

  final String? validToken; // null = siempre responde 401
  final List<Object?> authSent = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final auth = options.queryParameters['auth'];
    authSent.add(auth);
    final ok = validToken != null && auth == validToken;
    return ResponseBody.fromString(
      ok ? '{"ok":true}' : '{"error":"Permission denied"}',
      ok ? 200 : 401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _buildDio(
  FakeAdapter adapter,
  FakeTokenStorage storage,
  FakeAuthService auth,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://ejemplo.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    AuthInterceptor(dio: dio, tokenStorage: storage, authService: auth),
  );
  return dio;
}

void main() {
  test('agrega ?auth= con el token guardado', () async {
    final storage = FakeTokenStorage('valido');
    final auth = FakeAuthService(storage);
    final adapter = FakeAdapter(validToken: 'valido');
    final dio = _buildDio(adapter, storage, auth);

    final response = await dio.get<dynamic>('/habits.json');

    expect(response.statusCode, 200);
    expect(adapter.authSent, ['valido']);
    expect(auth.refreshCalls, 0);
  });

  test('con un 401 renueva el token y repite la petición', () async {
    final storage = FakeTokenStorage('viejo');
    final auth = FakeAuthService(storage);
    final adapter = FakeAdapter(validToken: 'nuevo');
    final dio = _buildDio(adapter, storage, auth);

    final response = await dio.get<dynamic>('/habits.json');

    expect(response.statusCode, 200);
    expect(adapter.authSent, ['viejo', 'nuevo']);
    expect(auth.refreshCalls, 1);
  });

  test('si no se puede renovar, deja pasar el 401', () async {
    final storage = FakeTokenStorage('viejo');
    final auth = FakeAuthService(storage, fails: true);
    final adapter = FakeAdapter(validToken: 'nuevo');
    final dio = _buildDio(adapter, storage, auth);

    await expectLater(
      dio.get<dynamic>('/habits.json'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
    expect(auth.refreshCalls, 1);
    expect(adapter.authSent, ['viejo']);
  });

  test('no reintenta más de una vez', () async {
    final storage = FakeTokenStorage('viejo');
    final auth = FakeAuthService(storage);
    final adapter = FakeAdapter(); // siempre 401
    final dio = _buildDio(adapter, storage, auth);

    await expectLater(
      dio.get<dynamic>('/habits.json'),
      throwsA(isA<DioException>()),
    );
    expect(auth.refreshCalls, 1);
    expect(adapter.authSent, ['viejo', 'nuevo']);
  });
}
