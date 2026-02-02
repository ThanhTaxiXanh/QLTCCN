# SETUP.md - Detailed Setup Instructions

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

1. **Flutter SDK** (3.0.0 or higher)
   - Download: https://flutter.dev/docs/get-started/install
   - Verify: `flutter --version`

2. **Dart SDK** (3.0.0 or higher)
   - Included with Flutter
   - Verify: `dart --version`

3. **IDE** (Choose one)
   - Android Studio (recommended for Android development)
   - Visual Studio Code with Flutter extension
   - Xcode (required for iOS development on macOS)

4. **Git**
   - Download: https://git-scm.com/downloads
   - Verify: `git --version`

## Quick Start

### 1. Clone/Extract Project

```bash
cd vn_expense_tracker
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Database Code

This project uses Drift for database management. Generate the required code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the App

**For development:**
```bash
flutter run
```

**Select target device when prompted:**
- Android emulator
- iOS simulator
- Physical device (connected via USB)

## Platform-Specific Setup

### Android Setup

1. **Install Android Studio**
   - Download from: https://developer.android.com/studio

2. **Configure Android SDK**
   ```bash
   flutter doctor
   ```
   Follow instructions to accept licenses and install missing components

3. **Create/Start Emulator**
   - Open Android Studio > Tools > AVD Manager
   - Create a new Virtual Device
   - Start the emulator

4. **Build APK**
   ```bash
   # Debug APK
   flutter build apk --debug
   
   # Release APK
   flutter build apk --release
   
   # App Bundle (for Google Play)
   flutter build appbundle --release
   ```

### iOS Setup (macOS only)

1. **Install Xcode**
   - Download from Mac App Store
   - Open Xcode and accept license

2. **Install CocoaPods**
   ```bash
   sudo gem install cocoapods
   ```

3. **Configure Xcode**
   ```bash
   flutter doctor
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

4. **Install iOS Simulator**
   - Open Xcode > Preferences > Components
   - Download desired iOS version

5. **Build iOS App**
   ```bash
   cd ios
   pod install
   cd ..
   
   # Build
   flutter build ios --release
   ```

## Database Setup

The app uses Drift (SQLite) for local storage. No additional setup required for basic usage.

### Regenerate Database Code

If you modify database schema in `lib/data/database/app_database.dart`:

```bash
# Clean old generated files
dart run build_runner clean

# Generate new code
dart run build_runner build --delete-conflicting-outputs
```

## Seed Demo Data

To populate the database with demo data for testing:

```dart
import 'package:vn_expense_tracker/data/database/seed_data.dart';

final db = AppDatabase();
final seeder = SeedData(db);
await seeder.seedAll();
```

## Running Tests

### All Tests
```bash
flutter test
```

### Specific Test Suite
```bash
flutter test test/services/voice_parser_test.dart
flutter test test/core/utils/currency_utils_test.dart
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Voice Input Setup

### Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice input</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition for voice transactions</string>
```

## Google Drive Backup Setup (Optional)

1. **Create Google Cloud Project**
   - Visit: https://console.cloud.google.com

2. **Enable Google Drive API**
   - APIs & Services > Enable APIs and Services
   - Search for "Google Drive API"
   - Enable it

3. **Configure OAuth Consent Screen**
   - APIs & Services > OAuth consent screen
   - Select "External" user type
   - Fill in required information

4. **Create OAuth 2.0 Credentials**
   - APIs & Services > Credentials
   - Create OAuth client ID
   - Download `client_id.json`

5. **Add to Project**
   - Place configuration in appropriate location
   - Update code with client ID

## Troubleshooting

### Build Runner Issues

**Problem:** `dart run build_runner build` fails

**Solution:**
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Dependency Conflicts

**Problem:** Pub get fails with version conflicts

**Solution:**
```bash
flutter pub upgrade --major-versions
flutter pub get
```

### SQLite Issues on iOS

**Problem:** Database errors on iOS

**Solution:** Add to `ios/Podfile`:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'HAVE_FULLFSYNC=1'
      ]
    end
  end
end
```

### Permission Errors

**Problem:** Voice input doesn't work

**Solution:**
1. Check permissions in manifest/Info.plist
2. Request permissions at runtime
3. Test on physical device (emulator may have limitations)

### Build Fails

**Problem:** Build fails with errors

**Solution:**
```bash
# Clean everything
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf android/.gradle

# Rebuild
flutter pub get
cd ios && pod install && cd ..
flutter build [android|ios]
```

## Development Workflow

### 1. Feature Development
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes
# ...

# Test
flutter test

# Analyze
flutter analyze

# Commit
git add .
git commit -m "Add new feature"
```

### 2. Hot Reload
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### 3. Debug Mode
```bash
flutter run --debug
```

### 4. Performance Profiling
```bash
flutter run --profile
```

## IDE Configuration

### Visual Studio Code

**Recommended Extensions:**
- Flutter (Dart Code)
- Dart
- Better Comments
- GitLens

**Settings (`.vscode/settings.json`):**
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "editor.formatOnSave": true,
  "editor.rulers": [80],
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.formatOnSave": true,
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}
```

### Android Studio

1. Install Flutter plugin
2. Configure Flutter SDK path
3. Enable Dart Analysis
4. Set code style to match project

## Environment Variables

Create `.env` file in project root (if needed):
```
# Google Drive
GOOGLE_DRIVE_CLIENT_ID=your_client_id
GOOGLE_DRIVE_CLIENT_SECRET=your_secret

# Other API keys
# ...
```

## Continuous Integration

### GitHub Actions Example

`.github/workflows/ci.yml`:
```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: dart run build_runner build
      - run: flutter test
      - run: flutter analyze
```

## Support

For issues or questions:
1. Check README.md
2. Review error messages carefully
3. Search Flutter documentation
4. Check GitHub issues (if applicable)

## Next Steps

After successful setup:
1. ✅ Run the app: `flutter run`
2. ✅ Explore the code structure
3. ✅ Read the API documentation
4. ✅ Start building features!

---

**Happy Coding! 🚀**
