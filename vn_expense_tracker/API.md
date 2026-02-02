# API.md - API Documentation

## Database API

### AppDatabase

Main database class using Drift.

#### Wallet Operations

```dart
// Get all wallets
Future<List<Wallet>> getAllWallets()

// Get wallet by ID
Future<Wallet?> getWalletById(String id)

// Insert new wallet
Future<int> insertWallet(WalletsCompanion wallet)

// Update existing wallet
Future<bool> updateWallet(Wallet wallet)

// Delete wallet
Future<int> deleteWallet(String id)

// Check if wallet has transactions
Future<int> getWalletTransactionCount(String walletId)

// Calculate wallet balance
Future<double> getWalletBalance(String walletId)
```

#### Category Operations

```dart
// Get all categories
Future<List<Category>> getAllCategories()

// Get categories by type ('expense' or 'income')
Future<List<Category>> getCategoriesByType(String type)

// Get category by ID
Future<Category?> getCategoryById(String id)

// Insert new category
Future<int> insertCategory(CategoriesCompanion category)

// Update existing category
Future<bool> updateCategory(Category category)

// Delete category
Future<int> deleteCategory(String id)

// Check if category has transactions
Future<int> getCategoryTransactionCount(String categoryId)

// Reassign transactions to new category (CRITICAL)
Future<void> reassignCategoryTransactions(
  String fromCategoryId,
  String toCategoryId,
)
```

#### Transaction Operations

```dart
// Get all transactions with optional filters
Future<List<Transaction>> getAllTransactions({
  String? walletId,
  DateTime? startDate,
  DateTime? endDate,
  int? limit,
})

// Get transaction by ID
Future<Transaction?> getTransactionById(String id)

// Insert new transaction
Future<int> insertTransaction(TransactionsCompanion transaction)

// Update existing transaction
Future<bool> updateTransaction(Transaction transaction)

// Delete transaction
Future<int> deleteTransaction(String id)

// Get transactions grouped by date
Future<Map<DateTime, List<Transaction>>> getTransactionsByDate({
  String? walletId,
  DateTime? startDate,
  DateTime? endDate,
})

// Get transaction summary statistics
Future<Map<String, double>> getTransactionSummary({
  String? walletId,
  DateTime? startDate,
  DateTime? endDate,
})
// Returns: {'income': double, 'expense': double, 'net': double}

// Get category breakdown
Future<Map<String, double>> getCategoryBreakdown({
  required String type,  // 'expense' or 'income'
  String? walletId,
  DateTime? startDate,
  DateTime? endDate,
})
// Returns: Map of category names to amounts
```

#### Settings Operations

```dart
// Get setting value
Future<String?> getSetting(String key)

// Set setting value
Future<void> setSetting(String key, String value)

// Delete setting
Future<int> deleteSetting(String key)
```

#### Backup Operations

```dart
// Get all backups
Future<List<Backup>> getAllBackups()

// Insert backup record
Future<int> insertBackup(BackupsCompanion backup)

// Delete backup
Future<int> deleteBackup(String id)
```

## Voice Parser Service

### VoiceParserService

Vietnamese natural language parser for transaction voice input.

```dart
// Parse Vietnamese voice input
static ParsedTransaction parse(String text)

// Get example phrases for UI
static List<String> getExamplePhrases()
```

#### ParsedTransaction

Result of voice parsing.

```dart
class ParsedTransaction {
  final double? amount;
  final String? type;           // 'expense' or 'income'
  final String? categoryName;
  final String? walletName;
  final DateTime? date;
  final String? note;
  final String originalText;
  
  // Check if all required fields are present
  bool get isComplete
  
  // Get list of missing fields
  List<String> getMissingFields()
}
```

#### Supported Vietnamese Patterns

**Amount:**
- `100k` → 100,000
- `1.5 triệu` → 1,500,000
- `10 triệu` → 10,000,000
- `2 tỷ` → 2,000,000,000

**Type Keywords:**
- Expense: chi, trả, mua, tiêu, cost, spent, pay
- Income: nhận, thu, lương, thưởng, kiếm, được, earn

**Category Keywords:**
- Food: ăn, uống, cafe, nhà hàng, cơm, phở
- Transport: xe, grab, taxi, xăng, bus
- Shopping: mua sắm, siêu thị, vinmart
- Bills: điện, nước, internet, bill
- Entertainment: phim, game, karaoke, du lịch
- etc.

**Date Keywords:**
- `hôm nay` → today
- `hôm qua` → yesterday
- `ngày mai` → tomorrow
- `15/1` → January 15
- `ngày 20 tháng 2` → February 20

## STT Service

### SttService (Abstract Interface)

Interface for Speech-to-Text providers.

```dart
// Initialize the STT service
Future<void> initialize()

// Check if speech recognition is available
Future<bool> isAvailable()

// Check if microphone permission is granted
Future<bool> hasPermission()

// Request microphone permission
Future<bool> requestPermission()

// Start listening for speech
Future<void> startListening({
  required Function(String) onResult,
  required Function(String) onError,
  String locale = 'vi-VN',
})

// Stop listening
Future<void> stopListening()

// Cancel listening
Future<void> cancelListening()

// Get supported locales
Future<List<String>> getSupportedLocales()
```

### DefaultSttService

Default implementation using `speech_to_text` plugin.

### MockSttService

Mock implementation for testing.

```dart
MockSttService({
  List<String> mockResponses = const [
    'Hôm nay chi 120 ngàn ăn trưa',
    'Nhận lương 10 triệu',
  ],
})
```

## Lunar Calendar Service

### LunarCalendarService

Vietnamese lunar calendar calculations.

```dart
// Convert solar date to lunar date
static Lunar convertSolar2Lunar(
  int dd,      // Day
  int mm,      // Month
  int yy,      // Year
  double timeZone  // Timezone (7.0 for Vietnam)
)

// Convert lunar date to solar date
static DateTime convertLunar2Solar(
  int lunarDay,
  int lunarMonth,
  int lunarYear,
  int lunarLeap,   // 0 = normal, 1 = leap
  double timeZone
)
```

#### Lunar Model

```dart
class Lunar {
  final int day;
  final int month;
  final int year;
  final bool isLeap;
  final String lunarMonthName;      // e.g., "Tháng Giêng"
  final String canChiDay;           // e.g., "Giáp Tý"
  final String canChiMonth;
  final String canChiYear;
  final List<String> goodHours;     // Auspicious hours
}
```

## Utility Functions

### CurrencyUtils

```dart
// Format amount with currency
static String format(double amount, {String currency = 'VND'})

// Format in compact form (1K, 1M)
static String formatCompact(double amount)

// Format with thousand separator only
static String formatNumber(double amount)

// Parse Vietnamese number text
static double? parseVietnameseNumber(String text)

// Format percentage
static String formatPercentage(double percentage, {bool showSign = true})

// Check if percentage is positive (context-aware)
static bool isPositivePercentage(double percentage, {bool isExpense = false})
```

### AppDateUtils

```dart
// Format date for display
static String formatDate(DateTime date)

// Format for database storage
static String formatForDatabase(DateTime date)

// Format date time
static String formatDateTime(DateTime dateTime)

// Format month and year
static String formatMonthYear(DateTime date)

// Format day and month
static String formatDayMonth(DateTime date)

// Parse database date
static DateTime parseDatabase(String dateStr)

// Date range helpers
static DateTime startOfDay(DateTime date)
static DateTime endOfDay(DateTime date)
static DateTime startOfMonth(DateTime date)
static DateTime endOfMonth(DateTime date)
static DateTime startOfWeek(DateTime date)
static DateTime endOfWeek(DateTime date)
static DateTime startOfYear(DateTime date)
static DateTime endOfYear(DateTime date)

// Comparison helpers
static bool isSameDay(DateTime a, DateTime b)
static bool isToday(DateTime date)
static bool isYesterday(DateTime date)

// Relative date string
static String getRelativeDateString(DateTime date)
// Returns: "Hôm nay", "Hôm qua", or formatted date

// Utility functions
static int getDaysInMonth(int year, int month)
static int getMonthDifference(DateTime start, DateTime end)
```

## Seed Data

### SeedData

Utility to populate database with demo data.

```dart
// Seed all demo data
Future<void> seedAll()

// Seed wallets only
Future<void> seedWallets()

// Seed categories only
Future<void> seedCategories()

// Seed transactions only
Future<void> seedTransactions()

// Clear all data
Future<void> clearAll()
```

## Constants

### AppConstants

```dart
// App Info
static const String appName
static const String appVersion

// Database
static const String databaseName
static const int databaseVersion

// Settings Keys
static const String keyThemeMode
static const String keyLanguage
static const String keyPinHash
static const String keyDailyReminder
static const String keyReminderTime
static const String keyDefaultWallet

// Currencies
static const String currencyVND
static const String currencyUSD

// Transaction Types
static const String typeExpense
static const String typeIncome

// Date Formats
static const String dateFormatDisplay
static const String dateFormatDatabase
static const String dateTimeFormat

// Validation
static const int minPinLength
static const int maxPinLength
static const int maxTitleLength
static const int maxNoteLength
static const double maxAmount
```

### DefaultCategories

```dart
static const expenseCategories  // List of default expense categories
static const incomeCategories   // List of default income categories
```

## Usage Examples

### Creating a Transaction

```dart
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

final db = AppDatabase();
final uuid = Uuid();

await db.insertTransaction(
  TransactionsCompanion(
    id: Value(uuid.v4()),
    title: const Value('Ăn trưa'),
    amount: const Value(120000),
    type: const Value('expense'),
    date: Value(DateTime.now()),
    walletId: Value(selectedWalletId),
    categoryId: Value(selectedCategoryId),
    note: const Value('Với đồng nghiệp'),
    createdAt: Value(DateTime.now()),
    updatedAt: Value(DateTime.now()),
  ),
);
```

### Voice Input Flow

```dart
// 1. Initialize STT service
final sttService = DefaultSttService();
await sttService.initialize();

// 2. Start listening
await sttService.startListening(
  onResult: (text) {
    // 3. Parse result
    final parsed = VoiceParserService.parse(text);
    
    // 4. Check completeness
    if (!parsed.isComplete) {
      showMissingFields(parsed.getMissingFields());
    } else {
      // 5. Show preview for confirmation
      showPreview(parsed);
    }
  },
  onError: (error) {
    showError(error);
  },
  locale: 'vi-VN',
);
```

### Category Deletion with Reassignment

```dart
Future<void> deleteCategoryWithReassignment(
  String categoryId,
  String? replacementCategoryId,
) async {
  final count = await db.getCategoryTransactionCount(categoryId);
  
  if (count > 0 && replacementCategoryId == null) {
    throw Exception('Category has transactions. Please select replacement.');
  }
  
  if (count > 0) {
    await db.reassignCategoryTransactions(categoryId, replacementCategoryId!);
  }
  
  await db.deleteCategory(categoryId);
}
```

### Getting Statistics

```dart
// Get current month summary
final now = DateTime.now();
final startOfMonth = AppDateUtils.startOfMonth(now);
final endOfMonth = AppDateUtils.endOfMonth(now);

final summary = await db.getTransactionSummary(
  walletId: selectedWalletId,
  startDate: startOfMonth,
  endDate: endOfMonth,
);

print('Income: ${CurrencyUtils.format(summary['income']!)}');
print('Expense: ${CurrencyUtils.format(summary['expense']!)}');
print('Net: ${CurrencyUtils.format(summary['net']!)}');

// Get expense breakdown by category
final breakdown = await db.getCategoryBreakdown(
  type: 'expense',
  walletId: selectedWalletId,
  startDate: startOfMonth,
  endDate: endOfMonth,
);

for (final entry in breakdown.entries) {
  print('${entry.key}: ${CurrencyUtils.format(entry.value)}');
}
```

### Lunar Calendar Usage

```dart
// Convert today to lunar date
final now = DateTime.now();
final lunar = LunarCalendarService.convertSolar2Lunar(
  now.day,
  now.month,
  now.year,
  7.0,  // Vietnam timezone
);

print('Lunar Date: ${lunar.day}/${lunar.month}/${lunar.year}');
print('Month: ${lunar.lunarMonthName}');
print('Can Chi: ${lunar.canChiDay}');
print('Good Hours: ${lunar.goodHours.join(", ")}');
```

## Error Handling

All database operations may throw:
- `SqliteException` - Database-level errors
- `StateError` - Invalid state operations

All voice operations may throw:
- `PlatformException` - Permission or device errors
- `FormatException` - Parsing errors

Always wrap in try-catch:

```dart
try {
  await db.insertTransaction(transaction);
} on SqliteException catch (e) {
  logger.error('Database error: $e');
  showError('Failed to save transaction');
} catch (e) {
  logger.error('Unexpected error: $e');
  showError('An error occurred');
}
```
