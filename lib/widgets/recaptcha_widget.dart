import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Import web implementation only
import 'recaptcha_widget_web.dart' if (dart.library.html) 'recaptcha_widget_web.dart';

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
    if (kIsWeb) {
      // Use web-specific implementation
      return RecaptchaWidgetWeb(
        siteKey: siteKey,
        onVerified: onVerified,
        onError: onError,
      );
    } else {
      // Use mobile WebView implementation
      return _RecaptchaWidgetMobile(
        siteKey: siteKey,
        onVerified: onVerified,
        onError: onError,
      );
    }
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
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isLoading = false);
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
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
