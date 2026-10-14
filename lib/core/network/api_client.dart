import 'package:dio/dio.dart';
import 'package:rachas/core/config/firebase_config.dart';

class ApiClient {
  ApiClient({Dio? dio}) : dio = dio ?? _buildDio();

  static const Duration _timeout = Duration(seconds: 10);

  final Dio dio;

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: FirebaseConfig.dbUrl,
        connectTimeout: _timeout,
        sendTimeout: _timeout,
        receiveTimeout: _timeout,
      ),
    );
  }
}
