import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? createDefaultDio();

  static const String baseUrl = 'http://192.168.68.130:3000/api/';
  static const String baseUrlWithoutApi = 'http://192.168.68.130:3000';

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

  String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) {
      return 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400&h=300&fit=crop';
    }
    if (imagePath.startsWith('http')) return imagePath;
    if (imagePath.startsWith('/')) {
      return '$baseUrlWithoutApi$imagePath';
    }
    return '$baseUrlWithoutApi/$imagePath';
  }

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

  Future<Response<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
