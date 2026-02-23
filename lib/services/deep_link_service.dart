import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link listener (warm start)
  Future<void> initialize() async {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debugPrint('🔗 Deep link received: $uri');
        _handleDeepLink(uri);
      },
      onError: (Object err) {
        debugPrint('❌ Deep link error: $err');
      },
    );
  }

  /// Get initial deep link (cold start)
  Future<Uri?> getInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        debugPrint('🔗 Initial deep link: $uri');
      }
      return uri;
    } catch (e) {
      debugPrint('❌ Failed to get initial link: $e');
      return null;
    }
  }

  /// Parse and handle deep link
  void _handleDeepLink(Uri uri) {
    // Expected URLs:
    // - https://vertexcoreai.com/govi_potha/verify-email?token=XXXXX
    // - http://localhost:8000/govi_potha/verify-email?token=XXXXX (dev)

    if (uri.path == '/govi_potha/verify-email' ||
        uri.path.endsWith('/verify-email')) {
      final token = uri.queryParameters['token'];

      if (token != null && token.isNotEmpty) {
        debugPrint('✅ Valid verification token found: ${token.substring(0, 10)}...');
        _navigateToVerification?.call(token);
      } else {
        debugPrint('⚠️ Deep link missing token parameter');
      }
    } else {
      debugPrint('⚠️ Unhandled deep link path: ${uri.path}');
    }
  }

  /// Navigation callback (set from main.dart)
  Function(String token)? _navigateToVerification;

  void setNavigationCallback(Function(String token) callback) {
    _navigateToVerification = callback;
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}
