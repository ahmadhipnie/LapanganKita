import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ✅ IMPORT INI PENTING untuk geolocation
import 'package:webview_flutter_android/webview_flutter_android.dart';

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
  Position? currentPosition;
  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    // ✅ Request permission dulu sebelum init WebView
    _requestLocationPermission();
    _initializeWebView();
  }

  /// Request location permission early
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    print('📍 Initial location permission status: $status');

    if (!status.isGranted) {
      status = await Permission.location.request();
      print('📍 After request location permission status: $status');
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
          onProgress: (int progress) {
            // Optional: Update progress indicator
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
              _showErrorSnackBar('Failed to load map: ${error.description}');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
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

    // ✅ TAMBAHKAN GEOLOCATION PERMISSION HANDLING
    // Ini adalah kode penting yang memungkinkan WebView akses lokasi
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController androidController =
          controller.platform as AndroidWebViewController;

      print('✅ Setting up geolocation callbacks for Android WebView');

      androidController.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (request) async {
          // Debug: Log ketika callback dipanggil
          print('🔔 Geolocation prompt called!');
          print('🔔 Origin: ${request.origin}');

          // Cek status permission saat ini
          var status = await Permission.location.status;
          print('📍 Current permission status: $status');

          // Jika belum granted, request permission
          if (!status.isGranted) {
            status = await Permission.location.request();
            print('📍 Permission after request: $status');
          }

          // Buat response untuk WebView
          final response = GeolocationPermissionsResponse(
            allow: status.isGranted,
            retain: true, // Simpan keputusan user
          );

          print(
            '✅ Geolocation response: allow=${response.allow}, retain=${response.retain}',
          );
          return response;
        },
      );
    } else {
      print('⚠️ Platform is not Android, geolocation callback not set');
    }
  }

  /// Request location permission and get current position
  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      // Check permission
      final permission = await Permission.location.status;
      if (permission.isDenied) {
        final result = await Permission.location.request();
        if (result.isDenied) {
          _showErrorSnackBar('Location permission denied');
          setState(() {
            isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission.isPermanentlyDenied) {
        _showPermissionDialog();
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      setState(() {
        currentPosition = position;
        isLoadingLocation = false;
      });

      // Load maps with current location
      _loadMapsWithLocation(position);
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
      });
      _showErrorSnackBar('Failed to get location: $e');
    }
  }

  /// Load maps with current location
  void _loadMapsWithLocation(Position position) {
    final query = '${widget.courtName}, ${widget.courtLocation}';
    final encodedQuery = Uri.encodeComponent(query);
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedQuery'
        '&center=${position.latitude},${position.longitude}';
    controller.loadRequest(Uri.parse(mapsUrl));
  }

  /// Load maps search with default query
  void _loadMapsSearch() {
    final query = '${widget.courtName}, ${widget.courtLocation}';
    final encodedQuery = Uri.encodeComponent(query);
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedQuery';
    controller.loadRequest(Uri.parse(mapsUrl));
  }

  /// Show error snackbar
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

  /// Show permission dialog
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.location_off, size: 48),
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location permission to show directions. '
          'Please enable location permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
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
          if (isLoading || isLoadingLocation)
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
            onPressed: () {
              controller.reload();
            },
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
      bottomNavigationBar: BottomAppBar(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: isLoadingLocation ? null : _getCurrentLocation,
                icon: isLoadingLocation
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      )
                    : const Icon(Icons.my_location_rounded, size: 20),
                label: const Text('My Location'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _loadMapsSearch,
                icon: const Icon(Icons.search_rounded, size: 20),
                label: const Text('Search'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: currentPosition != null
          ? FloatingActionButton.extended(
              onPressed: () {
                final query = '${widget.courtName}, ${widget.courtLocation}';
                final encodedQuery = Uri.encodeComponent(query);
                final directionsUrl =
                    'https://www.google.com/maps/dir/?api=1'
                    '&origin=${currentPosition!.latitude},${currentPosition!.longitude}'
                    '&destination=$encodedQuery';
                controller.loadRequest(Uri.parse(directionsUrl));
              },
              icon: const Icon(Icons.directions_rounded),
              label: const Text('Directions'),
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            )
          : null,
    );
  }
}
