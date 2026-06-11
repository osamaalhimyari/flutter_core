import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

/// 403 — authenticated but not permitted (disabled account, wrong role, a
/// broken account chain). [message] carries the backend reason code.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message);
}

/// 404 — the resource does not exist.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// 409 — a conflict / idempotent-replay (e.g. a duplicate submission).
class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}

/// 422 — well-formed but rejected by a business rule or field validation.
/// [errors] holds optional field→messages when the backend returns a bag
/// (often unavailable; the Dio client only forwards the top-level message).
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure(super.message, {this.errors});

  @override
  List<Object?> get props => [message, errors];
}

/// Timeouts / no connectivity — a retry is meaningful.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'error_no_internet']);
}
