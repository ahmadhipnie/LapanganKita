import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/modules/community/custommer_community_model.dart';

class CustomerCommunityController extends GetxController {
  final RxList<CommunityPost> posts = <CommunityPost>[].obs;
  final RxBool isScrolled = false.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
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

  void _loadDummyData() {
    posts.addAll([
      CommunityPost(
        id: '1',
        userProfileImage: '',
        userName: 'John Doe',
        postTime: DateTime.now().subtract(Duration(hours: 1)),
        category: 'Futsal',
        title: 'Looking for 2 more players',
        subtitle: 'Casual game, all skill levels welcome!',
        courtName: 'Sport Arena Central',
        gameDate: DateTime.now().add(Duration(days: 1)),
        gameTime: '19:00',
        playersNeeded: 2,
        totalCost: 250000,
        joinedPlayers: 3,
      ),
      CommunityPost(
        id: '2',
        userProfileImage: '',
        userName: 'Jane Smith',
        postTime: DateTime.now().subtract(Duration(hours: 3)),
        category: 'Basketball',
        title: 'Weekend Basketball Game',
        subtitle: 'Competitive but friendly match',
        courtName: 'City Basketball Court',
        gameDate: DateTime.now().add(Duration(days: 2)),
        gameTime: '15:00',
        playersNeeded: 3,
        totalCost: 180000,
        joinedPlayers: 2,
      ),
      CommunityPost(
        id: '3',
        userProfileImage: '',
        userName: 'Jane Smith',
        postTime: DateTime.now().subtract(Duration(hours: 3)),
        category: 'Basketball',
        title: 'Weekend Basketball Game',
        subtitle: 'Competitive but friendly match',
        courtName: 'City Basketball Court',
        gameDate: DateTime.now().add(Duration(days: 2)),
        gameTime: '15:00',
        playersNeeded: 3,
        totalCost: 180000,
        joinedPlayers: 2,
      ),
    ]);
  }

  void joinGame(String postId) {
    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1 &&
        posts[postIndex].joinedPlayers < posts[postIndex].playersNeeded) {
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
      Get.snackbar('Success', 'You joined the game!');
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
