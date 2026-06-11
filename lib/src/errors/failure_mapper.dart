import 'exceptions.dart';
import 'failures.dart';

/// Maps a thrown [ServerException] (or any error) to a [Failure], in one place.
///
/// [DioApiClient] throws [ServerException] for any non-2xx, carrying the HTTP
/// [ServerException.statusCode] and the backend reason code in
/// [ServerException.serverMessage]; for timeouts / connectivity it throws with a
/// null status and an `error_*` [ServerException.message]. Apps fold the result
/// in their repositories. App-specific specialization (e.g. treating a 409 as a
/// domain "duplicate") can wrap or post-process this.
Failure mapServerExceptionToFailure(Object error) {
  if (error is! ServerException) {
    return const UnknownFailure('error_unknown');
  }

  final status = error.statusCode;
  // Prefer the backend reason code; fall back to the generic transport code.
  final reason = error.serverMessage ?? error.message;

  // No status => transport-level failure (timeout / no internet).
  if (status == null) {
    if (error.message == 'error_no_internet' || error.message == 'error_timeout') {
      return NetworkFailure(error.message);
    }
    return UnknownFailure(reason);
  }

  return switch (status) {
    401 => UnauthorizedFailure(reason),
    403 => ForbiddenFailure(reason),
    404 => NotFoundFailure(reason),
    409 => ConflictFailure(reason),
    422 => ValidationFailure(reason),
    >= 500 => ServerFailure(reason),
    _ => ServerFailure(reason),
  };
}
