# Vietnamese Expense & Income Tracker

A modern, offline-first personal finance tracker optimized for the Vietnamese market.

## Features

- ✅ **Offline-First**: All features work without internet
- 💰 **Multi-Wallet Support**: Manage multiple wallets (cash, bank accounts, cards)
- 📊 **Smart Categories**: Flexible expense/income categorization with reassignment
- 🎤 **Voice Input**: Add transactions using Vietnamese voice commands
- 📈 **Analytics**: Detailed statistics with charts and trends
- 🌙 **Lunar Calendar**: Vietnamese lunar date integration
- 🔒 **Security**: Optional PIN lock protection
- 💾 **Backup**: Google Drive backup and CSV export
- 🌍 **Bilingual**: Vietnamese (default) and English support

## Architecture

```
lib/
├── core/               # Core utilities, constants, themes
├── data/               # Database, repositories, data sources
│   ├── database/       # Drift database schema
│   └── repositories/   # Data access layer
├── domain/             # Business logic, entities, use cases
│   ├── entities/       # Business models
│   └── usecases/       # Business operations
├── presentation/       # UI layer
│   ├── screens/        # App screens
│   ├── widgets/        # Reusable widgets
│   └── providers/      # Riverpod state providers
└── services/           # External services (STT, backup, etc.)
```

## Tech Stack

- **Framework**: Flutter 3.x (stable)
- **State Management**: Riverpod
- **Database**: Drift (SQLite)
- **Charts**: FL Chart
- **Voice**: Speech-to-Text (abstracted)
- **Testing**: Flutter Test + Mockito

## Setup Instructions

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode for mobile development

### Installation

1. **Clone or extract the project**

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
   flutter run
   ```

### Build for Release

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Testing

### Run all tests
```bash
flutter test
```

### Run specific test suite
```bash
flutter test test/data/database/
flutter test test/domain/usecases/
flutter test test/services/voice_parser_test.dart
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Key Features Explained

### 1. Category Management with Reassignment

When deleting a category that has transactions:
- System prevents deletion without reassignment
- User must select a replacement category (same type)
- All transactions are atomically reassigned
- Original category is then deleted

### 2. Voice-to-Transaction Flow

1. User taps voice input button
2. System records and transcribes speech
3. Parser extracts: amount, type, category, wallet, date
4. Preview card shows parsed data
5. User confirms or edits before saving

**Supported Vietnamese Phrases:**
- "Hôm nay chi 120 ngàn ăn trưa tại VinMart dùng Vietcombank"
- "Nhận lương 10 triệu"
- "Mua sắm hết 1.5 triệu"

### 3. Offline-First Architecture

- All data stored locally in SQLite
- No internet required for core features
- Optional manual sync to Google Drive
- Last-write-wins conflict resolution

### 4. Dashboard Overview

- Current wallet balance
- Month-over-month % change
- Quick action buttons
- Recent 5 transactions
- Category shortcuts

### 5. Statistics & Charts

**Time Ranges:**
- This week
- This month
- Last month
- This year
- Custom range

**Visualizations:**
- Line chart: Income vs Expense over time
- Donut chart: Category breakdown
- Percentage change indicators

## Configuration

### Default Categories

The app comes with predefined Vietnamese categories:

**Expenses:**
- Ăn uống (Food & Dining)
- Di chuyển (Transportation)
- Mua sắm (Shopping)
- Hóa đơn (Bills)
- Giải trí (Entertainment)

**Income:**
- Lương (Salary)
- Thưởng (Bonus)
- Đầu tư (Investment)
- Khác (Other)

### Localization

Modify `lib/core/l10n/` files to customize translations.

### Theme Customization

Edit `lib/core/theme/app_theme.dart` for color schemes and styling.

## Database Schema

### Wallets
- id, name, currency, initial_balance, created_at, updated_at

### Categories
- id, name, type, icon, color, created_at

### Transactions
- id, title, amount, type, date, wallet_id, category_id, note, metadata, created_at, updated_at

### Settings
- key-value store for app preferences

### Backups
- id, path, created_at

## Voice Parser Rules

The Vietnamese NLP parser recognizes:

**Numbers:**
- "100k" → 100,000
- "1.5 triệu" → 1,500,000
- "10 triệu" → 10,000,000

**Keywords:**
- Expense: chi, trả, mua, cost, spent
- Income: nhận, thu, income, salary

**Date Parsing:**
- "hôm nay" (today)
- "hôm qua" (yesterday)
- Specific dates: "15/1", "ngày 15 tháng 1"

## Security

- PIN is hashed using SHA-256
- Stored locally in encrypted preferences
- Biometric unlock (optional, future enhancement)

## Known Limitations

- No cloud sync (manual backup only)
- Single currency per wallet
- No multi-device real-time sync
- STT requires internet connection

## Future Enhancements

- [ ] Recurring transactions
- [ ] Budget limits and alerts
- [ ] Multi-currency support
- [ ] Real-time cloud sync
- [ ] Biometric authentication
- [ ] Receipt photo attachment
- [ ] Bill splitting
- [ ] Export to PDF reports

## Troubleshooting

### Build Issues

**Problem:** Drift code generation fails
```bash
# Solution:
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Problem:** SQLite errors on iOS
```bash
# Add to Podfile:
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

### Voice Input Issues

Ensure permissions are granted in:
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

## Contributing

This is a personal project template. Feel free to fork and customize.

## License

MIT License - See LICENSE file for details

## Contact & Support

For issues or questions, please create an issue in the repository.

---

**Built with ❤️ for the Vietnamese community**
