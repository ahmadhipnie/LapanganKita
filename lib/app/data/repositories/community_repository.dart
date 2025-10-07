import 'package:dio/dio.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';
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
  Future<CommunityPostsResponse> getPostsByUserId(int userId) async {
    try {
      final response = await _apiClient.get('posts/user?user_id=$userId');
      return CommunityPostsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load user posts: $e');
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
  Future<JoinRequestsResponse> getJoinRequestsByBooking(
    String bookingId,
  ) async {
    try {
      final response = await _apiClient.get('joined/booking/$bookingId');
      return JoinRequestsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load join requests: $e');
    }
  }

  // Update join request status (old method - kept for compatibility)
  Future<Response> updateJoinRequestStatus(
    String requestId,
    String status,
  ) async {
    try {
      print(
        '🔄 Old method: Updating join request $requestId to status: $status using PUT',
      );

      // Use PUT method with form data as shown in Postman
      final response = await _apiClient.raw.put(
        'joined/$requestId/status',
        data: 'status=$status',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      print('✅ Old method response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Old method failed: $e');
      throw Exception('Failed to update join request: $e');
    }
  }

  // Get booking details by booking ID
  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    try {
      final response = await _apiClient.get('bookings/$bookingId');
      return response.data;
    } catch (e) {
      print('⚠️ Failed to get booking details for ID $bookingId: $e');
      return null;
    }
  }

  // Get all join requests
  Future<JoinRequestsResponse> getAllJoinRequests() async {
    try {
      final response = await _apiClient.get('joined');
      return JoinRequestsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load all join requests: $e');
    }
  }

  // Update join request status (approve/reject) using the correct PUT endpoint
  Future<Response> updateJoinRequestStatusById(
    String joinId,
    String status,
  ) async {
    try {
      // Debug: Print the request details
      print('🔄 Updating join request $joinId to status: $status using PUT');

      // Use PUT method with form data as shown in Postman
      final response = await _apiClient.raw.put(
        'joined/$joinId/status',
        data: 'status=$status',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      print('✅ Update join request response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Failed to update join request status: $e');
      throw Exception('Failed to update join request status: $e');
    }
  }

  // Get join requests by user ID
  Future<JoinRequestsResponse> getJoinRequestsByUserId(int userId) async {
    try {
      final response = await _apiClient.get('joined/user?user_id=$userId');
      return JoinRequestsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load join requests by user: $e');
    }
  }

  // Get post details (including post_photo) from posts API
  Future<Map<String, dynamic>?> getPostDetails(String postId) async {
    try {
      final response = await _apiClient.get('posts/$postId');
      return response.data;
    } catch (e) {
      print('Failed to load post details for post $postId: $e');
      return null;
    }
  }
}
