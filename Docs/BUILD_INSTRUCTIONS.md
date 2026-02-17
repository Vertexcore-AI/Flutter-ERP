# Build Instructions - Environment Configurations

This project supports multiple build environments (local and production) with different API base URLs.

## Environment Configuration

### Local Environment
- **Base URL:** `http://localhost:8000`
- **Use Case:** Development and local testing
- **Entry Point:** `lib/main_local.dart`

### Production Environment
- **Base URL:** `https://vertexcoreai.com/govi_potha`
- **Use Case:** Production deployment and testing on real devices
- **Entry Point:** `lib/main_production.dart`

## Build Commands

### 1. Local Development Build

#### Web (Chrome)
```bash
flutter run -d chrome -t lib/main_local.dart
```

#### Android Debug (Connected Device/Emulator)
```bash
flutter run -d android -t lib/main_local.dart
```

#### Android Release APK (Local)
```bash
flutter build apk --release -t lib/main_local.dart -o build/app-local-release.apk
```

### 2. Production Build

#### Web (Production)
```bash
flutter run -d chrome -t lib/main_production.dart --release
```

#### Android Debug (Production - for testing)
```bash
flutter run -d android -t lib/main_production.dart
```

#### Android Release APK (Production)
```bash
flutter build apk --release -t lib/main_production.dart -o build/app-production-release.apk
```

#### Android App Bundle (Production - for Play Store)
```bash
flutter build appbundle --release -t lib/main_production.dart
```

### 3. Build for Specific Android Architecture

#### ARM64 (most modern devices)
```bash
flutter build apk --release -t lib/main_production.dart --target-platform android-arm64 -o build/app-production-arm64.apk
```

#### ARM32 (older devices)
```bash
flutter build apk --release -t lib/main_production.dart --target-platform android-arm -o build/app-production-arm.apk
```

#### Universal APK (all architectures - larger file size)
```bash
flutter build apk --release -t lib/main_production.dart --split-per-abi
```

## Quick Commands for Testing

### Test Production Build on Connected Android Device

1. **Connect your Android device via USB**
2. **Enable USB debugging on the device**
3. **Verify device is connected:**
   ```bash
   flutter devices
   ```

4. **Install and run production build:**
   ```bash
   flutter run -d android -t lib/main_production.dart --release
   ```

5. **Or install APK file directly:**
   ```bash
   # Build the APK
   flutter build apk --release -t lib/main_production.dart

   # Install to connected device
   flutter install
   ```

### Build and Share APK for Testing

```bash
# Build production release APK
flutter build apk --release -t lib/main_production.dart

# The APK will be located at:
# build/app/outputs/flutter-apk/app-release.apk

# You can share this APK file for testing on other Android devices
```

## Environment Verification

To verify which environment your app is using, you can check the API endpoint URLs in the app. The app will automatically use the correct base URL based on the entry point:

- **Local:** `http://localhost:8000/api/...`
- **Production:** `https://vertexcoreai.com/govi_potha/api/...`

## File Structure

```
lib/
├── main.dart              # Main app entry point (no environment set)
├── main_local.dart        # Local environment entry point
├── main_production.dart   # Production environment entry point
└── config/
    ├── environment.dart   # Environment configuration
    └── api_config.dart    # API endpoints (uses environment config)
```

## Switching Environments

The environment is automatically set based on which entry point you use:

- Use `-t lib/main_local.dart` for local development
- Use `-t lib/main_production.dart` for production testing/deployment

## Common Issues

### 1. APK Not Installing
- Make sure USB debugging is enabled on your Android device
- Check that "Install from unknown sources" is enabled
- Try uninstalling the previous version first

### 2. Network Errors in Production
- Verify the production URL is correct: `https://vertexcoreai.com/govi_potha`
- Check that your Android device has internet access
- Ensure the backend API is accessible from the internet

### 3. Different APK for Testing vs Production
- Always build separate APKs for testing and production
- Use clear naming: `app-local-release.apk` vs `app-production-release.apk`

## Android Release Build Setup (First Time Only)

If you haven't set up Android signing yet, you'll need to create a keystore:

```bash
# Create keystore (one-time setup)
keytool -genkey -v -keystore ~/my-app-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias

# Create android/key.properties file with:
storePassword=<password>
keyPassword=<password>
keyAlias=my-key-alias
storeFile=<path-to-keystore>
```

For development/testing builds, you can skip this and use debug builds instead of release builds.
