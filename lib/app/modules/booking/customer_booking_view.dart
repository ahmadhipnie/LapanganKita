import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_controller.dart';
import 'package:lapangan_kita/app/widgets/card.dart';

class CustomerBookingView extends GetView<CustomerBookingController> {
  const CustomerBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.only(right: 16),
        title: const Text(
          'Available Courts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
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
                // Courts List dengan builder untuk efisiensi
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: Obx(() {
                    final filteredCourts = controller.filteredCourts;

                    if (filteredCourts.isEmpty) {
                      return SliverFillRemaining(child: _buildNoDataMessage());
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final court = filteredCourts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CourtCard(
                            key: ValueKey('${court.name}_$index'),
                            image: controller.getTimestampedImageUrl(
                              court.imageUrl,
                            ),
                            title: court.name,
                            location: court.location,
                            types: court.types,
                            prefixText: 'Start from ',
                            price: court.price,
                            suffixText: ' / hour',
                            onTap: () {
                              Get.toNamed('/court-detail', arguments: court);
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

  Widget _buildSearchBar() {
    return SearchBar(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      elevation: WidgetStateProperty.all(3),
      padding: WidgetStateProperty.all<EdgeInsets>(
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
    return Builder(
      builder: (builderContext) {
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
              hoverColor: Color(0xff2563EB),
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(builderContext),
            ),
          ],
        );
      },
    );
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
      selectedColor: Colors.blue[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue[800] : Colors.grey[800],
      ),
    );
  }

  Widget _buildPriceFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.minPriceController,
                decoration: const InputDecoration(
                  labelText: 'Min Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller.maxPriceController,
                decoration: const InputDecoration(
                  labelText: 'Max Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Obx(() {
          return AlertDialog(
            title: const Text('Filters'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filter Lokasi
                _buildLocationFilter(),
                const SizedBox(height: 16),

                // Filter Harga
                _buildPriceFilter(context),
                const SizedBox(height: 16),

                // Filter Kategori
                _buildCategoryFilter(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => controller.clearFilters(),
                child: const Text('Reset'),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.applyFilters();
                  Get.back();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: controller.selectedLocation.value.isEmpty
              ? null
              : controller.selectedLocation.value,
          items: [
            const DropdownMenuItem(value: '', child: Text('All Locations')),
            ...controller.availableLocations.map((location) {
              return DropdownMenuItem(value: location, child: Text(location));
            }),
          ],
          onChanged: (value) => controller.setLocationFilter(value ?? ''),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            runAlignment: WrapAlignment.start,
            spacing: 8,

            children: controller.availableCategories.map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: controller.selectedCategory.value == category,
                onSelected: (_) => controller.setCategoryFilter(
                  controller.selectedCategory.value == category ? '' : category,
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}
