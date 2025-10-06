import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MidtransService {
  static MidtransService? _instance;
  static MidtransService get instance {
    _instance ??= MidtransService._();
    return _instance!;
  }

  MidtransService._();

  // Generate Snap Token via Midtrans API
  Future<String> createSnapToken({
    required String orderId,
    required double grossAmount,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> customerDetails,
  }) async {
    try {
      final serverKey = dotenv.env['MIDTRANS_SERVER_KEY'] ?? '';
      final isProduction = dotenv.env['MIDTRANS_IS_PRODUCTION'] == 'true';
      
      final snapUrl = isProduction
          ? 'https://app.midtrans.com/snap/v1/transactions'
          : 'https://app.sandbox.midtrans.com/snap/v1/transactions';

      final auth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';

      final dio = Dio();
      final response = await dio.post(
        snapUrl,
        data: {
          'transaction_details': {
            'order_id': orderId,
            'gross_amount': grossAmount,
          },
          'item_details': items,
          'customer_details': customerDetails,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': auth,
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['token'] ?? '';
      }
      
      throw Exception('Failed to create snap token: ${response.statusCode}');
    } catch (e) {
      print('Error creating snap token: $e');
      rethrow;
    }
  }

  // Get Snap URL from token
  String getSnapUrl(String snapToken) {
    final isProduction = dotenv.env['MIDTRANS_IS_PRODUCTION'] == 'true';
    
    if (isProduction) {
      return 'https://app.midtrans.com/snap/v2/vtweb/$snapToken';
    } else {
      return 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken';
    }
  }
}