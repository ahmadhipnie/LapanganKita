import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? createDefaultDio();

  static const String baseUrl = 'https://1972104ea7f7.ngrok-free.app/api/';
  static const String baseUrlWithoutApi = 'https://1972104ea7f7.ngrok-free.app';

  static final BaseOptions _defaultOptions = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
    responseType: ResponseType.json,
  );

  final Dio _dio;

  Dio get raw => _dio;

  static Dio createDefaultDio() => Dio(_defaultOptions);

  Future<Response<T>> postMultipart<T>(
    String endpoint, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options:
          options ??
          Options(
            contentType: 'multipart/form-data',
            headers: {'Content-Type': 'multipart/form-data'},
          ),
    );
  }

  String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) {
      return 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400&h=300&fit=crop';
    }
    if (imagePath.startsWith('http')) return imagePath;

    String cleanPath = imagePath;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    if (cleanPath.startsWith('posts/')) {
      cleanPath = cleanPath.replaceFirst('posts/', 'uploads/posts/');
    } else if (!cleanPath.contains('/')) {
      cleanPath = 'uploads/posts/$cleanPath';
    } else if (cleanPath.startsWith('uploads/')) {}

    final finalUrl = '$baseUrlWithoutApi/$cleanPath';

    return finalUrl;
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
