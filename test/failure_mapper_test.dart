import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_core/my_core.dart';

/// The exception → Failure status table.
void main() {
  group('mapServerExceptionToFailure', () {
    test('401 → UnauthorizedFailure', () {
      expect(
        mapServerExceptionToFailure(
          const ServerException('error_unauthorized', statusCode: 401),
        ),
        isA<UnauthorizedFailure>(),
      );
    });

    test('403 → ForbiddenFailure carrying the reason', () {
      final f = mapServerExceptionToFailure(
        const ServerException('error_request_failed',
            statusCode: 403, serverMessage: 'account_disabled'),
      );
      expect(f, isA<ForbiddenFailure>());
      expect(f.message, 'account_disabled');
    });

    test('404 → NotFoundFailure', () {
      expect(
        mapServerExceptionToFailure(
          const ServerException('error_request_failed',
              statusCode: 404, serverMessage: 'tag_not_found'),
        ),
        isA<NotFoundFailure>(),
      );
    });

    test('409 → ConflictFailure', () {
      expect(
        mapServerExceptionToFailure(
          const ServerException('error_request_failed',
              statusCode: 409, serverMessage: 'duplicate_transaction'),
        ),
        isA<ConflictFailure>(),
      );
    });

    test('422 → ValidationFailure carrying the reason', () {
      final f = mapServerExceptionToFailure(
        const ServerException('error_request_failed',
            statusCode: 422, serverMessage: 'insufficient_funds'),
      );
      expect(f, isA<ValidationFailure>());
      expect(f.message, 'insufficient_funds');
    });

    test('timeout / no-internet (null status) → NetworkFailure', () {
      expect(mapServerExceptionToFailure(const ServerException('error_no_internet')),
          isA<NetworkFailure>());
      expect(mapServerExceptionToFailure(const ServerException('error_timeout')),
          isA<NetworkFailure>());
    });

    test('5xx → ServerFailure', () {
      expect(
        mapServerExceptionToFailure(
          const ServerException('error_server', statusCode: 503),
        ),
        isA<ServerFailure>(),
      );
    });

    test('non-ServerException → UnknownFailure', () {
      expect(mapServerExceptionToFailure(Exception('boom')), isA<UnknownFailure>());
    });
  });

  group('CoreConfig.apiPath', () {
    test('joins prefix + endpoint with a single slash', () {
      const cfg = CoreConfig(
        appName: 'T',
        prefix: 'api/v1',
        baseApiUrl: 'https://x',
        locales: [],
        lightColors: _Colors(),
        darkColors: _Colors(),
        endpoints: {'login': 'worker/login'},
      );
      expect(cfg.apiPath('login'), '/api/v1/worker/login');
    });

    test('tolerates stray slashes and an empty prefix', () {
      const cfg = CoreConfig(
        appName: 'T',
        prefix: '/api/v1/',
        baseApiUrl: 'https://x',
        locales: [],
        lightColors: _Colors(),
        darkColors: _Colors(),
        endpoints: {'a': '/worker/a', 'b': 'worker/b'},
      );
      expect(cfg.apiPath('a'), '/api/v1/worker/a');

      const bare = CoreConfig(
        appName: 'T',
        prefix: '',
        baseApiUrl: 'https://x',
        locales: [],
        lightColors: _Colors(),
        darkColors: _Colors(),
        endpoints: {'a': 'worker/a'},
      );
      expect(bare.apiPath('a'), '/worker/a');
    });
  });
}

/// Minimal AppColors stub for constructing a CoreConfig in tests.
class _Colors implements AppColors {
  const _Colors();
  @override
  noSuchMethod(Invocation invocation) => const Color(0xFF000000);
}
