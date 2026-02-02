#!/bin/bash

# Build script for Vietnamese Expense Tracker
# This script sets up and builds the Flutter project

set -e

echo "🚀 Vietnamese Expense Tracker - Build Script"
echo "=============================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo ""

# Generate Drift database code
echo "🔨 Generating Drift database code..."
dart run build_runner build --delete-conflicting-outputs
echo ""

# Run tests
echo "🧪 Running tests..."
flutter test
echo ""

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze
echo ""

echo "✅ Build preparation complete!"
echo ""
echo "Next steps:"
echo "  • To run on device/emulator: flutter run"
echo "  • To build APK: flutter build apk --release"
echo "  • To build iOS: flutter build ios --release"
echo ""
