# ARCHITECTURE.md - System Architecture Documentation

## Overview

Vietnamese Expense Tracker is built using **Clean Architecture** principles with Flutter and Riverpod for state management.

## Architecture Layers

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (UI, Widgets, Screens, Providers)  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       Domain Layer                  │
│  (Entities, Use Cases, Interfaces)  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        Data Layer                   │
│  (Database, Repositories, Models)   │
└─────────────────────────────────────┘
```

## Directory Structure

```
lib/
├── core/                   # Core utilities and constants
│   ├── constants/          # App-wide constants
│   ├── theme/              # Theme configuration
│   ├── l10n/               # Localization files
│   └── utils/              # Utility functions
│
├── data/                   # Data layer
│   ├── database/           # Drift database
│   │   ├── app_database.dart
│   │   └── seed_data.dart
│   └── repositories/       # Data repositories
│
├── domain/                 # Business logic layer
│   ├── entities/           # Business entities
│   │   ├── wallet_entity.dart
│   │   ├── category_entity.dart
│   │   └── transaction_entity.dart
│   └── usecases/           # Business use cases
│
├── presentation/           # UI layer
│   ├── screens/            # App screens
│   │   ├── dashboard/
│   │   ├── history/
│   │   ├── add_transaction/
│   │   ├── statistics/
│   │   ├── settings/
│   │   ├── voice_input/
│   │   ├── wallet/
│   │   └── category/
│   ├── widgets/            # Reusable widgets
│   └── providers/          # Riverpod providers
│
├── services/               # External services
│   ├── stt_service.dart
│   ├── voice_parser_service.dart
│   └── lunar_calendar_service.dart
│
└── models/                 # Data models
    └── lunar.dart
```

## Key Design Patterns

### 1. Repository Pattern

Repositories abstract data sources from business logic.

```dart
abstract class TransactionRepository {
  Future<List<TransactionEntity>> getAll();
  Future<TransactionEntity?> getById(String id);
  Future<void> create(TransactionEntity transaction);
  Future<void> update(TransactionEntity transaction);
  Future<void> delete(String id);
}
```

### 2. Provider Pattern (Riverpod)

State management using Riverpod providers.

```dart
final walletProvider = StateNotifierProvider<WalletNotifier, AsyncValue<List<Wallet>>>((ref) {
  return WalletNotifier(ref.read(databaseProvider));
});
```

### 3. Service Locator Pattern

Services are abstracted for easy testing and swapping.

```dart
abstract class SttService {
  Future<void> startListening({...});
  Future<void> stopListening();
}

// Can swap implementations:
final sttService = DefaultSttService(); // Real implementation
final sttService = MockSttService();    // Test implementation
```

## Data Flow

### Creating a Transaction

```
User Input
    ↓
AddTransactionScreen
    ↓
TransactionProvider (Riverpod)
    ↓
TransactionRepository
    ↓
AppDatabase (Drift)
    ↓
SQLite
```

### Voice-to-Transaction Flow

```
User speaks
    ↓
SttService (Speech-to-Text)
    ↓
VoiceParserService (NLP)
    ↓
ParsedTransaction
    ↓
Preview Screen (User confirms)
    ↓
TransactionRepository
    ↓
Database
```

## Database Schema

### Wallets
- **Primary Key:** id (TEXT)
- **Fields:** name, currency, initialBalance, createdAt, updatedAt
- **Relationships:** One-to-Many with Transactions

### Categories
- **Primary Key:** id (TEXT)
- **Fields:** name, type, icon, color, createdAt
- **Relationships:** One-to-Many with Transactions
- **Constraints:** type IN ('expense', 'income')

### Transactions
- **Primary Key:** id (TEXT)
- **Fields:** title, amount, type, date, walletId, categoryId, note, metadata, createdAt, updatedAt
- **Relationships:** 
  - Many-to-One with Wallets
  - Many-to-One with Categories
- **Constraints:** type IN ('expense', 'income')

### Settings
- **Primary Key:** key (TEXT)
- **Fields:** value
- **Type:** Key-value store

### Backups
- **Primary Key:** id (TEXT)
- **Fields:** path, createdAt

## Critical Business Logic

### Category Deletion with Reassignment

**Requirement:** Categories with transactions cannot be deleted without reassignment.

**Implementation:**

```dart
Future<void> deleteCategory(String categoryId, String? replacementId) async {
  final count = await db.getCategoryTransactionCount(categoryId);
  
  if (count > 0) {
    if (replacementId == null) {
      throw Exception('Must provide replacement category');
    }
    
    await db.transaction(() async {
      await db.reassignCategoryTransactions(categoryId, replacementId);
      await db.deleteCategory(categoryId);
    });
  } else {
    await db.deleteCategory(categoryId);
  }
}
```

### Balance Calculation

Wallet balance = initialBalance + totalIncome - totalExpense

```dart
Future<double> getWalletBalance(String walletId) async {
  final wallet = await getWalletById(walletId);
  final income = await getTotalIncome(walletId);
  final expense = await getTotalExpense(walletId);
  return wallet.initialBalance + income - expense;
}
```

## State Management

### Using Riverpod

**Provider Types:**
- **Provider:** Immutable, cached values
- **StateProvider:** Simple mutable state
- **StateNotifierProvider:** Complex state with logic
- **FutureProvider:** Async data
- **StreamProvider:** Reactive streams

**Example:**

```dart
// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Wallets provider
final walletsProvider = FutureProvider<List<Wallet>>((ref) async {
  final db = ref.read(databaseProvider);
  return db.getAllWallets();
});

// Selected wallet provider
final selectedWalletProvider = StateProvider<String?>((ref) => null);
```

## Testing Strategy

### Unit Tests
- Voice parser logic
- Currency utilities
- Date utilities
- Business logic

### Integration Tests
- Database operations
- Transaction flows
- Category reassignment

### Widget Tests
- UI components
- Screen navigation
- User interactions

## Performance Considerations

### Database Optimization

1. **Indexed Columns:**
   - Transaction.date (for date range queries)
   - Transaction.walletId (for filtering)
   - Transaction.categoryId (for filtering)

2. **Pagination:**
   - Limit query results
   - Load more on scroll

3. **Caching:**
   - Cache frequently accessed data
   - Invalidate on updates

### UI Optimization

1. **Lazy Loading:**
   - ListView.builder for long lists
   - Load transactions on demand

2. **Memoization:**
   - Cache computed values
   - Use Riverpod's built-in caching

## Security

### PIN Protection

```dart
// Hash PIN before storage
String hashPin(String pin) {
  return sha256.convert(utf8.encode(pin)).toString();
}

// Verify PIN
bool verifyPin(String inputPin, String storedHash) {
  return hashPin(inputPin) == storedHash;
}
```

### Data Privacy

- All data stored locally
- No cloud sync without explicit user action
- Optional Google Drive backup with user consent

## Localization

### Supported Languages
- Vietnamese (default)
- English

### Implementation

```dart
// Using .arb files
{
  "appName": "Chi Tiêu Thông Minh",
  "dashboard": "Tổng quan",
  "addExpense": "Thêm chi tiêu",
  "@addExpense": {
    "description": "Button to add expense"
  }
}
```

## Error Handling

### Database Errors

```dart
try {
  await db.insertTransaction(transaction);
} on SqliteException catch (e) {
  // Handle constraint violations, etc.
  throw DatabaseException('Failed to insert transaction: ${e.message}');
}
```

### Voice Input Errors

```dart
try {
  await sttService.startListening(...);
} on PlatformException catch (e) {
  // Handle permission errors, STT not available, etc.
  throw VoiceInputException('Voice input failed: ${e.message}');
}
```

## Future Enhancements

### Planned Features
1. Recurring transactions
2. Budget limits and alerts
3. Multi-currency support
4. Real-time cloud sync
5. Biometric authentication
6. Receipt OCR
7. Bill splitting
8. Export to PDF

### Scalability Considerations
- Move to reactive streams for real-time updates
- Implement background sync
- Add offline queue for operations
- Consider NoSQL for flexible metadata

## Contributing

### Code Style
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features

### Pull Request Process
1. Create feature branch
2. Write code and tests
3. Run `flutter analyze`
4. Run `flutter test`
5. Submit PR with description

## References

- Flutter Documentation: https://flutter.dev/docs
- Riverpod Guide: https://riverpod.dev
- Drift Documentation: https://drift.simonbinder.eu
- Clean Architecture: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
