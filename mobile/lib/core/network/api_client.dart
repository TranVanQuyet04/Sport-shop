import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiEndpoints.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'Content-Type': 'application/json'},
            ),
          );

  final Dio _dio;

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
      throw _toApiException(error);
    }
  }

  Future<Map<String, dynamic>> postJson(String path, {Object? data}) async {
    try {
      final response = await _dio.post<Object?>(path, data: data);
      return _asJsonMap(response.data);
    } on DioException catch (error) {
      throw _toApiException(error);
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
      throw _toApiException(error);
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
      throw _toApiException(error);
    }
  }

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

  ApiException _toApiException(DioException error) {
    final response = error.response;
    final data = response?.data;
    String message = 'Không thể kết nối máy chủ. Vui lòng thử lại.';

    if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    } else if (response?.statusCode == 401) {
      message = 'Email hoặc mật khẩu không đúng.';
    } else if (response?.statusCode == 403) {
      message = 'Bạn không có quyền truy cập chức năng này.';
    }

    return ApiException(message, statusCode: response?.statusCode);
  }
}
