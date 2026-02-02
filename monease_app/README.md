# Monease - Personal Expense Tracker

A friendly, cross-platform expense tracker with voice input and Vietnamese lunar calendar support.

## Features

### Core Functionality
- **Multi-wallet management**: Track multiple accounts (cash, bank, e-wallets)
- **Smart transaction recording**: Quick entry via voice or manual input
- **Vietnamese lunar calendar**: Displays both solar and lunar dates with traditional can/chi information
- **Visual analytics**: Charts and statistics for spending patterns
- **Category management**: Customizable expense and income categories
- **Offline-first**: All data stored locally with optional cloud backup

### Voice Input
- Speech-to-text transaction recording in Vietnamese
- Natural language parsing for amount, category, wallet, and date
- Supports common Vietnamese number formats (nghìn, triệu, k, m)
- Example: "Hôm nay tôi đi siêu thị hết 100 nghìn từ Vietcombank"

### UI/UX Design
- Pastel color palette for a friendly, approachable feel
- Card-based interface with rounded corners
- Quick actions on dashboard for low-friction data entry
- Bottom navigation with centered FAB for adding transactions

## Tech Stack

- **Framework**: Flutter 3.x (Dart 3.x)
- **State Management**: Riverpod + Hooks
- **Local Database**: Drift (SQLite)
- **Calendar**: table_calendar
- **Charts**: fl_chart
- **Voice**: speech_to_text
- **Fonts**: Google Fonts (Inter)

## Project Structure

```
lib/
├── models/              # Data models
│   ├── lunar.dart      # Lunar calendar model
│   └── ...
├── services/           # Business logic & data access
│   ├── database.dart   # Drift database definition
│   ├── lunar_calendar_service.dart
│   ├── voice_service.dart
│   └── nlp_parser.dart
├── providers/          # Riverpod providers
│   ├── wallet_provider.dart
│   ├── transaction_provider.dart
│   └── settings_provider.dart
├── screens/            # Full-screen pages
│   ├── dashboard/
│   ├── history/
│   ├── add_transaction/
│   ├── statistics/
│   ├── settings/
│   └── voice_input/
├── widgets/            # Reusable UI components
│   ├── common/        # Generic widgets
│   ├── dashboard/     # Dashboard-specific widgets
│   ├── history/       # History-specific widgets
│   └── statistics/    # Statistics-specific widgets
├── utils/              # Utilities & constants
│   ├── design_tokens.dart
│   ├── app_theme.dart
│   ├── formatters.dart
│   └── validators.dart
└── l10n/               # Localization files
    ├── app_vi.arb
    └── app_en.arb
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.16+ installed
- Android Studio / Xcode for mobile development
- For voice features: microphone permissions

### Installation

1. **Clone or extract the project**
   ```bash
   cd monease_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Drift database code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run --device-id=<ios-device-id>
   ```

### Configuration

#### Voice Recognition Setup
The app uses on-device speech-to-text by default. For better accuracy with Vietnamese:

1. **Android**: Ensure Google app is installed and updated
2. **iOS**: Vietnamese language pack should be downloaded in iOS settings

#### Optional Cloud Services

**Google Drive Backup** (optional):
1. Create a Google Cloud project
2. Enable Google Drive API
3. Download `credentials.json`
4. Place in `assets/` folder
5. Update `lib/services/google_drive_service.dart` with your credentials

**Cloud Speech-to-Text** (optional fallback):
1. Enable Google Cloud Speech-to-Text API
2. Download service account JSON
3. Configure in `lib/services/voice_service.dart`

## Database Schema

### Wallets
- id, name, balance, currency, color, isDefault
- Tracks user's financial accounts

### Categories
- id, name, type (expense/income), color, icon, sortOrder, isSystem
- Organizes transactions by purpose

### Transactions
- id, amount, type, date, walletId, categoryId, note
- Individual financial events

### Settings
- key-value store for app preferences

## Usage Guide

### Adding Transactions

**Manual Entry:**
1. Tap the blue '+' FAB at the bottom center
2. Select "Add Expense" or "Add Income"
3. Enter amount, select category, wallet, and date
4. Optionally add a note
5. Tap "Save"

**Voice Entry:**
1. Tap the microphone icon on dashboard
2. Speak your transaction naturally
3. Review the parsed result
4. Confirm or edit as needed

**Voice Examples:**
- "Chi 50 nghìn mua cafe"
- "Hôm qua đi siêu thị hết 200k từ Vietcombank"
- "Nhận lương 15 triệu vào tk công ty"

### Viewing Statistics
Navigate to the Statistics tab to see:
- Income vs Expense over time
- Category breakdowns (donut charts)
- Monthly trends

### Exporting Data
Settings → Export Data → CSV
Downloads all transactions to a CSV file for backup or analysis.

## Voice NLP Parser

The voice parser uses a rule-based engine that extracts:

1. **Transaction Type**: Keywords like "chi", "mua", "trả" → expense; "thu", "nhận", "lương" → income
2. **Amount**: Numbers with suffixes (k, nghìn, triệu, m), handles separators
3. **Category**: Maps keywords to categories (siêu thị → groceries, cafe → food & beverage)
4. **Wallet**: Matches wallet names in the database
5. **Date**: Relative dates (hôm nay, hôm qua, tuần trước)

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/nlp_parser_test.dart

# Run with coverage
flutter test --coverage
```

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### iOS IPA
```bash
flutter build ios --release
```

## Accessibility

The app includes:
- Semantic labels for screen readers
- Sufficient color contrast (WCAG AA compliant)
- Scalable font sizes
- Keyboard navigation support

## License

Private project - All rights reserved

## Support & Feedback

For issues or feature requests, please contact the development team.

---

**Version**: 1.0.0  
**Last Updated**: February 2026  
**Minimum Flutter Version**: 3.16.0
