import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/modules/community/customer_community_controller.dart';
import 'package:lapangan_kita/app/modules/community/custommer_community_model.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

import '../../data/network/api_client.dart';

class CustomerCommunityView extends GetView<CustomerCommunityController> {
  const CustomerCommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Community'),
            const Text(
              'Manage your court reservations and booking history',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppColors.neutralColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshPosts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Section 1: Single Post by ID (contoh dengan ID tertentu)
          _buildSinglePostSection(),
          
          // Section 2: List of Posts
          Expanded(
            child: _buildPostsListSection(),
          ),
        ],
      ),
    );
  }

  // Section untuk menampilkan single post by ID
  Widget _buildSinglePostSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Post',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8),
          Obx(() {
            if (controller.isLoadingSinglePost.value) {
              return Center(child: CircularProgressIndicator());
            }
            
            final featuredPost = controller.selectedPost.value;
            if (featuredPost != null) {
              return _buildFeaturedPostCard(featuredPost);
            } else {
              return _buildLoadFeaturedPostButton();
            }
          }),
        ],
      ),
    );
  }

  // Button untuk load featured post
  Widget _buildLoadFeaturedPostButton() {
    return Column(
      children: [
        Text(
          'Load featured post',
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            // Ganti '1' dengan ID post yang ingin ditampilkan
            controller.loadPostById('1');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
          child: Text('Load Featured Post'),
        ),
      ],
    );
  }

  // Card khusus untuk featured post
  Widget _buildFeaturedPostCard(CommunityPost post) {
    final apiClient = Get.find<ApiClient>();

    return Card(
      color: Colors.blue[50],
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  'FEATURED',
                  style: TextStyle(
                    color: Colors.amber[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            _buildPostContent(post, apiClient),
          ],
        ),
      ),
    );
  }

  // Section untuk list posts biasa
  Widget _buildPostsListSection() {
    return Obx(
      () => controller.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: controller.refreshPosts,
              child: ListView.builder(
                controller: controller.scrollController,
                padding: EdgeInsets.all(16),
                itemCount: controller.posts.length,
                itemBuilder: (context, index) {
                  final post = controller.posts[index];
                  return _buildPostCard(post);
                },
              ),
            ),
    );
  }

  // Widget post card untuk list biasa
  Widget _buildPostCard(CommunityPost post) {
    final apiClient = Get.find<ApiClient>();

    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: _buildPostContent(post, apiClient),
      ),
    );
  }

  // Common post content yang bisa digunakan oleh kedua section
  Widget _buildPostContent(CommunityPost post, ApiClient apiClient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dengan profile, nama, waktu - menggunakan Stack untuk category
        Stack(
          children: [
            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: apiClient.getImageUrl(post.userProfileImage),
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 20,
                    backgroundImage: imageProvider,
                    backgroundColor: Colors.grey[300],
                  ),
                  placeholder: (context, url) => CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: Center(
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, color: Colors.grey[600]),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        post.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Category di pojok kanan atas
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  post.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        // Title dan Subtitle
        Text(
          post.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(
          post.subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),

        SizedBox(height: 16),

        // Court Info dengan background biru pucat
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.blue[700],
                  ),
                  SizedBox(width: 8),
                  Text(
                    post.courtName,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Game Details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDetailItem(
              Icons.calendar_today,
              DateFormat('dd MMM yyyy').format(post.gameDate),
            ),
            _buildDetailItem(Icons.access_time, post.gameTime),
            _buildDetailItem(
              Icons.people,
              '${post.joinedPlayers}/${post.playersNeeded} Players',
            ),
          ],
        ),

        SizedBox(height: 16),

        // Total Cost dan Join Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Cost: ${controller.formatRupiah(post.totalCost)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            ElevatedButton(
              onPressed: () => controller.joinGame(post.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text('Join Game'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}