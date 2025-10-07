import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

import '../../data/models/customer/community/community_post_model.dart';
import '../../data/models/customer/community/join_request_model.dart';
import '../../data/repositories/community_repository.dart';

class CustomerCommunityController extends GetxController {
  final RxList<CommunityPost> posts = <CommunityPost>[].obs;
  final RxList<CommunityPost> featuredPosts = <CommunityPost>[].obs;
  final RxBool isScrolled = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingFeaturedPost = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final ScrollController scrollController = ScrollController();
  final RxMap<String, bool> _joiningStates = <String, bool>{}.obs;
  final RxList<JoinRequest> joinRequests = <JoinRequest>[].obs;
  final RxBool isLoadingJoinRequests = false.obs;
  final RxString joinRequestsError = ''.obs;
  final RxMap<String, bool> _decisionLoading = <String, bool>{}.obs;

  final CommunityRepository _repository;
  final LocalStorageService _localStorageService = LocalStorageService.instance;

  CustomerCommunityController({required CommunityRepository repository})
    : _repository = repository;

  // Get current user ID
  int get _currentUserId => _localStorageService.userId;

  @override
  void onInit() {
    super.onInit();
    print('🟡 Controller initialized, user ID: $_currentUserId');
    scrollController.addListener(_handleScroll);
    _loadFeaturedPosts();
    _loadPostsFromApi();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _handleScroll() {
    isScrolled.value = scrollController.offset > 50;
  }

  // Method untuk load featured post (post milik user sendiri)
  Future<void> _loadFeaturedPosts() async {
    try {
      isLoadingFeaturedPost.value = true;
      featuredPosts.clear();

      if (_currentUserId <= 0) {
        print('❌ User not logged in, cannot load featured posts');
        isLoadingFeaturedPost.value = false;
        return;
      }

      print('🔍 Loading featured posts for user ID: $_currentUserId');

      final response = await _repository.getPostsByUserId(_currentUserId);

      print('📥 Loaded ${response.data.length} featured posts from API');

      if (response.success) {
        if (response.data.isNotEmpty) {
          // Debug: Print raw data untuk cek field yang tersedia
          print('🔍 First post data: ${response.data.first.userName}');
          print('🔍 Poster User ID: ${response.data.first.posterUserId}');

          featuredPosts.assignAll(response.data);
          print(
            '✅ Found ${response.data.length} featured posts for current user',
          );

          // Load join requests untuk featured post pertama jika ada
          if (response.data.isNotEmpty) {
            await fetchJoinRequestsByBooking(response.data.first.bookingId);
          }
        } else {
          print('⚠️ No posts found for current user ID: $_currentUserId');
          featuredPosts.clear();
        }
      } else {
        print('❌ API returned error: ${response.message}');
        featuredPosts.clear();
      }
    } catch (e) {
      print('❌ Exception loading featured posts: $e');
      featuredPosts.clear();
      Get.snackbar(
        'Error',
        'Failed to load your posts',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingFeaturedPost.value = false;
    }
  }

  Future<void> _loadPostsFromApi() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _repository.getCommunityPosts();

      if (response.success) {
        // PERBAIKAN: Filter out posts yang sudah ada di featured posts
        // Dengan membandingkan post ID
        final Set<String> featuredPostIds = featuredPosts
            .map((p) => p.id)
            .toSet();

        final otherUsersPosts = response.data.where((post) {
          // Filter berdasarkan user ID DAN post ID untuk menghindari duplikasi
          final isNotCurrentUser = post.posterUserId != _currentUserId;
          final isNotInFeatured = !featuredPostIds.contains(post.id);
          return isNotCurrentUser && isNotInFeatured;
        }).toList();

        print(
          '👥 Community posts: ${otherUsersPosts.length} posts from other users (filtered from ${response.data.length} total)',
        );
        print('🎯 Featured posts count: ${featuredPosts.length}');
        print('🔍 Current user ID: $_currentUserId');

        posts.assignAll(otherUsersPosts);

        if (response.data.isEmpty) {
          errorMessage.value = 'No community posts available yet.';
          hasError.value = true;
        } else if (otherUsersPosts.isEmpty && featuredPosts.isNotEmpty) {
          errorMessage.value =
              'All available posts are yours! Share with friends to see their posts here.';
          hasError.value = true;
        } else if (otherUsersPosts.isEmpty && featuredPosts.isEmpty) {
          errorMessage.value = 'Be the first to create a community post!';
          hasError.value = true;
        }
      } else {
        errorMessage.value = 'Failed to load posts: ${response.message}';
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

  // Update refreshPosts method
  Future<void> refreshPosts() async {
    // Load featured posts dulu, baru community posts
    // Agar filter di community posts bisa bekerja dengan benar
    await _loadFeaturedPosts();
    await _loadPostsFromApi();
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

    // Cari post di community posts atau featured posts
    CommunityPost? post;
    int postIndex = posts.indexWhere((post) => post.id == postId);

    if (postIndex != -1) {
      post = posts[postIndex];
    } else {
      final featuredIndex = featuredPosts.indexWhere(
        (post) => post.id == postId,
      );
      if (featuredIndex != -1) {
        post = featuredPosts[featuredIndex];
      }
    }

    if (post == null) {
      Get.snackbar(
        'Error',
        'Post not found',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Cek apakah user mencoba join post milik sendiri
    if (post.posterUserId == _currentUserId) {
      Get.snackbar(
        'Error',
        'You cannot join your own post',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

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
      final response = await _repository.joinGame(userId, post.bookingId);

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

          // Update post di list yang sesuai
          if (postIndex != -1) {
            posts[postIndex] = updatedPost;
          } else {
            final featuredIndex = featuredPosts.indexWhere(
              (p) => p.id == postId,
            );
            if (featuredIndex != -1) {
              featuredPosts[featuredIndex] = updatedPost;
            }
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

  Future<void> fetchJoinRequestsByBooking(String bookingId) async {
    try {
      isLoadingJoinRequests.value = true;
      joinRequestsError.value = '';

      print('🔍 Fetching join requests for booking ID: $bookingId');

      final response = await _repository.getJoinRequestsByBooking(bookingId);

      print('✅ Parsed ${response.data.length} join requests');

      if (response.success) {
        joinRequests.assignAll(response.data);

        if (response.data.isEmpty) {
          joinRequestsError.value = 'Belum ada permintaan bergabung.';
        } else {
          print(
            '🎯 Loaded ${response.data.length} join requests for booking $bookingId',
          );
        }
      } else {
        joinRequests.clear();
        joinRequestsError.value = response.message.isEmpty
            ? 'Gagal memuat data permintaan.'
            : response.message;
        print('❌ API Error: ${response.message}');
      }
    } catch (e) {
      joinRequests.clear();
      joinRequestsError.value =
          'Tidak dapat memuat permintaan. Periksa koneksi internet Anda.';
      print('❌ Exception: $e');
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
      final response = await _repository.updateJoinRequestStatus(
        request.id,
        status,
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
