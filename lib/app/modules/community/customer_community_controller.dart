import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/modules/community/custommer_community_model.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

import '../../data/network/api_client.dart';

class CustomerCommunityController extends GetxController {
  final RxList<CommunityPost> posts = <CommunityPost>[].obs;
  final Rx<CommunityPost?> selectedPost = Rx<CommunityPost?>(null);
  final RxBool isScrolled = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingSinglePost = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final ScrollController scrollController = ScrollController();
  final RxMap<String, bool> _joiningStates = <String, bool>{}.obs;
  final RxList<JoinRequest> joinRequests = <JoinRequest>[].obs;
  final RxBool isLoadingJoinRequests = false.obs;
  final RxString joinRequestsError = ''.obs;
  final RxMap<String, bool> _decisionLoading = <String, bool>{}.obs;

  final ApiClient _apiClient = Get.find<ApiClient>();
  final LocalStorageService _localStorageService = LocalStorageService.instance;

  @override
  void onInit() {
    super.onInit();
    _loadPostsFromApi();
    scrollController.addListener(_handleScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _handleScroll() {
    isScrolled.value = scrollController.offset > 50;
  }

  // Method untuk load single post by ID
  Future<void> loadPostById(String postId) async {
    try {
      isLoadingSinglePost.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _apiClient.get('posts/$postId');

      if (response.statusCode == 200) {
        final postResponse = CommunityPostsResponse.fromJson(response.data);

        if (postResponse.success && postResponse.data.isNotEmpty) {
          final post = postResponse.data.first;
          selectedPost.value = post;
          await fetchJoinRequests(post.id);
        } else {
          errorMessage.value = 'Post not found: ${postResponse.message}';
          hasError.value = true;
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        hasError.value = true;
      }
    } catch (e) {
      errorMessage.value =
          'Connection error: Please check your internet connection';
      hasError.value = true;
      print('Error loading post: $e');
    } finally {
      isLoadingSinglePost.value = false;
    }
  }

  Future<void> _loadPostsFromApi() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _apiClient.get('posts');

      if (response.statusCode == 200) {
        final postsResponse = CommunityPostsResponse.fromJson(response.data);

        if (postsResponse.success) {
          posts.assignAll(postsResponse.data);
          if (postsResponse.data.isEmpty) {
            errorMessage.value =
                'No posts available yet. Be the first to create a post!';
            hasError.value = true;
          }
        } else {
          errorMessage.value = 'Failed to load posts: ${postsResponse.message}';
          hasError.value = true;
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        hasError.value = true;
      }
    } catch (e) {
      errorMessage.value =
          'Connection error: Please check your internet connection';
      hasError.value = true;
      print('Error loading posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPosts() async {
    await _loadPostsFromApi();
    final postId = selectedPost.value?.id;
    if (postId != null) {
      await fetchJoinRequests(postId);
    }
  }

  bool isJoining(String postId) => _joiningStates[postId] ?? false;

  void _setJoining(String postId, bool value) {
    if (value) {
      _joiningStates[postId] = true;
    } else {
      _joiningStates.remove(postId);
    }
  }

  Future<void> joinGame(String postId) async {
    if (isJoining(postId)) return;

    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) {
      Get.snackbar(
        'Error',
        'Post not found',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final post = posts[postIndex];

    if (post.joinedPlayers >= post.playersNeeded) {
      Get.snackbar(
        'Full',
        'This game is already full',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final userId = _localStorageService.userId;
    if (userId <= 0) {
      Get.snackbar(
        'Error',
        'Please sign in to join a game.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (post.bookingId.isEmpty) {
      Get.snackbar(
        'Error',
        'Booking information is unavailable for this post.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _setJoining(postId, true);

    try {
      final response = await _apiClient.post(
        'joined',
        data: {'id_users': userId, 'id_booking': post.bookingId},
      );

      final statusCode = response.statusCode ?? 0;
      final responseBody = response.data;

      if (statusCode >= 200 && statusCode < 300) {
        final bool success;
        if (responseBody is Map<String, dynamic>) {
          success =
              (responseBody['success'] == true) ||
              (responseBody['status'] == true);
        } else {
          success = true;
        }

        final message = _extractMessage(responseBody) ?? 'You joined the game!';

        if (success) {
          final updatedPost = post.copyWith(
            joinedPlayers: post.joinedPlayers + 1,
          );
          posts[postIndex] = updatedPost;

          if (selectedPost.value?.id == updatedPost.id) {
            selectedPost.value = updatedPost;
          }

          Get.snackbar(
            'Success',
            message,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Failed',
            message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Failed',
          'Server error: $statusCode',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on DioException catch (e) {
      final message =
          _extractMessage(e.response?.data) ??
          (e.message ?? 'Failed to join game.');
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan. Silakan coba lagi.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setJoining(postId, false);
    }
  }

  bool isProcessingDecision(String requestId) =>
      _decisionLoading[requestId] ?? false;

  Future<void> fetchJoinRequests(String postId) async {
    try {
      isLoadingJoinRequests.value = true;
      joinRequestsError.value = '';

      final response = await _apiClient.get(
        'posts/joined',
        queryParameters: {'post_id': postId},
      );

      if (response.statusCode == 200) {
        final parsed = JoinRequestsResponse.fromJson(response.data);
        if (parsed.success) {
          joinRequests.assignAll(parsed.data);
          if (parsed.data.isEmpty) {
            joinRequestsError.value = 'Belum ada permintaan bergabung.';
          }
        } else {
          joinRequests.clear();
          joinRequestsError.value = parsed.message.isEmpty
              ? 'Gagal memuat data permintaan.'
              : parsed.message;
        }
      } else {
        joinRequests.clear();
        joinRequestsError.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      joinRequests.clear();
      joinRequestsError.value =
          'Tidak dapat memuat permintaan. Periksa koneksi internet Anda.';
    } finally {
      isLoadingJoinRequests.value = false;
    }
  }

  Future<void> approveJoinRequest(JoinRequest request) async {
    await _updateJoinRequestStatus(request, 'approved');
  }

  Future<void> rejectJoinRequest(JoinRequest request) async {
    await _updateJoinRequestStatus(request, 'rejected');
  }

  Future<void> _updateJoinRequestStatus(
    JoinRequest request,
    String status,
  ) async {
    if (isProcessingDecision(request.id)) return;

    _decisionLoading[request.id] = true;

    try {
      final response = await _apiClient.put(
        'joined/${request.id}',
        data: {'status': status},
      );

      final responseBody = response.data;
      final message =
          _extractMessage(responseBody) ?? 'Permintaan berhasil diperbarui';

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final index = joinRequests.indexWhere((item) => item.id == request.id);
        if (index != -1) {
          final updated = request.copyWith(status: status);
          joinRequests[index] = updated;
        }

        Get.snackbar(
          'Berhasil',
          message,
          backgroundColor: status == 'approved' ? Colors.green : Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Server error: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on DioException catch (e) {
      final message =
          _extractMessage(e.response?.data) ??
          (e.message ?? 'Gagal memperbarui status.');
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan. Silakan coba lagi.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _decisionLoading.remove(request.id);
    }
  }

  String formatRupiah(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.map((e) => e.toString()).join(', ');
      }

      if (errors is Map) {
        final buffer = <String>[];
        errors.forEach((key, value) {
          if (value is Iterable) {
            buffer.addAll(value.map((e) => e.toString()));
          } else if (value != null) {
            buffer.add(value.toString());
          }
        });

        if (buffer.isNotEmpty) {
          return buffer.join(', ');
        }
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }
}
