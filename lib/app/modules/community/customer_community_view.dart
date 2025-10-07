import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/modules/community/customer_community_controller.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

import '../../data/models/customer/community/community_post_model.dart';
import '../../data/models/customer/community/join_request_model.dart';

class CustomerCommunityView extends GetView<CustomerCommunityController> {
  CustomerCommunityView({super.key});

  final ApiClient _apiClient = Get.find<ApiClient>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        title: const Text('Community'),
        elevation: 0,
        backgroundColor: AppColors.neutralColor,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshPosts,
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = controller.posts;

          if (controller.hasError.value && posts.isEmpty) {
            final message = controller.errorMessage.value;
            return _buildErrorState(message);
          }

          if (posts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: controller.refreshPosts,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // SECTION 1: Featured Post by ID dari local storage
                _buildFeaturedPostSection(context),
                const SizedBox(height: 24),

                // SECTION 2: All Community Posts (tanpa featured post)
                Text(
                  'Community Posts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ...posts.map((post) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPostCard(context, post),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 48, color: Colors.grey[500]),
            const SizedBox(height: 12),
            Text(
              message.isEmpty ? 'Tidak dapat memuat data community.' : message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.refreshPosts,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.forum_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No community posts yet. Be the first to create one!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION 1: Featured Post by ID dari local storage
  Widget _buildFeaturedPostSection(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingFeaturedPost.value) {
        return _buildFeaturedPostSkeleton();
      }

      final featuredPosts = controller.featuredPosts;
      if (featuredPosts.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Posts',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${featuredPosts.length} POST${featuredPosts.length > 1 ? 'S' : ''}',
                          style: TextStyle(
                            color: Colors.amber[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Featured posts list
            ...featuredPosts.map((post) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildFeaturedPost(context, post),
              );
            }),
          ],
        );
      } else {
        return _buildNoFeaturedPost();
      }
    });
  }

  Widget _buildFeaturedPostSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton header
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundColor: Colors.grey[300]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 16, color: Colors.grey[300]),
                    const SizedBox(height: 4),
                    Container(width: 80, height: 12, color: Colors.grey[300]),
                  ],
                ),
              ),
              Container(width: 60, height: 24, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(height: 16),
          Container(width: 200, height: 20, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 16,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Container(width: 150, height: 14, color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildNoFeaturedPost() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.featured_play_list, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'My Posts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t created any posts yet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFeaturedPost(BuildContext context, CommunityPost post) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured badge untuk setiap post
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber[700], size: 16),
                const SizedBox(width: 4),
                Text(
                  'MY POST',
                  style: TextStyle(
                    color: Colors.amber[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildPostHeader(post),
          const SizedBox(height: 16),
          Text(
            post.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.subtitle,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildLocationTile(post),
          const SizedBox(height: 16),
          _buildMetaDetails(post),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Total Cost',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              Text(
                controller.formatRupiah(post.totalCost),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildJoinRequestsSection(post),
        ],
      ),
    );
  }

  Widget _buildPostHeader(CommunityPost post) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(post.userProfileImage, radius: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                post.timeAgo,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        _buildCategoryChip(post.category),
      ],
    );
  }

  Widget _buildLocationTile(CommunityPost post) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color: AppColors.primary.withOpacity(0.9),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              post.courtName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaDetails(CommunityPost post) {
    final dateLabel = DateFormat('dd MMM yyyy').format(post.gameDate);
    final infoTextStyle = TextStyle(color: Colors.grey[700], fontSize: 13);

    return Column(
      children: [
        Row(
          children: [
            _buildMetaItem(Icons.calendar_today, dateLabel, infoTextStyle),
            const SizedBox(width: 16),
            _buildMetaItem(Icons.access_time, post.gameTime, infoTextStyle),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetaItem(
              Icons.people_alt,
              '${post.joinedPlayers}/${post.playersNeeded} pemain',
              infoTextStyle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaItem(IconData icon, String text, TextStyle style) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }

  Widget _buildJoinRequestsSection(CommunityPost post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Permintaan Bergabung',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            Obx(() {
              final isLoading = controller.isLoadingJoinRequests.value;
              return IconButton(
                onPressed: isLoading
                    ? null
                    : () => controller.loadAllJoinRequests(),
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Muat ulang',
              );
            }),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final isLoading = controller.isLoadingJoinRequests.value;
          final allRequests = controller.joinRequests;
          final errorMessage = controller.joinRequestsError.value;

          // Filter join requests for this specific booking
          final bookingRequests = allRequests
              .where((request) => request.bookingId == post.bookingId)
              .toList();

          if (isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (bookingRequests.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neutralColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                errorMessage.isNotEmpty
                    ? errorMessage
                    : 'Belum ada permintaan bergabung.',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            );
          }

          return Column(
            children: bookingRequests
                .map(
                  (request) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildJoinRequestTile(request),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildJoinRequestTile(JoinRequest request) {
    final formattedTime = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(request.requestedAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(request.avatarUrl ?? '', radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.formattedGender} • ${request.age} tahun • ${request.userEmail}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    if (request.note?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        request.note!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildStatusChip(request.status),
            ],
          ),
          if (request.isPending) ...[
            const SizedBox(height: 16),
            Obx(() {
              final isProcessing = controller.isProcessingDecision(request.id);
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => controller.handleJoinRequestAction(
                              request.id,
                              'approved',
                            ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => controller.handleJoinRequestAction(
                              request.id,
                              'rejected',
                            ),
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: isProcessing ? Colors.grey : Colors.red,
                      ),
                      label: Text(
                        'Reject',
                        style: TextStyle(
                          color: isProcessing ? Colors.grey : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isProcessing
                              ? Colors.grey.shade300
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final normalized = status.toLowerCase();

    Color backgroundColor;
    Color textColor;
    String label;

    switch (normalized) {
      case 'approved':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Approved';
        break;
      case 'rejected':
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = 'Rejected';
        break;
      default:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, CommunityPost post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(post),
          const SizedBox(height: 12),
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetaChip(
                Icons.calendar_today,
                DateFormat('dd MMM').format(post.gameDate),
              ),
              const SizedBox(width: 8),
              _buildMetaChip(Icons.access_time, post.gameTime),
              const SizedBox(width: 8),
              _buildMetaChip(
                Icons.people_outline,
                '${post.joinedPlayers}/${post.playersNeeded}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Cost',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.formatRupiah(post.totalCost),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              _buildJoinButton(post),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(CommunityPost post) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(post.userProfileImage, radius: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                post.timeAgo,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        _buildCategoryChip(post.category),
      ],
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutralColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildJoinButton(CommunityPost post) {
    return Obx(() {
      final isJoining = controller.isJoining(post.id);
      final isFull = post.joinedPlayers >= post.playersNeeded;

      // Check user's join request status for this booking
      final userJoinRequest = controller.joinRequests.firstWhereOrNull(
        (request) =>
            request.bookingId == post.bookingId &&
            request.userId == controller.currentUserId,
      );

      // Determine button state based on join request status
      String buttonText;
      Color backgroundColor;
      Color foregroundColor;
      bool isEnabled;

      if (userJoinRequest != null) {
        switch (userJoinRequest.status) {
          case 'pending':
            buttonText = 'Pending';
            backgroundColor = Colors.orange;
            foregroundColor = Colors.white;
            isEnabled = false;
            break;
          case 'approved':
            buttonText = 'Approved';
            backgroundColor = Colors.green;
            foregroundColor = Colors.white;
            isEnabled = false;
            break;
          case 'rejected':
            buttonText = 'Rejected';
            backgroundColor = Colors.red;
            foregroundColor = Colors.white;
            isEnabled = false;
            break;
          default:
            buttonText = isFull ? 'Full' : 'Join';
            backgroundColor = AppColors.primary;
            foregroundColor = Colors.white;
            isEnabled = !isJoining && !isFull;
        }
      } else {
        buttonText = isFull ? 'Full' : 'Join';
        backgroundColor = AppColors.primary;
        foregroundColor = Colors.white;
        isEnabled = !isJoining && !isFull;
      }

      return ElevatedButton(
        onPressed: (isJoining || !isEnabled)
            ? null
            : () => controller.joinGame(post.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: isJoining
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(buttonText),
      );
    });
  }

  Widget _buildAvatar(String imagePath, {double radius = 18}) {
    final imageUrl = _apiClient.getImageUrl(imagePath);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, provider) => CircleAvatar(
        radius: radius,
        backgroundImage: provider,
        backgroundColor: Colors.grey[300],
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, color: Colors.grey[600], size: radius),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
