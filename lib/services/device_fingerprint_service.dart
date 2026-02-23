import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DeviceFingerprintService {
  static final DeviceFingerprintService _instance =
      DeviceFingerprintService._internal();
  factory DeviceFingerprintService() => _instance;
  DeviceFingerprintService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Generate device fingerprint map
  Future<Map<String, String>> generateFingerprint() async {
    try {
      if (kIsWeb) {
        // Web platform
        final webInfo = await _deviceInfo.webBrowserInfo;
        return {
          'deviceId': 'web-${webInfo.userAgent?.hashCode ?? 'unknown'}',
          'deviceModel': webInfo.browserName.name,
          'deviceOs': '${webInfo.platform ?? 'Web'} ${webInfo.appVersion ?? ''}',
        };
      } else {
        // Try to detect mobile platforms
        try {
          final androidInfo = await _deviceInfo.androidInfo;
          return {
            'deviceId': androidInfo.id,
            'deviceModel': '${androidInfo.manufacturer} ${androidInfo.model}',
            'deviceOs': 'Android ${androidInfo.version.release}',
          };
        } catch (e) {
          // If not Android, try iOS
          try {
            final iosInfo = await _deviceInfo.iosInfo;
            return {
              'deviceId': iosInfo.identifierForVendor ?? 'unknown',
              'deviceModel': '${iosInfo.model} ${iosInfo.name}',
              'deviceOs': 'iOS ${iosInfo.systemVersion}',
            };
          } catch (e) {
            // Fallback for other platforms
            return {
              'deviceId': 'unknown-device-${DateTime.now().millisecondsSinceEpoch}',
              'deviceModel': 'Unknown Device',
              'deviceOs': 'Unknown OS',
            };
          }
        }
      }
    } catch (e) {
      // Ultimate fallback
      return {
        'deviceId': 'fallback-${DateTime.now().millisecondsSinceEpoch}',
        'deviceModel': 'Generic Device',
        'deviceOs': 'Unknown',
      };
    }
  }

  /// Generate hash of fingerprint (for local comparison)
  String hashFingerprint(Map<String, String> fingerprint) {
    final combined =
        '${fingerprint['deviceId']}|${fingerprint['deviceModel']}|${fingerprint['deviceOs']}';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
