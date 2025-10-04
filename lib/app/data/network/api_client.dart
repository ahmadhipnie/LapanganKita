import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? createDefaultDio();

  static const String baseUrl = 'https://217f27a1c4e8.ngrok-free.app/api/';

  static final BaseOptions _defaultOptions = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
    contentType: 'application/json',
    responseType: ResponseType.json,
  );

  final Dio _dio;

  Dio get raw => _dio;

  static Dio createDefaultDio() => Dio(_defaultOptions);

  Future<Response<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
