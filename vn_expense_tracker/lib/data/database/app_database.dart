// lib/data/database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Wallets Table
class Wallets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get currency => text().withDefault(const Constant('VND'))();
  RealColumn get initialBalance => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Categories Table
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text().check(type.isIn(['expense', 'income']))();
  TextColumn get icon => text().withDefault(const Constant('📌'))();
  TextColumn get color => text().withDefault(const Constant('9E9E9E'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Transactions Table
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable().withLength(max: 100)();
  RealColumn get amount => real()();
  TextColumn get type => text().check(type.isIn(['expense', 'income']))();
  DateTimeColumn get date => dateTime()();
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get note => text().nullable().withLength(max: 500)();
  TextColumn get metadata => text().nullable()(); // JSON string
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Settings Table
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  
  @override
  Set<Column> get primaryKey => {key};
}

// Backups Table
class Backups extends Table {
  TextColumn get id => text()();
  TextColumn get path => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Wallets, Categories, Transactions, Settings, Backups])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle future migrations here
    },
  );

  // ==================== WALLET OPERATIONS ====================
  
  Future<List<Wallet>> getAllWallets() => select(wallets).get();
  
  Future<Wallet?> getWalletById(String id) =>
      (select(wallets)..where((w) => w.id.equals(id))).getSingleOrNull();
  
  Future<int> insertWallet(WalletsCompanion wallet) =>
      into(wallets).insert(wallet);
  
  Future<bool> updateWallet(Wallet wallet) =>
      update(wallets).replace(wallet);
  
  Future<int> deleteWallet(String id) =>
      (delete(wallets)..where((w) => w.id.equals(id))).go();
  
  // Check if wallet has transactions
  Future<int> getWalletTransactionCount(String walletId) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.id.count()])
      ..where(transactions.walletId.equals(walletId));
    
    final result = await query.getSingleOrNull();
    return result?.read(transactions.id.count()) ?? 0;
  }
  
  // Get wallet balance (initial + all transactions)
  Future<double> getWalletBalance(String walletId) async {
    final wallet = await getWalletById(walletId);
    if (wallet == null) return 0;
    
    final incomeQuery = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.walletId.equals(walletId))
      ..where(transactions.type.equals('income'));
    
    final expenseQuery = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.walletId.equals(walletId))
      ..where(transactions.type.equals('expense'));
    
    final incomeResult = await incomeQuery.getSingleOrNull();
    final expenseResult = await expenseQuery.getSingleOrNull();
    
    final totalIncome = incomeResult?.read(transactions.amount.sum()) ?? 0;
    final totalExpense = expenseResult?.read(transactions.amount.sum()) ?? 0;
    
    return wallet.initialBalance + totalIncome - totalExpense;
  }

  // ==================== CATEGORY OPERATIONS ====================
  
  Future<List<Category>> getAllCategories() => select(categories).get();
  
  Future<List<Category>> getCategoriesByType(String type) =>
      (select(categories)..where((c) => c.type.equals(type))).get();
  
  Future<Category?> getCategoryById(String id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  
  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);
  
  Future<bool> updateCategory(Category category) =>
      update(categories).replace(category);
  
  Future<int> deleteCategory(String id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();
  
  // Check if category has transactions
  Future<int> getCategoryTransactionCount(String categoryId) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.id.count()])
      ..where(transactions.categoryId.equals(categoryId));
    
    final result = await query.getSingleOrNull();
    return result?.read(transactions.id.count()) ?? 0;
  }
  
  // Reassign transactions to new category (CRITICAL for delete flow)
  Future<void> reassignCategoryTransactions(
    String fromCategoryId,
    String toCategoryId,
  ) async {
    await transaction(() async {
      await (update(transactions)
            ..where((t) => t.categoryId.equals(fromCategoryId)))
          .write(TransactionsCompanion(
        categoryId: Value(toCategoryId),
        updatedAt: Value(DateTime.now()),
      ));
    });
  }

  // ==================== TRANSACTION OPERATIONS ====================
  
  Future<List<Transaction>> getAllTransactions({
    String? walletId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    final query = select(transactions);
    
    if (walletId != null) {
      query.where((t) => t.walletId.equals(walletId));
    }
    
    if (startDate != null) {
      query.where((t) => t.date.isBiggerOrEqualValue(startDate));
    }
    
    if (endDate != null) {
      query.where((t) => t.date.isSmallerOrEqualValue(endDate));
    }
    
    query.orderBy([(t) => OrderingTerm.desc(t.date)]);
    
    if (limit != null) {
      query.limit(limit);
    }
    
    return query.get();
  }
  
  Future<Transaction?> getTransactionById(String id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
  
  Future<int> insertTransaction(TransactionsCompanion transaction) =>
      into(transactions).insert(transaction);
  
  Future<bool> updateTransaction(Transaction transaction) =>
      update(transactions).replace(transaction);
  
  Future<int> deleteTransaction(String id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();
  
  // Get transactions grouped by date
  Future<Map<DateTime, List<Transaction>>> getTransactionsByDate({
    String? walletId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final txList = await getAllTransactions(
      walletId: walletId,
      startDate: startDate,
      endDate: endDate,
    );
    
    final Map<DateTime, List<Transaction>> grouped = {};
    
    for (final tx in txList) {
      final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }
    
    return grouped;
  }
  
  // Get summary statistics
  Future<Map<String, double>> getTransactionSummary({
    String? walletId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var incomeQuery = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.type.equals('income'));
    
    var expenseQuery = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.type.equals('expense'));
    
    if (walletId != null) {
      incomeQuery.where(transactions.walletId.equals(walletId));
      expenseQuery.where(transactions.walletId.equals(walletId));
    }
    
    if (startDate != null) {
      incomeQuery.where(transactions.date.isBiggerOrEqualValue(startDate));
      expenseQuery.where(transactions.date.isBiggerOrEqualValue(startDate));
    }
    
    if (endDate != null) {
      incomeQuery.where(transactions.date.isSmallerOrEqualValue(endDate));
      expenseQuery.where(transactions.date.isSmallerOrEqualValue(endDate));
    }
    
    final incomeResult = await incomeQuery.getSingleOrNull();
    final expenseResult = await expenseQuery.getSingleOrNull();
    
    final totalIncome = incomeResult?.read(transactions.amount.sum()) ?? 0;
    final totalExpense = expenseResult?.read(transactions.amount.sum()) ?? 0;
    
    return {
      'income': totalIncome,
      'expense': totalExpense,
      'net': totalIncome - totalExpense,
    };
  }
  
  // Get category breakdown
  Future<Map<String, double>> getCategoryBreakdown({
    required String type,
    String? walletId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId))
    ])
      ..where(transactions.type.equals(type));
    
    if (walletId != null) {
      query.where(transactions.walletId.equals(walletId));
    }
    
    if (startDate != null) {
      query.where(transactions.date.isBiggerOrEqualValue(startDate));
    }
    
    if (endDate != null) {
      query.where(transactions.date.isSmallerOrEqualValue(endDate));
    }
    
    final results = await query.get();
    
    final Map<String, double> breakdown = {};
    
    for (final row in results) {
      final category = row.readTable(categories);
      final transaction = row.readTable(transactions);
      
      breakdown[category.name] = 
          (breakdown[category.name] ?? 0) + transaction.amount;
    }
    
    return breakdown;
  }

  // ==================== SETTINGS OPERATIONS ====================
  
  Future<String?> getSetting(String key) async {
    final result = await (select(settings)..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return result?.value;
  }
  
  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }
  
  Future<int> deleteSetting(String key) =>
      (delete(settings)..where((s) => s.key.equals(key))).go();

  // ==================== BACKUP OPERATIONS ====================
  
  Future<List<Backup>> getAllBackups() => select(backups).get();
  
  Future<int> insertBackup(BackupsCompanion backup) =>
      into(backups).insert(backup);
  
  Future<int> deleteBackup(String id) =>
      (delete(backups)..where((b) => b.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'expense_tracker.db'));
    return NativeDatabase(file);
  });
}
