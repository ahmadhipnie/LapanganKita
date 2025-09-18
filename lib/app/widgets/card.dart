import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

class CourtCard extends StatelessWidget {
  final Widget? image;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final String title;
  final String? location;
  final List<String>? types;
  final double? price;
  final String? prefixText;
  final String? suffixText;

  const CourtCard({
    super.key,
    this.image,
    required this.onTap,
    this.onFavorite,
    required this.title,
    this.location,
    this.types,
    this.price,
    this.prefixText,
    this.suffixText,
  });

  String _formatRupiah(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image ?? SizedBox.shrink(),
            // Court Name
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location ?? 'Unknown Location',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Sport Types
                  Wrap(
                    spacing: 8,
                    children:
                        types?.map((type) {
                          return Chip(
                            label: Text(
                              type,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: AppColors.secondary,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList() ??
                        [],
                  ),

                  const SizedBox(height: 12),

                  // Price and Book Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(text: prefixText),
                            TextSpan(
                              text: price != null
                                  ? _formatRupiah(
                                      price!,
                                    ) // Menggunakan format Rupiah
                                  : 'Harga tidak tersedia',
                            ),
                            TextSpan(text: suffixText),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
