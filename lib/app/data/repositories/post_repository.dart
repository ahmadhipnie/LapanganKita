import 'dart:io';
import 'package:dio/dio.dart';
import '../models/customer/community/post_request.dart';
import '../network/api_client.dart';

class PostRepository {
  final ApiClient _apiClient;

  PostRepository(this._apiClient);

  /// Create new post with photo
  /// Required: booking_id, post_title, post_description, post_photo
  Future<Response> createPost({
    required PostRequest request,
    required File photoFile,
  }) async {
    try {
      print('📤 Creating post...');
      print('  Booking ID: ${request.idBooking}');
      print('  Title: ${request.title}');
      print('  Description: ${request.description}');
      print('  Photo: ${photoFile.path}');

      // ✅ Buat FormData dengan field names yang BENAR
      final formData = FormData.fromMap({
        'id_booking': request.idBooking, // ✅ id_booking (underscore)
        'post_title': request.title, // ✅ post_title
        'post_description': request.description, // ✅ post_description
        'post_photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split('/').last,
        ),
      });

      print('📡 Sending POST request to /posts...');

      // ✅ POST ke endpoint /posts
      final response = await _apiClient.raw.post('posts', data: formData);

      print('✅ Response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      return response;
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  /// Update existing post (optional photo)
  Future<Response> updatePost({
    required String postId,
    required PostRequest request,
    File? photoFile,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {
        'id_booking': request.idBooking,
        'post_title': request.title,
        'post_description': request.description,
      };

      // ✅ Hanya tambahkan photo jika ada
      if (photoFile != null) {
        formDataMap['post_photo'] = await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _apiClient.raw.put(
        'posts/$postId',
        data: formData,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete post
  Future<Response> deletePost(String postId) async {
    try {
      final response = await _apiClient.raw.delete('posts/$postId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get post by ID
  Future<Response> getPostById(String postId) async {
    try {
      final response = await _apiClient.raw.get('posts/$postId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get posts by user ID
  Future<Response> getPostsByUserId(int userId) async {
    try {
      final response = await _apiClient.raw.get(
        'posts/user',
        queryParameters: {'user_id': userId},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all posts
  Future<Response> getAllPosts() async {
    try {
      final response = await _apiClient.raw.get('posts');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
