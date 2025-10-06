import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/modules/community/custommer_community_model.dart';

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

  final ApiClient _apiClient = Get.find<ApiClient>();

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
          selectedPost.value = postResponse.data.first;
        } else {
          errorMessage.value = 'Post not found: ${postResponse.message}';
          hasError.value = true;
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        hasError.value = true;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: Please check your internet connection';
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
            errorMessage.value = 'No posts available yet. Be the first to create a post!';
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
      errorMessage.value = 'Connection error: Please check your internet connection';
      hasError.value = true;
      print('Error loading posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPosts() async {
    await _loadPostsFromApi();
  }

  void joinGame(String postId) {
    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      if (posts[postIndex].joinedPlayers < posts[postIndex].playersNeeded) {
        final updatedPost = CommunityPost(
          id: posts[postIndex].id,
          userProfileImage: posts[postIndex].userProfileImage,
          userName: posts[postIndex].userName,
          postTime: posts[postIndex].postTime,
          category: posts[postIndex].category,
          title: posts[postIndex].title,
          subtitle: posts[postIndex].subtitle,
          courtName: posts[postIndex].courtName,
          gameDate: posts[postIndex].gameDate,
          gameTime: posts[postIndex].gameTime,
          playersNeeded: posts[postIndex].playersNeeded,
          totalCost: posts[postIndex].totalCost,
          joinedPlayers: posts[postIndex].joinedPlayers + 1,
        );
        posts[postIndex] = updatedPost;
        Get.snackbar(
          'Success', 
          'You joined the game!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Full', 
          'This game is already full',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error', 
        'Post not found',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
}