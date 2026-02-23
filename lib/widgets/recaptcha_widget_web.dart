import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:js' as js;

/// Web-specific reCAPTCHA widget using direct HTML integration
class RecaptchaWidgetWeb extends StatefulWidget {
  final String siteKey;
  final Function(String token) onVerified;
  final Function(String error)? onError;

  const RecaptchaWidgetWeb({
    super.key,
    required this.siteKey,
    required this.onVerified,
    this.onError,
  });

  @override
  State<RecaptchaWidgetWeb> createState() => _RecaptchaWidgetWebState();
}

class _RecaptchaWidgetWebState extends State<RecaptchaWidgetWeb> {
  final String _viewId = 'recaptcha-container-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _registerView();
  }

  void _registerView() {
    // Register the HTML element
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final container = html.DivElement()
          ..id = 'recaptcha-$viewId'
          ..style.width = '100%'
          ..style.height = '78px';

        // Wait for reCAPTCHA to load (script is in index.html), then render
        _waitForRecaptcha(() {
          try {
            // Correctly access grecaptcha.render method
            final grecaptcha = js.context['grecaptcha'];
            if (grecaptcha == null) {
              throw Exception('grecaptcha object is null');
            }

            grecaptcha.callMethod('render', [
              'recaptcha-$viewId',
              js.JsObject.jsify({
                'sitekey': widget.siteKey,
                'callback': js.allowInterop((String token) {
                  widget.onVerified(token);
                }),
                'error-callback': js.allowInterop(() {
                  if (widget.onError != null) {
                    widget.onError!('reCAPTCHA verification failed');
                  }
                }),
                'expired-callback': js.allowInterop(() {
                  if (widget.onError != null) {
                    widget.onError!('reCAPTCHA expired');
                  }
                }),
              })
            ]);
          } catch (e) {
            if (widget.onError != null) {
              widget.onError!('Failed to render reCAPTCHA: $e');
            }
          }
        });

        return container;
      },
    );
  }

  void _waitForRecaptcha(Function callback, {int attempts = 0}) {
    if (attempts > 50) {
      // Max 5 seconds (50 * 100ms)
      if (widget.onError != null) {
        widget.onError!('reCAPTCHA script failed to load after 5 seconds');
      }
      return;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        if (js.context.hasProperty('grecaptcha')) {
          final grecaptcha = js.context['grecaptcha'];
          if (grecaptcha != null && grecaptcha.hasProperty('render')) {
            callback();
            return;
          }
        }
        _waitForRecaptcha(callback, attempts: attempts + 1);
      } catch (e) {
        _waitForRecaptcha(callback, attempts: attempts + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
