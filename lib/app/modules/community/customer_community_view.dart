import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/modules/community/customer_community_controller.dart';
import 'package:lapangan_kita/app/modules/community/custommer_community_model.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

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

          _ensureSelectedPost(posts);

          final selectedPost = controller.selectedPost.value ?? posts.first;

          return RefreshIndicator(
            onRefresh: controller.refreshPosts,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildFeaturedPost(context, selectedPost),
                const SizedBox(height: 24),
                Text(
                  'Community Posts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ...posts.map((post) {
                  final isSelected =
                      controller.selectedPost.value?.id == post.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPostCard(context, post, isSelected),
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
              child: const Text('Coba lagi'),
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
              'Belum ada post community. Jadilah yang pertama membuat post!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _ensureSelectedPost(List<CommunityPost> posts) {
    if (controller.selectedPost.value != null || posts.isEmpty) return;

    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {
      if (controller.selectedPost.value == null && posts.isNotEmpty) {
        final firstPost = posts.first;
        controller.selectedPost.value = firstPost;
        controller.joinRequests.clear();
        controller.joinRequestsError.value = '';
        controller.fetchJoinRequests(firstPost.id);
      }
    });
  }

  Widget _buildFeaturedPost(BuildContext context, CommunityPost post) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color: AppColors.primary.withValues(alpha: 0.9),
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
                    : () => controller.fetchJoinRequests(post.id),
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
          final requests = controller.joinRequests;
          final errorMessage = controller.joinRequestsError.value;

          if (isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (requests.isEmpty) {
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
            children: requests
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
            color: Colors.black.withValues(alpha: 0.04),
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
                          : () => controller.approveJoinRequest(request),
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
                          : () => controller.rejectJoinRequest(request),
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

  Widget _buildPostCard(
    BuildContext context,
    CommunityPost post,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => _onPostSelected(post),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(post, isSelected),
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
      ),
    );
  }

  Widget _buildCardHeader(CommunityPost post, bool isSelected) {
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
        Wrap(
          spacing: 8,
          children: [
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Selected',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            _buildCategoryChip(post.category),
          ],
        ),
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

      return ElevatedButton(
        onPressed: (isJoining || isFull)
            ? null
            : () => controller.joinGame(post.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
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
            : Text(isFull ? 'Full' : 'Join'),
      );
    });
  }

  void _onPostSelected(CommunityPost post) {
    if (controller.selectedPost.value?.id == post.id) return;

    controller.selectedPost.value = post;
    controller.joinRequests.clear();
    controller.joinRequestsError.value = '';
    controller.fetchJoinRequests(post.id);
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
        color: AppColors.secondary.withValues(alpha: 0.15),
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
