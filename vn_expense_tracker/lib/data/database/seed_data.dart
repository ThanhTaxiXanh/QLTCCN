// lib/data/database/seed_data.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'app_database.dart';
import '../../core/constants/app_constants.dart';

/// Utility class to seed demo data into the database
class SeedData {
  final AppDatabase db;
  final _uuid = const Uuid();

  SeedData(this.db);

  /// Seed all demo data
  Future<void> seedAll() async {
    await seedWallets();
    await seedCategories();
    await seedTransactions();
  }

  /// Create demo wallets
  Future<void> seedWallets() async {
    final wallets = [
      WalletsCompanion(
        id: Value(_uuid.v4()),
        name: const Value('Tiền mặt'),
        currency: const Value(AppConstants.currencyVND),
        initialBalance: const Value(5000000),
        createdAt: Value(DateTime.now().subtract(const Duration(days: 90))),
        updatedAt: Value(DateTime.now()),
      ),
      WalletsCompanion(
        id: Value(_uuid.v4()),
        name: const Value('Vietcombank'),
        currency: const Value(AppConstants.currencyVND),
        initialBalance: const Value(15000000),
        createdAt: Value(DateTime.now().subtract(const Duration(days: 90))),
        updatedAt: Value(DateTime.now()),
      ),
      WalletsCompanion(
        id: Value(_uuid.v4()),
        name: const Value('Techcombank'),
        currency: const Value(AppConstants.currencyVND),
        initialBalance: const Value(8000000),
        createdAt: Value(DateTime.now().subtract(const Duration(days: 90))),
        updatedAt: Value(DateTime.now()),
      ),
    ];

    for (final wallet in wallets) {
      await db.into(db.wallets).insert(wallet);
    }
  }

  /// Create demo categories
  Future<void> seedCategories() async {
    // Expense categories
    for (final cat in DefaultCategories.expenseCategories) {
      await db.into(db.categories).insert(
        CategoriesCompanion(
          id: Value(_uuid.v4()),
          name: Value(cat['name'] as String),
          type: const Value(AppConstants.typeExpense),
          icon: Value(cat['icon'] as String),
          color: Value(cat['color'] as String),
          createdAt: Value(DateTime.now().subtract(const Duration(days: 90))),
        ),
      );
    }

    // Income categories
    for (final cat in DefaultCategories.incomeCategories) {
      await db.into(db.categories).insert(
        CategoriesCompanion(
          id: Value(_uuid.v4()),
          name: Value(cat['name'] as String),
          type: const Value(AppConstants.typeIncome),
          icon: Value(cat['icon'] as String),
          color: Value(cat['color'] as String),
          createdAt: Value(DateTime.now().subtract(const Duration(days: 90))),
        ),
      );
    }
  }

  /// Create demo transactions
  Future<void> seedTransactions() async {
    final wallets = await db.getAllWallets();
    final categories = await db.getAllCategories();

    if (wallets.isEmpty || categories.isEmpty) return;

    final expenseCategories = categories.where((c) => c.type == 'expense').toList();
    final incomeCategories = categories.where((c) => c.type == 'income').toList();

    // Create transactions for the past 30 days
    for (int i = 0; i < 30; i++) {
      final date = DateTime.now().subtract(Duration(days: i));

      // 2-4 expense transactions per day
      for (int j = 0; j < 2 + (i % 3); j++) {
        final category = expenseCategories[j % expenseCategories.length];
        await db.into(db.transactions).insert(
          TransactionsCompanion(
            id: Value(_uuid.v4()),
            title: Value(_getExpenseTitle(category.name)),
            amount: Value(_randomAmount(20000, 500000)),
            type: const Value('expense'),
            date: Value(date),
            walletId: Value(wallets[j % wallets.length].id),
            categoryId: Value(category.id),
            note: const Value(null),
            metadata: const Value(null),
            createdAt: Value(date),
            updatedAt: Value(date),
          ),
        );
      }

      // 1 income transaction every 15 days
      if (i % 15 == 0 && incomeCategories.isNotEmpty) {
        final category = incomeCategories[0]; // Salary
        await db.into(db.transactions).insert(
          TransactionsCompanion(
            id: Value(_uuid.v4()),
            title: const Value('Lương tháng'),
            amount: const Value(15000000),
            type: const Value('income'),
            date: Value(date),
            walletId: Value(wallets[0].id),
            categoryId: Value(category.id),
            note: const Value(null),
            metadata: const Value(null),
            createdAt: Value(date),
            updatedAt: Value(date),
          ),
        );
      }
    }
  }

  double _randomAmount(double min, double max) {
    return min + (max - min) * (DateTime.now().millisecond / 1000);
  }

  String _getExpenseTitle(String categoryName) {
    final titles = {
      'Ăn uống': ['Ăn trưa', 'Cafe', 'Nhà hàng', 'Ăn tối', 'Trà sữa'],
      'Di chuyển': ['Grab', 'Taxi', 'Xăng xe', 'Gửi xe', 'Bus'],
      'Mua sắm': ['VinMart', 'Siêu thị', 'Mua đồ', 'Shopping'],
      'Hóa đơn': ['Tiền điện', 'Tiền nước', 'Internet', 'Điện thoại'],
      'Giải trí': ['Phim', 'Game', 'Karaoke', 'Du lịch'],
      'Y tế': ['Thuốc', 'Khám bệnh', 'Vitamin'],
      'Giáo dục': ['Sách', 'Khóa học', 'Học phí'],
      'Nhà cửa': ['Thuê nhà', 'Sửa chữa', 'Đồ dùng'],
      'Quần áo': ['Áo', 'Quần', 'Giày'],
    };

    final options = titles[categoryName] ?? ['Chi tiêu'];
    return options[DateTime.now().second % options.length];
  }

  /// Clear all data
  Future<void> clearAll() async {
    await db.delete(db.transactions).go();
    await db.delete(db.categories).go();
    await db.delete(db.wallets).go();
  }
}
