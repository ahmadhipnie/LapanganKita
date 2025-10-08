import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_controller.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';
import 'package:lapangan_kita/app/widgets/card.dart';
import '../../data/network/api_client.dart';

class CustomerBookingView extends GetView<CustomerBookingController> {
  const CustomerBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        backgroundColor: AppColors.neutralColor,
        actionsPadding: const EdgeInsets.only(right: 16),
        title: const Text(
          'Available Courts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.allCourts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError.value && controller.allCourts.isEmpty) {
            return _buildErrorWidget();
          }

          return RefreshIndicator(
            onRefresh: () => controller.refreshData(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 12),
                        _buildFilterRow(),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: Obx(() {
                    final filteredCourts = controller.filteredCourts;

                    if (filteredCourts.isEmpty && !controller.isLoading.value) {
                      return SliverFillRemaining(child: _buildNoDataMessage());
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final court = filteredCourts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CourtCard(
                            key: ValueKey('${court.id}_$index'),
                            image: _buildCachedImage(court.imageUrl),
                            title: court.name,
                            location: court.placeName,
                            types: court.types,
                            prefixText: 'Start from ',
                            price: court.price,
                            suffixText: ' / hour',
                            onTap: () {
                              Get.toNamed(
                                '/customer/booking/detail',
                                arguments: court,
                              );
                            },
                          ),
                        );
                      }, childCount: filteredCourts.length),
                    );
                  }),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              controller.errorMessage.value,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.refreshData(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCachedImage(String imagePath) {
    final ApiClient apiClient = Get.find();
    final imageUrl = apiClient.getImageUrl(imagePath);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          color: Colors.grey[300],
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          color: Colors.grey[200],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Court Image',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Image not available',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
      fit: BoxFit.cover,
      width: double.infinity,
      height: 200,
    );
  }

  Widget _buildSearchBar() {
    return SearchBar(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      elevation: WidgetStateProperty.all(3),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16),
      ),
      hintText: 'Search courts, categories, or locations...',
      leading: const Icon(Icons.search),
      trailing: [
        Obx(
          () => controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clearSearch();
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
      onChanged: (value) {
        controller.searchQuery.value = value;
      },
      controller: controller.searchController,
    );
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data yang cocok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba kata kunci lain atau atur filter berbeda',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.searchQuery.value.isNotEmpty ||
                controller.selectedCategory.value.isNotEmpty ||
                controller.selectedLocation.value.isNotEmpty ||
                controller.minPriceController.text.isNotEmpty ||
                controller.maxPriceController.text.isNotEmpty) {
              return ElevatedButton(
                onPressed: () => controller.clearFilters(),
                child: const Text('Hapus Semua Filter'),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All',
                    isSelected: controller.selectedCategory.value.isEmpty,
                    onSelected: (_) => controller.clearFilters(),
                  ),
                  const SizedBox(width: 8),
                  ...controller.availableCategories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(
                        label: category,
                        isSelected:
                            controller.selectedCategory.value == category,
                        onSelected: (_) =>
                            controller.setCategoryFilter(category),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          IconButton(
            hoverColor: AppColors.primary,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            onPressed: () => _showFilterDialog(Get.context!),
          ),
        ],
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.secondary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[800],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Reset controller text dengan nilai saat ini
    controller.locationController.text = controller.selectedLocation.value;

    showDialog(
      context: context,
      builder: (context) {
        return _FilterDialogContent(controller: controller);
      },
    );
  }
}

// ✅ STATEFUL WIDGET UNTUK DIALOG FILTER - MATERIAL 3 MINIMALIS
class _FilterDialogContent extends StatefulWidget {
  final CustomerBookingController controller;

  const _FilterDialogContent({required this.controller});

  @override
  State<_FilterDialogContent> createState() => _FilterDialogContentState();
}

class _FilterDialogContentState extends State<_FilterDialogContent> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ HEADER MINIMALIS
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Filter Courts',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ✅ DIVIDER SUBTLE
            Divider(height: 1, thickness: 1, color: Colors.grey[200]),

            // ✅ CONTENT (SCROLLABLE)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationFilterTextField(),
                    const SizedBox(height: 24),
                    _buildCategoryFilter(),
                    const SizedBox(height: 24),
                    _buildPriceFilter(),
                  ],
                ),
              ),
            ),

            // ✅ FOOTER MINIMALIS
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.controller.clearFilters();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        widget.controller.applyFilters();
                        Get.back();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ LOCATION FILTER - MATERIAL 3 STYLE
  Widget _buildLocationFilterTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Section
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Location',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),

        // Text Field
        TextField(
          controller: widget.controller.locationController,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search by city or location',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.grey[400],
              size: 22,
            ),
            suffixIcon: widget.controller.locationController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        widget.controller.locationController.clear();
                        widget.controller.selectedLocation.value = '';
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onChanged: (value) {
            setState(() {
              widget.controller.selectedLocation.value = value.trim();
            });
          },
        ),

        // Location Suggestions
        Obx(() {
          if (widget.controller.availableLocations.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.controller.availableLocations.map((location) {
                final isSelected =
                    widget.controller.selectedLocation.value == location;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        widget.controller.locationController.text = location;
                        widget.controller.selectedLocation.value = location;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.3)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_city_rounded,
                            size: 16,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  // ✅ CATEGORY FILTER - MATERIAL 3 STYLE
  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Section
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(Icons.category_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),

        // Categories
        Obx(() {
          if (widget.controller.availableCategories.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'No categories available',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.controller.availableCategories.map((category) {
              final isSelected =
                  widget.controller.selectedCategory.value == category;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    widget.controller.setCategoryFilter(
                      isSelected ? '' : category,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondary
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[700],
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // ✅ PRICE FILTER - MATERIAL 3 STYLE
  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Section
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(Icons.payments_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Price Range',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),

        // Price Inputs
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller.minPriceController,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Min',
                  labelStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixText: 'Rp ',
                  prefixStyle: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 24,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: widget.controller.maxPriceController,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Max',
                  labelStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: '∞',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixText: 'Rp ',
                  prefixStyle: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
