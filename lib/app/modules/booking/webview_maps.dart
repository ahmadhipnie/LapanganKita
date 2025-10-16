import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _requestLocationPermission();
    _initializeWebView();
  }

  /// Request location permission early
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;

    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  void _initializeWebView() {
    final query = '${widget.courtName}, ${widget.courtLocation}';
    final encodedQuery = Uri.encodeComponent(query);
    final mapsSearchUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedQuery';

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() => isLoading = true);
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => isLoading = false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() => isLoading = false);
              _showErrorSnackBar('Failed to load map: ${error.description}');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Intercept Google Maps app links and directions
            if (request.url.startsWith('intent://') ||
                request.url.startsWith('geo:') ||
                request.url.contains('maps.app.goo.gl') ||
                request.url.contains('google.com/maps/dir') ||
                request.url.contains('google.navigation:') ||
                request.url.contains('comgooglemaps://')) {
              _launchExternalUrl(request.url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(mapsSearchUrl));

    // Setup geolocation for Android
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController androidController =
          controller.platform as AndroidWebViewController;

      androidController.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (request) async {
          var status = await Permission.location.status;

          if (!status.isGranted) {
            status = await Permission.location.request();
          }

          return GeolocationPermissionsResponse(
            allow: status.isGranted,
            retain: true,
          );
        },
      );
    }
  }

  /// Launch external URL with Google Maps app or browser
  Future<void> _launchExternalUrl(String url) async {
    try {
      String targetUrl = url;

      if (url.startsWith('intent://')) {
        final uri = Uri.parse(url);
        final package = uri.queryParameters['package'];

        if (package == 'com.google.android.apps.maps') {
          targetUrl = url.replaceFirst('intent://', 'https://');
          targetUrl = targetUrl.split('#Intent')[0];

          if (url.contains('dir/')) {
            final query = '${widget.courtName}, ${widget.courtLocation}';
            final encodedQuery = Uri.encodeComponent(query);
            targetUrl =
                'https://www.google.com/maps/dir/?api=1&destination=$encodedQuery';
          }
        }
      }

      final uri = Uri.parse(targetUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Cannot open Google Maps');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open map: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.courtName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              widget.courtLocation,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 0,
        actions: [
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 24),
            onPressed: () => controller.reload(),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Container(
              color: colorScheme.surface.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Loading map...',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
