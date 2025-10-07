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
  final RxList<JoinRequest> joinRequests =
      <JoinRequest>[].obs; // Join requests TO user's posts
  final RxList<JoinRequest> userJoinRequests =
      <JoinRequest>[].obs; // Join requests FROM user
  final RxBool isLoadingJoinRequests = false.obs;
  final RxString joinRequestsError = ''.obs;
  final RxMap<String, bool> _decisionLoading = <String, bool>{}.obs;

  final CommunityRepository _repository;
  final LocalStorageService _localStorageService = LocalStorageService.instance;

  CustomerCommunityController({required CommunityRepository repository})
    : _repository = repository;

  // Get current user ID
  int get _currentUserId => _localStorageService.userId;
  int get currentUserId => _currentUserId;

  @override
  void onInit() {
    super.onInit();
    print('🟡 Controller initialized, user ID: $_currentUserId');
    scrollController.addListener(_handleScroll);

    // Ganti pemanggilan terpisah dengan method berurutan
    loadInitialData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _handleScroll() {
    isScrolled.value = scrollController.offset > 50;
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;

      // Load featured posts terlebih dahulu
      await _loadFeaturedPosts();

      // Tunggu sebentar untuk memastikan featuredPosts terisi
      await Future.delayed(const Duration(milliseconds: 100));

      // Kemudian load community posts dengan filter yang tepat
      await _loadPostsFromApi();

      // Load data join requests
      await loadAllJoinRequests();
      await loadUserJoinRequests();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load data. Please try again.';
    }
  }

  // Method untuk load featured post (post milik user sendiri)
  Future<void> _loadFeaturedPosts() async {
    try {
      isLoadingFeaturedPost.value = true;
      featuredPosts.clear();

      if (_currentUserId <= 0) {
        isLoadingFeaturedPost.value = false;
        return;
      }

      print('🔍 Loading featured posts for user ID: $_currentUserId');

      final response = await _repository.getPostsByUserId(_currentUserId);

      print('📥 Loaded ${response.data.length} featured posts from API');

      if (response.success) {
        if (response.data.isNotEmpty) {
          // Enrich posts dengan data booking
          final enrichedPosts = await _enrichPostsWithBookingData(
            response.data,
          );

          // Filter out completed bookings - don't show in featured posts
          final activePosts = enrichedPosts
              .where((post) => post.bookingStatus.toLowerCase() != 'completed')
              .toList();

          // Debug: Print filtering results
          print('🔍 Total enriched posts: ${enrichedPosts.length}');
          print('🔍 Active posts (excluding completed): ${activePosts.length}');
          if (activePosts.isNotEmpty) {
            print('🔍 First active post: ${activePosts.first.userName}');
            print('🔍 First post status: ${activePosts.first.bookingStatus}');
          }

          featuredPosts.assignAll(activePosts);
          print(
            '✅ Found ${activePosts.length} active featured posts for current user',
          );

          // Load join requests untuk featured post pertama jika ada
          if (activePosts.isNotEmpty) {
            await fetchJoinRequestsByBooking(activePosts.first.bookingId);
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

  // Enrich community posts dengan data booking
  Future<List<CommunityPost>> _enrichPostsWithBookingData(
    List<CommunityPost> posts,
  ) async {
    final enrichedPosts = <CommunityPost>[];

    for (final post in posts) {
      try {
        // Coba ambil data booking berdasarkan booking_id
        final bookingData = await _repository.getBookingDetails(post.bookingId);

        // Coba ambil data post photo dari posts API
        String postPhoto = '';
        try {
          final postsData = await _repository.getPostDetails(post.id);
          if (postsData != null && postsData['success'] == true) {
            final postInfo = postsData['data'];
            postPhoto = postInfo?['post_photo']?.toString() ?? '';
          }
        } catch (e) {
          print('⚠️ Could not fetch post photo for post ${post.id}: $e');
        }

        if (bookingData != null && bookingData['success'] == true) {
          final bookingInfo = bookingData['data'];
          if (bookingInfo != null) {
            // Buat post baru dengan data booking yang diperbarui menggunakan copyWith
            final enrichedPost = post.copyWith(
              userName: bookingInfo['user_name']?.toString() ?? post.userName,
              totalCost: (bookingInfo['total_price'] ?? post.totalCost)
                  .toDouble(),
              bookingStatus: bookingInfo['status']?.toString() ?? 'approved',
              placeAddress: bookingInfo['place_address']?.toString() ?? '',
              placeName:
                  bookingInfo['place_name']?.toString() ?? post.courtName,
              postPhoto: postPhoto,
            );

            print(
              '✅ Enriched post ${post.id}: ${enrichedPost.userName} - ${enrichedPost.totalCost} - Status: ${enrichedPost.bookingStatus} - Photo: ${postPhoto.isNotEmpty ? 'Yes' : 'No'}',
            );
            enrichedPosts.add(enrichedPost);
          } else {
            final enrichedPost = post.copyWith(postPhoto: postPhoto);
            enrichedPosts.add(enrichedPost);
          }
        } else {
          print('⚠️ No booking data found for booking ID: ${post.bookingId}');
          final enrichedPost = post.copyWith(postPhoto: postPhoto);
          enrichedPosts.add(enrichedPost);
        }
      } catch (e) {
        print('❌ Error enriching post ${post.id}: $e');
        enrichedPosts.add(post);
      }
    }

    return enrichedPosts;
  }

  Future<void> _loadPostsFromApi() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Clear existing posts to ensure fresh data
      posts.clear();

      final response = await _repository.getCommunityPosts();

      if (response.success) {
        // PERBAIKAN: Tunggu featuredPosts selesai load sebelum filter
        // Tunggu hingga featuredPosts sudah terisi (tidak loading)
        while (isLoadingFeaturedPost.value) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        // Filter out posts yang sudah ada di featured posts
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
        print('🎯 Featured post IDs: $featuredPostIds');
        print('🔍 Current user ID: $_currentUserId');

        // Enrich community posts dengan data booking
        final enrichedCommunityPosts = await _enrichPostsWithBookingData(
          otherUsersPosts,
        );
        posts.assignAll(enrichedCommunityPosts);

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
    try {
      print('🔄 Starting refresh posts...');

      // Clear error states when starting refresh
      hasError.value = false;
      errorMessage.value = '';

      // Clear join requests cache to ensure fresh data
      joinRequests.clear();

      // PERBAIKAN: Load featured posts dulu dan TUNGGU selesai
      // sebelum load community posts
      await _loadFeaturedPosts();

      // Pastikan featuredPosts sudah terisi sebelum melanjutkan
      await Future.delayed(const Duration(milliseconds: 200));

      // Sekarang load community posts dengan filter yang akurat
      await _loadPostsFromApi();

      // Refresh join requests for the first featured post if available
      if (featuredPosts.isNotEmpty) {
        await fetchJoinRequestsByBooking(featuredPosts.first.bookingId);
      }

      print('✅ Posts refresh completed successfully');
    } catch (e) {
      print('❌ Error during refresh: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to refresh posts. Please try again.';
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

          // Reload user join requests to update UI
          loadUserJoinRequests();
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

  // Load all join requests for the current user's posts (as poster)
  Future<void> loadAllJoinRequests() async {
    try {
      isLoadingJoinRequests.value = true;
      joinRequestsError.value = '';

      final response = await _repository.getAllJoinRequests();

      if (response.success) {
        // Filter join requests where current user is the poster
        final myPostJoinRequests = response.data
            .where((request) => request.posterUserId == _currentUserId)
            .toList();

        joinRequests.assignAll(myPostJoinRequests);
        print(
          '✅ Loaded ${myPostJoinRequests.length} join requests for user posts',
        );
      } else {
        joinRequestsError.value = response.message;
        print('❌ Failed to load join requests: ${response.message}');
      }
    } catch (e) {
      joinRequestsError.value = 'Failed to load join requests';
      print('❌ Exception loading join requests: $e');
    } finally {
      isLoadingJoinRequests.value = false;
    }
  }

  // Get pending join requests for a specific booking
  List<JoinRequest> getPendingJoinRequestsForBooking(String bookingId) {
    return joinRequests
        .where(
          (request) =>
              request.bookingId == bookingId && request.status == 'pending',
        )
        .toList();
  }

  // Handle approve/reject action
  Future<void> handleJoinRequestAction(String joinId, String action) async {
    if (_decisionLoading[joinId] == true) return;

    try {
      _decisionLoading[joinId] = true;

      print('🔄 Handling join request action: $joinId -> $action');

      final response = await _repository.updateJoinRequestStatusById(
        joinId,
        action,
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update local join request status
        final requestIndex = joinRequests.indexWhere((req) => req.id == joinId);
        if (requestIndex != -1) {
          final updatedRequest = joinRequests[requestIndex].copyWith(
            status: action,
          );
          joinRequests[requestIndex] = updatedRequest;
        }

        // Reload featured posts to update join counts
        await _loadFeaturedPosts();

        // Reload user join requests to update status in other users' views
        loadUserJoinRequests();

        final message = action == 'approved'
            ? 'Join request approved successfully!'
            : 'Join request rejected successfully!';

        Get.snackbar(
          'Success',
          message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        print('✅ Join request $joinId $action successfully');
      } else {
        throw Exception('Failed to update join request status');
      }
    } catch (e) {
      final message =
          'Failed to ${action == 'approved' ? 'approve' : 'reject'} join request';
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ Error ${action}ing join request: $e');
    } finally {
      _decisionLoading.remove(joinId);
    }
  }

  // Load current user's own join requests (where user is the joiner)
  Future<void> loadUserJoinRequests() async {
    try {
      print('🔄 Loading user join requests for user ID: $_currentUserId');

      final response = await _repository.getJoinRequestsByUserId(
        _currentUserId,
      );

      if (response.success) {
        userJoinRequests.assignAll(response.data);
        print('✅ Loaded ${response.data.length} user join requests');
      } else {
        print('❌ Failed to load user join requests: ${response.message}');
      }
    } catch (e) {
      print('❌ Exception loading user join requests: $e');
    }
  }

  // Get user's own join request status for a specific booking
  Future<String?> getUserJoinStatus(String bookingId) async {
    try {
      final response = await _repository.getJoinRequestsByUserId(
        _currentUserId,
      );
      if (response.success) {
        final userRequest = response.data.firstWhereOrNull(
          (request) => request.bookingId == bookingId,
        );
        return userRequest?.status;
      }
    } catch (e) {
      print('❌ Error getting user join status: $e');
    }
    return null;
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
