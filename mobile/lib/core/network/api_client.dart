import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({Dio? dio, TokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? const TokenStorage(),
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiEndpoints.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'Content-Type': 'application/json'},
            ),
          ) {
    _dio.interceptors.add(const _MicroserviceRoutingInterceptor());
    _dio.interceptors.add(_AuthInterceptor(_tokenStorage));
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
      );
      return _asJsonMap(response.data);
    } on DioException catch (error) {
      throw await _toApiException(error);
    }
  }

  Future<Map<String, dynamic>> postJson(String path, {Object? data}) async {
    try {
      final response = await _dio.post<Object?>(path, data: data);
      return _asJsonMap(response.data);
    } on DioException catch (error) {
      throw await _toApiException(error);
    }
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _asJsonMap(response.data);
    } on DioException catch (error) {
      throw await _toApiException(error);
    }
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _asJsonMap(response.data);
    } on DioException catch (error) {
      throw await _toApiException(error);
    }
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _asJsonMap(response.data);
    } on DioException catch (error) {
      throw await _toApiException(error);
    }
  }

  /// Called by the GoRouter redirect to eagerly set the token.
  /// The [_AuthInterceptor] also attaches it automatically as a fallback.
  void setBearerToken(String? token) {
    final headers = _dio.options.headers;
    if (token == null || token.isEmpty) {
      headers.remove('Authorization');
      return;
    }
    headers['Authorization'] = 'Bearer $token';
  }

  Map<String, dynamic> _asJsonMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{'data': data};
  }

  Future<ApiException> _toApiException(DioException error) async {
    final response = error.response;
    final data = response?.data;
    final isPublicAuthRequest = ApiEndpoints.isPublicAuthPath(
      error.requestOptions.path,
    );
    String message = 'Không thể kết nối máy chủ. Vui lòng thử lại.';

    if (response?.statusCode == 401 && !isPublicAuthRequest) {
      await _tokenStorage.clear();
      setBearerToken(null);
      message = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }

    if (data is Map) {
      final rawMessage =
          data['message'] ??
          data['error'] ??
          data['detail'] ??
          data['path'] ??
          data['data'];
      if (rawMessage != null && response?.statusCode != 401) {
        message = rawMessage.toString();
      }
    } else if (data is String &&
        data.trim().isNotEmpty &&
        response?.statusCode != 401) {
      message = data.trim();
    } else if (response?.statusCode == 403) {
      message = 'Bạn không có quyền truy cập chức năng này.';
    }

    return ApiException(message, statusCode: response?.statusCode);
  }
}

class _MicroserviceRoutingInterceptor extends Interceptor {
  const _MicroserviceRoutingInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.baseUrl = ApiEndpoints.resolveBaseUrl(options.path);
    handler.next(options);
  }
}

/// Dio Interceptor that automatically reads the access token from
/// secure storage and attaches it to the Authorization header for
/// every outgoing request. This is the fallback for cases where
/// [ApiClient.setBearerToken] has not been called yet (e.g. deep links
/// or hot-reloads that skip the GoRouter redirect).
class _AuthInterceptor extends Interceptor {
  const _AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Do not let an expired stored token block permitAll auth endpoints.
    // Spring validates any supplied bearer token before authorization rules.
    if (ApiEndpoints.isPublicAuthPath(options.path)) {
      options.headers.remove('Authorization');
      handler.next(options);
      return;
    }

    // If the Authorization header is already set (via setBearerToken), keep it.
    if (!options.headers.containsKey('Authorization')) {
      final token = await _tokenStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
