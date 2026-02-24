import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Platform-aware reCAPTCHA widget
/// Uses web-specific implementation for Flutter web, WebView for mobile
class RecaptchaWidget extends StatelessWidget {
  final String siteKey;
  final Function(String token) onVerified;
  final Function(String error)? onError;

  const RecaptchaWidget({
    super.key,
    required this.siteKey,
    required this.onVerified,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    // For web platform, use a placeholder (web reCAPTCHA needs different implementation)
    if (kIsWeb) {
      return _RecaptchaWidgetWeb(
        siteKey: siteKey,
        onVerified: onVerified,
        onError: onError,
      );
    }

    // For mobile platforms, use WebView implementation
    return _RecaptchaWidgetMobile(
      siteKey: siteKey,
      onVerified: onVerified,
      onError: onError,
    );
  }
}

/// Web-specific reCAPTCHA widget placeholder
/// Note: Full web implementation requires dart:html and should be in separate file
class _RecaptchaWidgetWeb extends StatelessWidget {
  final String siteKey;
  final Function(String token) onVerified;
  final Function(String error)? onError;

  const _RecaptchaWidgetWeb({
    required this.siteKey,
    required this.onVerified,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-verify for web temporarily (proper implementation requires dart:html)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onVerified('web-temporary-token');
    });

    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: const Center(
        child: Text(
          'reCAPTCHA (Web Mode)',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

/// Mobile-specific reCAPTCHA widget using WebView
class _RecaptchaWidgetMobile extends StatefulWidget {
  final String siteKey;
  final Function(String token) onVerified;
  final Function(String error)? onError;

  const _RecaptchaWidgetMobile({
    required this.siteKey,
    required this.onVerified,
    this.onError,
  });

  @override
  State<_RecaptchaWidgetMobile> createState() => _RecaptchaWidgetMobileState();
}

class _RecaptchaWidgetMobileState extends State<_RecaptchaWidgetMobile> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (url) {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
          ),
        )
        ..addJavaScriptChannel(
          'RecaptchaChannel',
          onMessageReceived: (JavaScriptMessage message) {
            // Token received from reCAPTCHA
            final token = message.message;
            if (token.startsWith('ERROR:')) {
              if (widget.onError != null) {
                widget.onError!(token.substring(6));
              }
            } else {
              widget.onVerified(token);
            }
          },
        )
        ..loadHtmlString(_getHtmlContent());
    } catch (e) {
      debugPrint('WebView initialization error: $e');
      if (widget.onError != null) {
        widget.onError!('WebView initialization failed');
      }
    }
  }

  String _getHtmlContent() {
    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <script src="https://www.google.com/recaptcha/api.js?render=explicit" async defer></script>
          <style>
            body {
              margin: 0;
              padding: 20px;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              background: transparent;
            }
            #recaptcha-container {
              transform: scale(0.9);
              transform-origin: 0 0;
            }
          </style>
        </head>
        <body>
          <div id="recaptcha-container"></div>
          <script>
            function onRecaptchaSuccess(token) {
              RecaptchaChannel.postMessage(token);
            }

            function onRecaptchaError() {
              RecaptchaChannel.postMessage('ERROR:reCAPTCHA verification failed');
            }

            function onRecaptchaExpired() {
              RecaptchaChannel.postMessage('ERROR:reCAPTCHA expired');
            }

            window.onload = function() {
              grecaptcha.render('recaptcha-container', {
                'sitekey': '${widget.siteKey}',
                'callback': onRecaptchaSuccess,
                'error-callback': onRecaptchaError,
                'expired-callback': onRecaptchaExpired
              });
            };
          </script>
        </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('WebView not available'),
        ),
      );
    }

    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          WebViewWidget(controller: _controller!),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
