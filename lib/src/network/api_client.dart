import 'package:dio/dio.dart';

import 'api_response.dart';

/// Thin abstraction over HTTP. Data sources depend on this interface, not on
/// Dio directly, so the transport can be swapped without touching the
/// domain/data code. `Core.init` registers a [DioApiClient] under this type.
///
/// Every method takes [requiresAuth] (default `true`): when `false`, the
/// bearer token is NOT attached and a 401 is treated as a per-request error
/// rather than a global session invalidation.
abstract class ApiClient {
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  });

  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  });

  Future<ApiResponse> postMultipart(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  });

  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  });

  Future<ApiResponse> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  });
}
