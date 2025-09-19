import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/modules/community/customer_community_controller.dart';
import 'package:lapangan_kita/app/modules/community/custommer_community_model.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

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
      ),
      body: Obx(
        () => ListView.builder(
          controller: controller.scrollController,
          padding: EdgeInsets.all(16),
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final post = controller.posts[index];
            return _buildPostCard(post);
          },
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan profile, nama, waktu - menggunakan Stack untuk category
            Stack(
              children: [
                Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: post.userProfileImage,
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
                    // Container category dihapus dari sini
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
        ),
      ),
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

  Widget _buildFloatingButton() {
    return Obx(
      () => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: controller.isScrolled.value ? 140 : 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: BorderRadius.circular(
            controller.isScrolled.value ? 28 : 56,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Get.toNamed('/create-post');
          },
          borderRadius: BorderRadius.circular(
            controller.isScrolled.value ? 28 : 56,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 24),
              if (controller.isScrolled.value) ...[
                SizedBox(width: 4), // Kurangi spacing
                Flexible(
                  // Gunakan Flexible
                  child: FittedBox(
                    // Scale text jika perlu
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Create Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
