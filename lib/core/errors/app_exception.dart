enum AppErrorType {
  noConnection,
  invalidData,
  sessionExpired,
  server,
  notFound,
  cancelled,
  unknown,
}

class AppException implements Exception {
  const AppException(
    this.message, {
    this.type = AppErrorType.unknown,
    this.statusCode,
  });

  final String message;
  final AppErrorType type;
  final int? statusCode;

  @override
  String toString() => message;
}
