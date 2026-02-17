# Environment Setup - Complete Summary

## ✅ What Was Created

I've set up a complete environment configuration system that allows you to build separate versions of your app for **local development** and **production** with different API base URLs.

## 📁 New Files Created

### 1. Configuration Files
- **`lib/config/environment.dart`** - Environment configuration (local/production)
- **`lib/main_local.dart`** - Entry point for local builds
- **`lib/main_production.dart`** - Entry point for production builds

### 2. Updated Files
- **`lib/config/api_config.dart`** - Now uses environment-based URLs

### 3. Documentation
- **`BUILD_INSTRUCTIONS.md`** - Complete build instructions
- **`QUICK_BUILD_GUIDE.md`** - Quick reference guide
- **`ENVIRONMENT_SETUP_SUMMARY.md`** - This file

### 4. Build Scripts
- **`build-production.bat`** - Windows build script
- **`build-production.sh`** - Mac/Linux build script

## 🎯 Environment Configuration

### Local Environment
```
Base URL: http://localhost:8000
API Prefix: /api
Entry Point: lib/main_local.dart
```

**Example URLs:**
- `http://localhost:8000/api/auth/login`
- `http://localhost:8000/api/farms`

### Production Environment
```
Base URL: https://vertexcoreai.com/govi_potha
API Prefix: /api
Entry Point: lib/main_production.dart
```

**Example URLs:**
- `https://vertexcoreai.com/govi_potha/api/auth/login`
- `https://vertexcoreai.com/govi_potha/api/farms`

## 🚀 How to Build Production APK for Android Testing

### Option 1: Quick Command (Recommended)

```bash
# Windows
build-production.bat

# Mac/Linux
bash build-production.sh
```

### Option 2: Manual Flutter Command

```bash
flutter build apk --release -t lib/main_production.dart
```

The APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Option 3: Build and Install Directly

```bash
# Connect your Android device via USB
# Run this command to build and install in one step
flutter run -d android -t lib/main_production.dart --release
```

## 📱 Testing on Android Device

### Step 1: Enable Developer Mode
1. Go to **Settings** > **About Phone**
2. Tap **Build Number** 7 times
3. Go to **Settings** > **Developer Options**
4. Enable **USB Debugging**

### Step 2: Connect Device
```bash
# Verify device is connected
flutter devices

# Should show something like:
# Android SDK built for x86 (mobile) • emulator-5554 • android-x86
# SAMSUNG SM-G950F (mobile) • 1234567890ABCDEF • android-arm64
```

### Step 3: Build and Install
```bash
# Build and install production version
flutter run -d android -t lib/main_production.dart --release
```

OR

```bash
# Build APK file
flutter build apk --release -t lib/main_production.dart

# Transfer app-release.apk to your phone
# Install manually by opening the file on your Android device
```

## 🔄 Switching Between Environments

### Run Local Version (for development)
```bash
# Web
flutter run -d chrome -t lib/main_local.dart

# Android
flutter run -d android -t lib/main_local.dart
```

### Run Production Version (for testing)
```bash
# Web
flutter run -d chrome -t lib/main_production.dart

# Android
flutter run -d android -t lib/main_production.dart --release
```

## 🛠️ How It Works

### 1. Environment Configuration (`lib/config/environment.dart`)
```dart
enum Environment { local, production }

class EnvironmentConfig {
  static String get baseUrl {
    switch (_environment) {
      case Environment.local:
        return 'http://localhost:8000';
      case Environment.production:
        return 'https://vertexcoreai.com/govi_potha';
    }
  }
}
```

### 2. API Configuration (`lib/config/api_config.dart`)
```dart
class ApiConfig {
  // Automatically uses environment-based URL
  static String get baseUrl => EnvironmentConfig.baseUrl;

  // All endpoints automatically use correct base URL
  static String get login => '$baseUrl/api/auth/login';
  static String get farms => '$baseUrl/api/farms';
}
```

### 3. Entry Points
- **`lib/main_local.dart`** - Sets environment to LOCAL, then runs app
- **`lib/main_production.dart`** - Sets environment to PRODUCTION, then runs app

## ✅ Verification

The configuration has been tested and verified:
```bash
$ flutter analyze lib/config/environment.dart lib/config/api_config.dart lib/main_local.dart lib/main_production.dart
No issues found! ✓
```

## 🎉 You're Ready!

You can now:
1. ✅ Build production APKs with production URL
2. ✅ Build local APKs with localhost URL
3. ✅ Test on Android devices
4. ✅ Share APK files with others
5. ✅ Switch environments easily

## 📞 Quick Commands Cheat Sheet

```bash
# Build production APK (Windows)
build-production.bat

# Build production APK (Mac/Linux)
bash build-production.sh

# Run production on connected Android device
flutter run -d android -t lib/main_production.dart --release

# Run local development (Web)
flutter run -d chrome -t lib/main_local.dart

# Check connected devices
flutter devices

# Clean build (if you encounter issues)
flutter clean && flutter pub get
```

## 🔗 Production API Endpoints

Your app will automatically use these endpoints in production:

- **Login:** `https://vertexcoreai.com/govi_potha/api/auth/login`
- **Register:** `https://vertexcoreai.com/govi_potha/api/auth/register`
- **Logout:** `https://vertexcoreai.com/govi_potha/api/auth/logout`
- **User Profile:** `https://vertexcoreai.com/govi_potha/api/auth/me`
- **Farms:** `https://vertexcoreai.com/govi_potha/api/farms`
- **Dashboard:** `https://vertexcoreai.com/govi_potha/api/dashboard`
- **Weather:** `https://vertexcoreai.com/govi_potha/api/weather`

---

**Need help?** Check `BUILD_INSTRUCTIONS.md` for detailed instructions or `QUICK_BUILD_GUIDE.md` for common commands.
