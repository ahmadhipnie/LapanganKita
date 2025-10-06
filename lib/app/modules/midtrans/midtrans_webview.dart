import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebView extends StatefulWidget {
  final String snapUrl;
  final String orderId;

  const MidtransWebView({
    super.key,
    required this.snapUrl,
    required this.orderId,
  });

  @override
  State<MidtransWebView> createState() => _MidtransWebViewState();
}

class _MidtransWebViewState extends State<MidtransWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            _checkPaymentStatus(url);
          },
          onWebResourceError: (error) {
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.snapUrl));
  }

  void _checkPaymentStatus(String url) {
    // Check if URL contains finish redirect
    if (url.contains('status_code=200') || url.contains('transaction_status=settlement')) {
      // Success
      Navigator.of(context).pop({
        'status': 'success',
        'order_id': widget.orderId,
      });
    } else if (url.contains('status_code=201') || url.contains('transaction_status=pending')) {
      // Pending
      Navigator.of(context).pop({
        'status': 'pending',
        'order_id': widget.orderId,
      });
    } else if (url.contains('status_code=202') || 
               url.contains('transaction_status=deny') ||
               url.contains('transaction_status=cancel') ||
               url.contains('transaction_status=expire')) {
      // Failed
      Navigator.of(context).pop({
        'status': 'failed',
        'order_id': widget.orderId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button - consider it as cancelled
        Navigator.of(context).pop({
          'status': 'cancelled',
          'order_id': widget.orderId,
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Payment',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1976D2),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _showCancelConfirmation();
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading payment page...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text('Are you sure you want to cancel this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop({
                'status': 'cancelled',
                'order_id': widget.orderId,
              }); // Close webview
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}