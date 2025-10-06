import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleSearchWebView extends StatefulWidget {
  final String courtName;
  final String courtLocation;

  const GoogleSearchWebView({
    super.key,
    required this.courtName,
    required this.courtLocation,
  });

  @override
  State<GoogleSearchWebView> createState() => _GoogleSearchWebViewState();
}

class _GoogleSearchWebViewState extends State<GoogleSearchWebView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Buat URL Google Maps search dengan data court
    final query = '${widget.courtName}, ${widget.courtLocation}';
    final encodedQuery = Uri.encodeComponent(query);
    final mapsSearchUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedQuery';

    print('Court: ${widget.courtName}');
    print('Location: ${widget.courtLocation}');
    print('Maps URL: $mapsSearchUrl');

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('Loading progress: $progress%');
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.errorCode} - ${error.description}');
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle URL scheme yang tidak supported
            if (request.url.startsWith('geo:') ||
                request.url.startsWith('intent:') ||
                request.url.startsWith('market:')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(mapsSearchUrl));
  }

  void _loadMapsSearch() {
    final query = '${widget.courtName}, ${widget.courtLocation}';
    final encodedQuery = Uri.encodeComponent(query);
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedQuery';
    controller.loadRequest(Uri.parse(mapsUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.courtName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.courtLocation,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView
          WebViewWidget(controller: controller),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      // Minimal navigation
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMapsSearch,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        mini: true,
        child: const Icon(Icons.location_on, size: 20),
      ),
    );
  }
}
