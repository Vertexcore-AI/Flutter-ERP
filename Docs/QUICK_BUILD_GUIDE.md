# Quick Build Guide

## 🎯 Most Common Commands

### Production Build for Android Testing

```bash
# Quick build and install on connected device
flutter run -d android -t lib/main_production.dart --release

# Or use the build script (Windows)
build-production.bat

# Or use the build script (Mac/Linux)
bash build-production.sh
```

### Local Development

```bash
# Run locally (Web)
flutter run -d chrome -t lib/main_local.dart

# Run locally (Android)
flutter run -d android -t lib/main_local.dart
```

## 📱 Steps to Test on Your Android Device

1. **Enable Developer Mode & USB Debugging**
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go to Settings > Developer Options
   - Enable "USB Debugging"

2. **Connect Device to Computer**
   ```bash
   # Verify device is connected
   flutter devices
   ```

3. **Build and Install Production App**
   ```bash
   flutter run -d android -t lib/main_production.dart --release
   ```

   **OR** build APK and share it:
   ```bash
   flutter build apk --release -t lib/main_production.dart

   # APK will be at: build/app/outputs/flutter-apk/app-release.apk
   # Transfer this file to your phone and install
   ```

## 🔄 Environment Switching

| Environment | Base URL | Command Flag |
|------------|----------|--------------|
| **Local** | `http://localhost:8000` | `-t lib/main_local.dart` |
| **Production** | `https://vertexcoreai.com/govi_potha` | `-t lib/main_production.dart` |

## ⚡ One-Line Commands

```bash
# Production APK build (Windows)
flutter build apk --release -t lib/main_production.dart && echo APK: build\app\outputs\flutter-apk\app-release.apk

# Production APK build (Mac/Linux)
flutter build apk --release -t lib/main_production.dart && echo "APK: build/app/outputs/flutter-apk/app-release.apk"

# Install to connected device
flutter install
```

## 🐛 Troubleshooting

**Problem:** Device not detected
```bash
# Check connected devices
flutter devices
adb devices

# Restart ADB
adb kill-server
adb start-server
```

**Problem:** Build fails
```bash
# Clean build
flutter clean
flutter pub get

# Try again
flutter build apk --release -t lib/main_production.dart
```

**Problem:** App shows wrong API URL
- Make sure you're using the correct entry point (`-t lib/main_production.dart`)
- Check `lib/config/environment.dart` for correct URLs

## 📦 Build Outputs

- **Debug APK:** `build/app/outputs/flutter-apk/app-debug.apk`
- **Release APK:** `build/app/outputs/flutter-apk/app-release.apk`
- **App Bundle:** `build/app/outputs/bundle/release/app-release.aab`

## 🎯 API Endpoints

### Production URLs will be:
- Login: `https://vertexcoreai.com/govi_potha/api/auth/login`
- Register: `https://vertexcoreai.com/govi_potha/api/auth/register`
- Farms: `https://vertexcoreai.com/govi_potha/api/farms`
- Dashboard: `https://vertexcoreai.com/govi_potha/api/dashboard`

### Local URLs will be:
- Login: `http://localhost:8000/api/auth/login`
- Register: `http://localhost:8000/api/auth/register`
- Farms: `http://localhost:8000/api/farms`
- Dashboard: `http://localhost:8000/api/dashboard`
