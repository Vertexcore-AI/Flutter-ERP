#!/bin/bash

# Build script for production Android APK

echo "=========================================="
echo "Building Production Android APK"
echo "=========================================="
echo ""
echo "Environment: Production"
echo "Base URL: https://vertexcoreai.com/govi_potha"
echo ""

# Build the APK
flutter build apk --release -t lib/main_production.dart

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ Build Successful!"
    echo "=========================================="
    echo ""
    echo "APK Location:"
    echo "  build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "To install on connected device:"
    echo "  flutter install"
    echo ""
    echo "Or transfer the APK file to your Android device and install manually."
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ Build Failed!"
    echo "=========================================="
    echo ""
    exit 1
fi
