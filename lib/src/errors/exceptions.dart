class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error']);
}

class ServerException implements Exception {
  final String message; // e.g. 'error_timeout' — UI translates
  final int? statusCode;
  final String? serverMessage;
  final Object? cause;
  const ServerException(
    this.message, {
    this.statusCode,
    this.serverMessage,
    this.cause,
  });
}
