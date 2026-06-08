import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';
import 'api_response.dart';

/// Dio-backed [ApiClient]. Built by `Core.init` from `CoreConfig` (base URL +
/// timeouts) and a [TokenStorage]; can also be constructed directly in tests
/// by injecting a [Dio].
///
/// Pure Dart — no Flutter. Set [enableLogging] for request/response logs (the
/// host app can pass its own debug flag, e.g. `kDebugMode`).
class DioApiClient implements ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  /// Fired whenever the server returns 401 to a request that carried a token
  /// (`requiresAuth != false`). Wire it to your global sign-out so a stale or
  /// revoked token forces a session reset instead of every caller having to
  /// special-case `UnauthorizedFailure`.
  final void Function()? _onUnauthorized;

  DioApiClient({
    required TokenStorage tokenStorage,
    String baseUrl = '',
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Dio? dio,
    bool enableLogging = false,
    void Function()? onUnauthorized,
  }) : _tokenStorage = tokenStorage,
       _onUnauthorized = onUnauthorized,
       _dio =
           dio ??
           _buildDio(
             baseUrl: baseUrl,
             connectTimeout: connectTimeout,
             receiveTimeout: receiveTimeout,
           ) {
    _dio.interceptors.add(_authInterceptor());
    if (enableLogging) _dio.interceptors.add(_loggingInterceptor());
  }

  static Dio _buildDio({
    required String baseUrl,
    required Duration connectTimeout,
    required Duration receiveTimeout,
  }) => Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // ---- Interceptors ------------------------------------------------

  Interceptor _authInterceptor() => InterceptorsWrapper(
    onRequest: (options, handler) async {
      if (options.extra['requiresAuth'] != false) {
        final token = await _tokenStorage.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
      handler.next(options);
    },
  );

  Interceptor _loggingInterceptor() => InterceptorsWrapper(
    onRequest: (o, h) {
      developer.log('🚀 ${o.method} ${o.uri}', name: 'flutter_core.net');
      if (o.data != null) {
        developer.log('📤 ${o.data}', name: 'flutter_core.net');
      }
      h.next(o);
    },
    onResponse: (r, h) {
      developer.log(
        '✅ ${r.statusCode} ${r.requestOptions.uri}',
        name: 'flutter_core.net',
      );
      h.next(r);
    },
    onError: (e, h) {
      developer.log(
        '❌ ${e.type} ${e.requestOptions.method} ${e.requestOptions.uri}'
        ' | message=${e.message} | error=${e.error}',
        name: 'flutter_core.net',
      );
      h.next(e);
    },
  );

  // ---- Public API --------------------------------------------------

  @override
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) => _send(
    () => _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(extra: {'requiresAuth': requiresAuth}),
    ),
  );

  @override
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) => _send(
    () => _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(extra: {'requiresAuth': requiresAuth}),
    ),
  );

  @override
  Future<ApiResponse> postMultipart(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) => _send(
    () => _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(extra: {'requiresAuth': requiresAuth}),
    ),
  );

  @override
  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) => _send(
    () => _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(extra: {'requiresAuth': requiresAuth}),
    ),
  );

  @override
  Future<ApiResponse> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) => _send(
    () => _dio.delete(
      path,
      queryParameters: queryParameters,
      options: Options(extra: {'requiresAuth': requiresAuth}),
    ),
  );

  // ---- Core --------------------------------------------------------

  Future<ApiResponse> _send(Future<Response<dynamic>> Function() call) async {
    try {
      final r = await call();
      final body = (r.data is Map<String, dynamic>)
          ? r.data as Map<String, dynamic>
          : <String, dynamic>{};

      return ApiResponse(
        success: body['success'] == true,
        message: body['message']?.toString(),
        data: body['data'] ?? body,
        statusCode: r.statusCode ?? 0,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw ServerException('error_unknown', cause: e);
    }
  }

  ServerException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerException('error_timeout');
      case DioExceptionType.connectionError:
        return const ServerException('error_no_internet');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        final body = e.response?.data;
        final serverMsg = (body is Map<String, dynamic>)
            ? body['message']?.toString()
            : null;
        if (code == 401) {
          // Only forward to the global handler when the request actually
          // carried a token. A 401 on a `requiresAuth: false` call (login
          // with bad credentials, OTP verify, …) is a per-form error, not
          // a session invalidation.
          final requiresAuth = e.requestOptions.extra['requiresAuth'] != false;
          if (requiresAuth) _onUnauthorized?.call();
          return ServerException(
            'error_unauthorized',
            statusCode: code,
            serverMessage: serverMsg,
          );
        }
        if (code >= 500) {
          return ServerException(
            'error_server',
            statusCode: code,
            serverMessage: serverMsg,
          );
        }
        return ServerException(
          'error_request_failed',
          statusCode: code,
          serverMessage: serverMsg,
        );
      default:
        return const ServerException('error_unknown');
    }
  }
}
