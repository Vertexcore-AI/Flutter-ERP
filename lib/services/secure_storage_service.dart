import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Keys
  static const String _keyDeviceFingerprintHash = 'device_fingerprint_hash';
  static const String _keyDeviceTrusted = 'device_trusted';
  static const String _keyAuthToken = 'auth_token';

  // Device fingerprint hash
  Future<void> saveDeviceFingerprintHash(String hash) async {
    await _storage.write(key: _keyDeviceFingerprintHash, value: hash);
  }

  Future<String?> getDeviceFingerprintHash() async {
    return await _storage.read(key: _keyDeviceFingerprintHash);
  }

  // Device trust status
  Future<void> setDeviceTrusted(bool trusted) async {
    await _storage.write(key: _keyDeviceTrusted, value: trusted.toString());
  }

  Future<bool> isDeviceTrusted() async {
    final value = await _storage.read(key: _keyDeviceTrusted);
    return value == 'true';
  }

  // Auth token (replace SharedPreferences)
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _keyAuthToken);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
