import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda la sesión de forma cifrada.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _idTokenKey = 'id_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _uidKey = 'uid';

  /// Guarda los tres datos de una sola vez al iniciar sesión.
  Future<void> saveSession({
    required String idToken,
    required String refreshToken,
    required String uid,
  }) async {
    await _storage.write(key: _idTokenKey, value: idToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _uidKey, value: uid);
  }

  Future<String?> readIdToken() => _storage.read(key: _idTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<String?> readUid() => _storage.read(key: _uidKey);

  /// Hay sesión si existen el refreshToken y el uid.
  Future<bool> hasSession() async {
    final refreshToken = await readRefreshToken();
    final uid = await readUid();
    return refreshToken != null && uid != null;
  }

  /// Cerrar sesión: borra los tres datos.
  Future<void> clear() async {
    await _storage.delete(key: _idTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _uidKey);
  }
}
