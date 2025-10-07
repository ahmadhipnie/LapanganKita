import 'package:dio/dio.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';
import '../models/customer/community/community_post_detail_model.dart';
import '../models/customer/community/community_post_model.dart';
import '../models/customer/community/join_request_model.dart';

class CommunityRepository {
  final ApiClient _apiClient;

  CommunityRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // Get all community posts
  Future<CommunityPostsResponse> getCommunityPosts() async {
    try {
      final response = await _apiClient.get('posts');
      return CommunityPostsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load community posts: $e');
    }
  }

  // Get post by ID
  Future<CommunityPostDetailResponse> getPostById(String postId) async {
    try {
      final response = await _apiClient.get('posts/$postId');
      return CommunityPostDetailResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load post detail: $e');
    }
  }

  // Join game
  Future<Response> joinGame(int userId, String bookingId) async {
    try {
      return await _apiClient.post(
        'joined',
        data: {'id_users': userId, 'id_booking': bookingId},
      );
    } catch (e) {
      throw Exception('Failed to join game: $e');
    }
  }

  // Get join requests by booking ID
  Future<JoinRequestsResponse> getJoinRequestsByBooking(String bookingId) async {
    try {
      final response = await _apiClient.get('joined/booking/$bookingId');
      return JoinRequestsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load join requests: $e');
    }
  }

  // Update join request status
  Future<Response> updateJoinRequestStatus(String requestId, String status) async {
    try {
      return await _apiClient.put(
        'joined/$requestId',
        data: {'status': status},
      );
    } catch (e) {
      throw Exception('Failed to update join request: $e');
    }
  }
}
