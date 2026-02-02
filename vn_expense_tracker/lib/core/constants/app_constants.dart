// lib/core/constants/app_constants.dart

class AppConstants {
  // App Info
  static const String appName = 'Chi Tiêu Thông Minh';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'expense_tracker.db';
  static const int databaseVersion = 1;
  
  // Settings Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyPinHash = 'pin_hash';
  static const String keyDailyReminder = 'daily_reminder';
  static const String keyReminderTime = 'reminder_time';
  static const String keyDefaultWallet = 'default_wallet';
  
  // Currencies
  static const String currencyVND = 'VND';
  static const String currencyUSD = 'USD';
  
  // Transaction Types
  static const String typeExpense = 'expense';
  static const String typeIncome = 'income';
  
  // Date Formats
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatDatabase = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Pagination
  static const int transactionsPerPage = 50;
  
  // Voice Input
  static const String voiceLocale = 'vi-VN';
  static const Duration voiceTimeout = Duration(seconds: 30);
  
  // Backup
  static const String backupFolderName = 'ExpenseTrackerBackups';
  static const String backupFileExtension = '.json';
  
  // Chart Settings
  static const int maxChartDataPoints = 30;
  
  // Validation
  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  static const int maxTitleLength = 100;
  static const int maxNoteLength = 500;
  static const double maxAmount = 999999999999.0; // ~1 trillion
}

// Default Categories for Vietnamese Market
class DefaultCategories {
  static const expenseCategories = [
    {'name': 'Ăn uống', 'icon': '🍜', 'color': 'FF6B6B'},
    {'name': 'Di chuyển', 'icon': '🚗', 'color': '4ECDC4'},
    {'name': 'Mua sắm', 'icon': '🛍️', 'color': 'FF9FF3'},
    {'name': 'Hóa đơn', 'icon': '📄', 'color': 'FFA07A'},
    {'name': 'Giải trí', 'icon': '🎮', 'color': 'DDA15E'},
    {'name': 'Y tế', 'icon': '💊', 'color': 'F4A261'},
    {'name': 'Giáo dục', 'icon': '📚', 'color': '2A9D8F'},
    {'name': 'Nhà cửa', 'icon': '🏠', 'color': 'E76F51'},
    {'name': 'Quần áo', 'icon': '👕', 'color': 'BC6C25'},
    {'name': 'Khác', 'icon': '📌', 'color': '9E9E9E'},
  ];
  
  static const incomeCategories = [
    {'name': 'Lương', 'icon': '💰', 'color': '2ECC71'},
    {'name': 'Thưởng', 'icon': '🎁', 'color': '27AE60'},
    {'name': 'Đầu tư', 'icon': '📈', 'color': '16A085'},
    {'name': 'Bán hàng', 'icon': '💵', 'color': '1ABC9C'},
    {'name': 'Khác', 'icon': '💸', 'color': '52B788'},
  ];
}
