import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/modules/community/post_modal_view.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

import '../../data/helper/error_helper.dart';
import '../../data/models/customer/community/community_post_model.dart';
import '../../data/models/customer/community/join_request_model.dart';
import '../../data/models/customer/community/post_request.dart';
import '../../data/models/customer/history/customer_history_model.dart';
import '../../data/network/api_client.dart';
import '../../data/repositories/community_repository.dart';
import '../../data/repositories/post_repository.dart';

/// Controller to manage community posts and join requests
/// Handles CRUD posts, join game, approve/reject requests
class CustomerCommunityController extends GetxController {
  // ==================== User-Friendly Messages ====================

  static const Map<String, String> _userMessages = {
    // Join game messages
    'join_success': 'You have successfully joined this game!',
    'join_already_full': 'This game is already full',
    'join_own_post': 'You cannot join your own game',
    'join_already_joined': 'You have already joined this game',
    'join_failed': 'Unable to join game. Please try again.',

    // Join request messages
    'request_approve_success': 'Join request approved successfully!',
    'request_reject_success': 'Join request declined',
    'request_update_failed': 'Unable to process request. Please try again.',

    // Post creation messages
    'post_create_success': 'Your post has been created successfully!',
    'post_create_failed': 'Unable to create post. Please try again.',
    'post_missing_booking': 'Please select a booking',
    'post_missing_title': 'Please enter a title for your post',
    'post_missing_description': 'Please add a description',
    'post_missing_photo': 'Please add a photo',

    // Loading messages
    'load_failed': 'Unable to load data. Please try again.',
    'refresh_failed': 'Unable to refresh. Please check your connection.',
    'load_posts_error': 'Failed to load your posts',

    // Validation messages
    'signin_required': 'Please sign in to continue',
    'booking_unavailable': 'Booking information is not available',
  };

  String _getUserMessage(String key) {
    return _userMessages[key] ?? 'Something went wrong';
  }

  // ==================== Observables ====================

  final RxList<CommunityPost> posts = <CommunityPost>[].obs;
  final RxList<CommunityPost> featuredPosts = <CommunityPost>[].obs;
  final RxList<JoinRequest> joinRequests = <JoinRequest>[].obs;
  final RxList<JoinRequest> userJoinRequests = <JoinRequest>[].obs;
  final RxList<BookingHistory> approvedBookings = <BookingHistory>[].obs;

  // State management
  final RxBool isScrolled = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingFeaturedPost = false.obs;
  final RxBool isLoadingJoinRequests = false.obs;
  final RxBool isLoadingBookings = false.obs;
  final RxBool isCreatingPost = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString joinRequestsError = ''.obs;

  final RxMap<String, bool> _joiningStates = <String, bool>{}.obs;
  final RxMap<String, bool> _decisionLoading = <String, bool>{}.obs;

  // ==================== Controllers & Services ====================

  final ScrollController scrollController = ScrollController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<BookingHistory?> selectedBooking = Rx<BookingHistory?>(null);

  late final CommunityRepository _repository;
  final LocalStorageService _localStorageService = LocalStorageService.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final _errorHandler = ErrorHandler();

  PostRepository get _postRepository {
    if (!Get.isRegistered<PostRepository>()) {
      Get.lazyPut<PostRepository>(
        () => PostRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    return Get.find<PostRepository>();
  }

  // ==================== Constructor ====================

  CustomerCommunityController({required CommunityRepository repository})
    : _repository = repository;

  int get _currentUserId => _localStorageService.userId;
  int get currentUserId => _currentUserId;

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_handleScroll);

    if (!Get.isRegistered<PostRepository>()) {
      Get.lazyPut<PostRepository>(
        () => PostRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }

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

  // ==================== Data Loading ====================

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;

      await _loadFeaturedPosts();
      await Future.delayed(const Duration(milliseconds: 100));
      await _loadPostsFromApi();
      await loadAllJoinRequests();
      await loadUserJoinRequests();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = _getUserMessage('load_failed');
    }
  }

  Future<void> _loadFeaturedPosts() async {
    try {
      isLoadingFeaturedPost.value = true;
      featuredPosts.clear();

      if (_currentUserId <= 0) {
        isLoadingFeaturedPost.value = false;
        return;
      }

      final response = await _repository.getPostsByUserId(_currentUserId);

      if (response.success) {
        if (response.data.isNotEmpty) {
          final enrichedPosts = await _enrichPostsWithBookingData(
            response.data,
          );

          final activePosts = enrichedPosts
              .where((post) => post.bookingStatus.toLowerCase() != 'completed')
              .toList();

          featuredPosts.assignAll(activePosts);

          if (activePosts.isNotEmpty) {
            await fetchJoinRequestsByBooking(activePosts.first.bookingId);
          }
        } else {
          featuredPosts.clear();
        }
      } else {
        featuredPosts.clear();
      }
    } catch (e) {
      featuredPosts.clear();
      _errorHandler.showErrorMessage(_getUserMessage('load_posts_error'));
    } finally {
      isLoadingFeaturedPost.value = false;
    }
  }

  Future<List<CommunityPost>> _enrichPostsWithBookingData(
    List<CommunityPost> posts,
  ) async {
    final enrichedPosts = <CommunityPost>[];

    for (final post in posts) {
      try {
        final bookingData = await _repository.getBookingDetails(
          post.bookingId.toString(),
        );

        String postPhoto = '';
        try {
          final postsData = await _repository.getPostDetails(
            post.id.toString(),
          );
          if (postsData != null && postsData['success'] == true) {
            final postInfo = postsData['data'];
            postPhoto = postInfo?['post_photo']?.toString() ?? '';
          }
        } catch (e) {
          // Silent fail for post photo
        }

        if (bookingData != null && bookingData['success'] == true) {
          final bookingInfo = bookingData['data'];
          if (bookingInfo != null) {
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

            enrichedPosts.add(enrichedPost);
          } else {
            final enrichedPost = post.copyWith(postPhoto: postPhoto);
            enrichedPosts.add(enrichedPost);
          }
        } else {
          final enrichedPost = post.copyWith(postPhoto: postPhoto);
          enrichedPosts.add(enrichedPost);
        }
      } catch (e) {
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
      posts.clear();

      final response = await _repository.getCommunityPosts();

      if (response.success) {
        while (isLoadingFeaturedPost.value) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        final Set<int> featuredPostIds = featuredPosts.map((p) => p.id).toSet();

        final otherUsersPosts = response.data.where((post) {
          final isNotCurrentUser = post.posterUserId != _currentUserId;
          final isNotInFeatured = !featuredPostIds.contains(post.id);
          return isNotCurrentUser && isNotInFeatured;
        }).toList();

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
        errorMessage.value = _getUserMessage('load_failed');
        hasError.value = true;
      }
    } catch (e) {
      errorMessage.value =
          'Connection error: Please check your internet connection';
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPosts() async {
    try {
      hasError.value = false;
      errorMessage.value = '';

      joinRequests.clear();
      userJoinRequests.clear();

      await _loadFeaturedPosts();
      await Future.delayed(const Duration(milliseconds: 200));
      await _loadPostsFromApi();
      await Future.wait([loadAllJoinRequests(), loadUserJoinRequests()]);

      if (featuredPosts.isNotEmpty) {
        await fetchJoinRequestsByBooking(featuredPosts.first.bookingId);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = _getUserMessage('refresh_failed');
    }
  }

  // ==================== Join Game ====================

  bool isJoining(String postId) => _joiningStates[postId] ?? false;

  void _setJoining(String postId, bool value) {
    if (value) {
      _joiningStates[postId] = true;
    } else {
      _joiningStates.remove(postId);
    }
  }

  Future<void> joinGame(int postId) async {
    if (isJoining(postId.toString())) return;

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
      _errorHandler.showErrorMessage(_getUserMessage('join_failed'));
      return;
    }

    if (post.posterUserId == _currentUserId) {
      _errorHandler.showErrorMessage(_getUserMessage('join_own_post'));
      return;
    }

    if (post.joinedPlayers >= post.playersNeeded) {
      _errorHandler.showErrorMessage(_getUserMessage('join_already_full'));
      return;
    }

    final userId = _localStorageService.userId;
    if (userId <= 0) {
      _errorHandler.showErrorMessage(_getUserMessage('signin_required'));
      return;
    }

    if (post.bookingId <= 0) {
      _errorHandler.showErrorMessage(_getUserMessage('booking_unavailable'));
      return;
    }

    _setJoining(postId.toString(), true);

    try {
      final response = await _repository.joinGame(
        userId,
        post.bookingId.toString(),
      );

      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        final updatedPost = post.copyWith(
          joinedPlayers: post.joinedPlayers + 1,
        );

        if (postIndex != -1) {
          posts[postIndex] = updatedPost;
        } else {
          final featuredIndex = featuredPosts.indexWhere((p) => p.id == postId);
          if (featuredIndex != -1) {
            featuredPosts[featuredIndex] = updatedPost;
          }
        }

        await loadUserJoinRequests();

        _errorHandler.showSuccessMessage(_getUserMessage('join_success'));
      } else {
        throw Exception(_getUserMessage('join_failed'));
      }
    } on DioException catch (e) {
      final friendlyMessage = _errorHandler.getSimpleErrorMessage(e);
      _errorHandler.showErrorMessage(friendlyMessage);
    } catch (e) {
      _errorHandler.showErrorMessage(_getUserMessage('join_failed'));
    } finally {
      _setJoining(postId.toString(), false);
    }
  }

  // ==================== Join Requests ====================

  Future<void> loadAllJoinRequests() async {
    try {
      isLoadingJoinRequests.value = true;
      joinRequestsError.value = '';

      final response = await _repository.getAllJoinRequests();

      if (response.success) {
        final myPostJoinRequests = response.data
            .where((request) => request.posterUserId == _currentUserId)
            .toList();

        joinRequests.assignAll(myPostJoinRequests);
      } else {
        joinRequestsError.value = response.message;
      }
    } catch (e) {
      joinRequestsError.value = 'Failed to load join requests';
    } finally {
      isLoadingJoinRequests.value = false;
    }
  }

  Future<void> loadUserJoinRequests() async {
    try {
      final response = await _repository.getJoinRequestsByUserId(
        _currentUserId,
      );

      if (response.success) {
        userJoinRequests.clear();
        userJoinRequests.assignAll(response.data);
        userJoinRequests.refresh();
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> fetchJoinRequestsByBooking(int bookingId) async {
    try {
      isLoadingJoinRequests.value = true;
      joinRequestsError.value = '';

      final response = await _repository.getJoinRequestsByBooking(
        bookingId.toString(),
      );

      if (response.success) {
        joinRequests.assignAll(response.data);

        if (response.data.isEmpty) {
          joinRequestsError.value = 'No join requests yet.';
        }
      } else {
        joinRequests.clear();
        joinRequestsError.value = response.message.isEmpty
            ? 'Failed to load request data.'
            : response.message;
      }
    } catch (e) {
      joinRequests.clear();
      joinRequestsError.value =
          'Unable to load requests. Please check your internet connection.';
    } finally {
      isLoadingJoinRequests.value = false;
    }
  }

  List<JoinRequest> getPendingJoinRequestsForBooking(int bookingId) {
    return joinRequests
        .where(
          (request) =>
              request.bookingId == bookingId && request.status == 'pending',
        )
        .toList();
  }

  String? getUserJoinStatusForBooking(int bookingId) {
    try {
      final userRequest = userJoinRequests.firstWhereOrNull(
        (request) => request.bookingId == bookingId,
      );

      return userRequest?.status;
    } catch (e) {
      return null;
    }
  }

  bool isProcessingDecision(int requestId) =>
      _decisionLoading[requestId.toString()] ?? false;

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

    _decisionLoading[request.id.toString()] = true;

    try {
      final response = await _repository.updateJoinRequestStatus(
        request.id.toString(),
        status,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final index = joinRequests.indexWhere((item) => item.id == request.id);
        if (index != -1) {
          final updated = request.copyWith(status: status);
          joinRequests[index] = updated;
        }

        final messageKey = status == 'approved'
            ? 'request_approve_success'
            : 'request_reject_success';
        _errorHandler.showSuccessMessage(_getUserMessage(messageKey));
      }
    } on DioException catch (e) {
      final friendlyMessage = _errorHandler.getSimpleErrorMessage(e);
      _errorHandler.showErrorMessage(friendlyMessage);
    } catch (e) {
      _errorHandler.showErrorMessage(_getUserMessage('request_update_failed'));
    } finally {
      _decisionLoading.remove(request.id.toString());
    }
  }

  Future<void> handleJoinRequestAction(int joinId, String action) async {
    if (_decisionLoading[joinId.toString()] == true) return;

    try {
      _decisionLoading[joinId.toString()] = true;

      final response = await _repository.updateJoinRequestStatusById(
        joinId.toString(),
        action,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final requestIndex = joinRequests.indexWhere((req) => req.id == joinId);
        if (requestIndex != -1) {
          final updatedRequest = joinRequests[requestIndex].copyWith(
            status: action,
          );
          joinRequests[requestIndex] = updatedRequest;
        }

        final userRequestIndex = userJoinRequests.indexWhere(
          (req) => req.id == joinId,
        );
        if (userRequestIndex != -1) {
          final updatedUserRequest = userJoinRequests[userRequestIndex]
              .copyWith(status: action);
          userJoinRequests[userRequestIndex] = updatedUserRequest;
        }

        userJoinRequests.refresh();
        joinRequests.refresh();

        await Future.wait([_loadFeaturedPosts(), loadUserJoinRequests()]);

        final messageKey = action == 'approved'
            ? 'request_approve_success'
            : 'request_reject_success';
        _errorHandler.showSuccessMessage(_getUserMessage(messageKey));
      } else {
        throw Exception(_getUserMessage('request_update_failed'));
      }
    } on DioException catch (e) {
      final friendlyMessage = _errorHandler.getSimpleErrorMessage(e);
      _errorHandler.showErrorMessage(friendlyMessage);
    } catch (e) {
      _errorHandler.showErrorMessage(_getUserMessage('request_update_failed'));
    } finally {
      _decisionLoading.remove(joinId.toString());
    }
  }

  // ==================== Create Post ====================

  Future<void> loadApprovedBookings() async {
    try {
      isLoadingBookings.value = true;
      final userId = _localStorageService.userId;
      final apiClient = Get.find<ApiClient>();

      final postsResponse = await apiClient.get<Map<String, dynamic>>('posts');

      final Set<int> postedBookingIds = {};

      if (postsResponse.statusCode == 200 && postsResponse.data != null) {
        final data = postsResponse.data!;

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> allPosts = data['data'] as List<dynamic>;

          for (var post in allPosts) {
            final idBooking = post['id_booking'];
            if (idBooking != null) {
              final bookingId = int.tryParse(idBooking.toString());
              if (bookingId != null) {
                postedBookingIds.add(bookingId);
              }
            }
          }
        }
      }

      final bookingsResponse = await apiClient.raw.get<Map<String, dynamic>>(
        'bookings/me/bookings',
        queryParameters: {'user_id': userId},
      );

      if (bookingsResponse.statusCode == 200 && bookingsResponse.data != null) {
        final data = bookingsResponse.data!;

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> bookingsList = data['data'] as List<dynamic>;

          final allBookings = bookingsList
              .map(
                (json) => BookingHistory.fromApiResponse(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();

          final availableBookings = allBookings.where((booking) {
            final isApproved = booking.status.toLowerCase() == 'approved';
            final notPosted = !postedBookingIds.contains(booking.id);
            return isApproved && notPosted;
          }).toList();

          approvedBookings.assignAll(availableBookings);
        }
      }
    } catch (e) {
      approvedBookings.clear();
    } finally {
      isLoadingBookings.value = false;
    }
  }

  void openCreatePostBottomSheet() {
    _resetCreatePostForm();
    loadApprovedBookings();

    Get.bottomSheet(
      CreatePostBottomSheet(controller: this),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
    );
  }

  void selectBooking(BookingHistory? booking) {
    selectedBooking.value = booking;

    if (booking != null) {
      titleController.text = 'Looking for players at ${booking.courtName}';
    } else {
      titleController.clear();
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        _errorHandler.showSuccessMessage('Image selected');
      }
    } catch (e) {
      _errorHandler.showErrorMessage('Failed to pick image');
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }

  Future<void> submitCreatePost() async {
    // Validation
    if (selectedBooking.value == null) {
      _errorHandler.showErrorMessage(_getUserMessage('post_missing_booking'));
      return;
    }

    if (titleController.text.trim().isEmpty) {
      _errorHandler.showErrorMessage(_getUserMessage('post_missing_title'));
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      _errorHandler.showErrorMessage(
        _getUserMessage('post_missing_description'),
      );
      return;
    }

    if (selectedImage.value == null) {
      _errorHandler.showErrorMessage(_getUserMessage('post_missing_photo'));
      return;
    }

    try {
      isCreatingPost.value = true;

      final request = PostRequest(
        idBooking: selectedBooking.value!.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
      );

      final response = await _postRepository.createPost(
        request: request,
        photoFile: selectedImage.value!,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ RESET LOADING STATE
        isCreatingPost.value = false;

        // ✅ RESET FORM FIRST
        _resetCreatePostForm();

        // ✅ SMALL DELAY BEFORE CLOSE
        await Future.delayed(const Duration(milliseconds: 100));

        // ✅ CLOSE MODAL
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }

        // ✅ SHOW SUCCESS MESSAGE AFTER CLOSE
        await Future.delayed(const Duration(milliseconds: 500));
        _errorHandler.showSuccessMessage(
          _getUserMessage('post_create_success'),
        );

        // ✅ REFRESH IN BACKGROUND
        refreshPosts();
        loadApprovedBookings();
      } else {
        throw Exception(_getUserMessage('post_create_failed'));
      }
    } on DioException catch (e) {
      final friendlyMessage = _errorHandler.getSimpleErrorMessage(e);
      _errorHandler.showErrorMessage(friendlyMessage);
    } catch (e) {
      _errorHandler.showErrorMessage(_getUserMessage('post_create_failed'));
    } finally {
      isCreatingPost.value = false;
    }
  }

  void _resetCreatePostForm() {
    selectedBooking.value = null;
    titleController.clear();
    descriptionController.clear();
    selectedImage.value = null;
  }

  // ==================== Utilities ====================

  String formatRupiah(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(amount);
  }
}
