// lib/services/nlp_parser.dart
import 'package:monease_app/services/database.dart';

/// Parsed transaction data from voice input
class ParsedTransaction {
  final String? type; // 'income' or 'expense'
  final double? amount;
  final int? categoryId;
  final String? categoryName;
  final int? walletId;
  final String? walletName;
  final DateTime? date;
  final String? note;
  final List<String> issues; // Parsing issues or ambiguities

  ParsedTransaction({
    this.type,
    this.amount,
    this.categoryId,
    this.categoryName,
    this.walletId,
    this.walletName,
    this.date,
    this.note,
    this.issues = const [],
  });

  bool get isValid => type != null && amount != null;
  bool get isComplete => isValid && categoryId != null && walletId != null;
}

/// Vietnamese NLP Parser for extracting transaction details from speech
class NLPParser {
  final AppDatabase db;

  NLPParser(this.db);

  /// Main parsing method
  Future<ParsedTransaction> parse(String text) async {
    final normalized = _normalizeText(text);
    
    final type = _extractType(normalized);
    final amount = _extractAmount(normalized);
    final date = _extractDate(normalized);
    final note = _extractNote(normalized);
    
    // Load categories and wallets for matching
    final categories = await db.getAllCategories();
    final wallets = await db.getAllWallets();
    
    final categoryMatch = _matchCategory(normalized, categories, type);
    final walletMatch = _matchWallet(normalized, wallets);
    
    final issues = <String>[];
    if (type == null) issues.add('Không xác định được loại giao dịch');
    if (amount == null) issues.add('Không xác định được số tiền');
    if (categoryMatch == null && type != null) issues.add('Không xác định được danh mục');
    if (walletMatch == null) issues.add('Không xác định được ví');
    
    return ParsedTransaction(
      type: type,
      amount: amount,
      categoryId: categoryMatch?.$1,
      categoryName: categoryMatch?.$2,
      walletId: walletMatch?.$1,
      walletName: walletMatch?.$2,
      date: date ?? DateTime.now(),
      note: note,
      issues: issues,
    );
  }

  /// Normalize text: lowercase, remove extra spaces, normalize Vietnamese
  String _normalizeText(String text) {
    return text.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Extract transaction type from keywords
  String? _extractType(String text) {
    // Expense keywords
    const expenseKeywords = [
      'chi', 'mua', 'trả', 'đi', 'hết', 'mất', 'tiêu', 'tốn',
      'thanh toán', 'nộp', 'đóng', 'bill', 'hóa đơn'
    ];
    
    // Income keywords
    const incomeKeywords = [
      'thu', 'nhận', 'lương', 'được', 'kiếm', 'kiếm được',
      'thu nhập', 'thưởng', 'trúng', 'bán'
    ];
    
    for (final keyword in incomeKeywords) {
      if (text.contains(keyword)) return 'income';
    }
    
    for (final keyword in expenseKeywords) {
      if (text.contains(keyword)) return 'expense';
    }
    
    // Default to expense if ambiguous
    return 'expense';
  }

  /// Extract amount from text with Vietnamese number formats
  double? _extractAmount(String text) {
    // Patterns for Vietnamese numbers
    final patterns = [
      // "100 nghìn", "50 triệu"
      RegExp(r'(\d+(?:[.,]\d+)?)\s*(nghìn|ngàn|k)', caseSensitive: false),
      RegExp(r'(\d+(?:[.,]\d+)?)\s*(triệu|tr|m)', caseSensitive: false),
      RegExp(r'(\d+(?:[.,]\d+)?)\s*(tỷ|ty|b)', caseSensitive: false),
      // "100k", "1.5m"
      RegExp(r'(\d+(?:[.,]\d+)?)(k|m|b)', caseSensitive: false),
      // Plain numbers: "100000", "1.500.000"
      RegExp(r'(\d+(?:[.,]\d+)*)\s*(?:đồng|dong|₫|d|vnd)?'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final numberStr = match.group(1)!.replaceAll(',', '.');
        final number = double.tryParse(numberStr);
        if (number == null) continue;
        
        final suffix = match.group(2)?.toLowerCase();
        
        switch (suffix) {
          case 'nghìn':
          case 'ngàn':
          case 'k':
            return number * 1000;
          case 'triệu':
          case 'tr':
          case 'm':
            return number * 1000000;
          case 'tỷ':
          case 'ty':
          case 'b':
            return number * 1000000000;
          default:
            // If number is very large without suffix, assume it's already in VND
            if (number >= 1000) {
              return number;
            }
            // Small numbers might need interpretation
            return number;
        }
      }
    }
    
    return null;
  }

  /// Extract date from text (relative dates)
  DateTime _extractDate(String text) {
    final now = DateTime.now();
    
    if (text.contains('hôm nay')) {
      return DateTime(now.year, now.month, now.day);
    }
    
    if (text.contains('hôm qua')) {
      return DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
    }
    
    if (text.contains('hôm kia')) {
      return DateTime(now.year, now.month, now.day).subtract(const Duration(days: 2));
    }
    
    if (text.contains('tuần trước') || text.contains('tuần rồi')) {
      return now.subtract(const Duration(days: 7));
    }
    
    if (text.contains('tháng trước') || text.contains('tháng rồi')) {
      return DateTime(now.year, now.month - 1, now.day);
    }
    
    // Try to extract specific date: "ngày 25/1", "25 tháng 1"
    final datePattern = RegExp(r'(?:ngày\s*)?(\d{1,2})[/\s](\d{1,2})');
    final match = datePattern.firstMatch(text);
    if (match != null) {
      final day = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      if (day != null && month != null && day >= 1 && day <= 31 && month >= 1 && month <= 12) {
        return DateTime(now.year, month, day);
      }
    }
    
    return now;
  }

  /// Match category from text
  (int, String)? _matchCategory(String text, List<Category> categories, String? type) {
    if (type == null) return null;
    
    final categoryKeywords = <String, List<String>>{
      // Expense categories
      'Ăn uống': ['ăn', 'uống', 'cafe', 'cà phê', 'quán', 'nhà hàng', 'ăn trưa', 'ăn tối', 'buffet', 'food'],
      'Di chuyển': ['xe', 'grab', 'taxi', 'xe ôm', 'xăng', 'dầu', 'xe buýt', 'bus', 'tàu', 'máy bay', 'vé'],
      'Mua sắm': ['mua', 'shopping', 'siêu thị', 'chợ', 'quần áo', 'giày', 'túi', 'đồ', 'sắm'],
      'Giải trí': ['phim', 'game', 'chơi', 'vui', 'du lịch', 'giải trí', 'karaoke', 'bar', 'club'],
      'Sức khỏe': ['bác sĩ', 'bệnh viện', 'thuốc', 'khám', 'y tế', 'sức khỏe', 'phòng khám'],
      'Giáo dục': ['học', 'sách', 'khóa học', 'trường', 'học phí', 'giáo dục'],
      'Hóa đơn': ['điện', 'nước', 'internet', 'wifi', 'điện thoại', 'hóa đơn', 'bill', 'tiền nhà', 'thuê nhà'],
      // Income categories
      'Lương': ['lương', 'salary', 'công ty', 'làm việc'],
      'Kinh doanh': ['bán', 'kinh doanh', 'doanh thu', 'khách hàng'],
      'Đầu tư': ['đầu tư', 'cổ phiếu', 'chứng khoán', 'tiền lãi'],
      'Quà tặng': ['quà', 'tặng', 'gift', 'được tặng'],
    };
    
    for (final category in categories) {
      if (category.type != type) continue;
      
      final keywords = categoryKeywords[category.name];
      if (keywords == null) continue;
      
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          return (category.id, category.name);
        }
      }
    }
    
    // Return first category of the correct type as fallback
    final fallback = categories.where((c) => c.type == type).firstOrNull;
    if (fallback != null) {
      return (fallback.id, fallback.name);
    }
    
    return null;
  }

  /// Match wallet from text
  (int, String)? _matchWallet(String text, List<Wallet> wallets) {
    // Try exact name match first
    for (final wallet in wallets) {
      final normalizedWalletName = wallet.name.toLowerCase();
      if (text.contains(normalizedWalletName)) {
        return (wallet.id, wallet.name);
      }
    }
    
    // Try common wallet keywords
    const walletKeywords = {
      'vietcombank': ['vietcombank', 'vcb', 'việt com bank'],
      'techcombank': ['techcombank', 'tcb', 'tech com bank'],
      'vietinbank': ['vietinbank', 'vietin', 'viết tín'],
      'bidv': ['bidv', 'bi di vi'],
      'agribank': ['agribank', 'agri'],
      'momo': ['momo'],
      'zalopay': ['zalopay', 'zalo pay'],
      'cash': ['tiền mặt', 'cash', 'túi'],
    };
    
    for (final wallet in wallets) {
      final keywords = walletKeywords[wallet.name.toLowerCase()];
      if (keywords != null) {
        for (final keyword in keywords) {
          if (text.contains(keyword)) {
            return (wallet.id, wallet.name);
          }
        }
      }
    }
    
    // Return default wallet as fallback
    final defaultWallet = wallets.where((w) => w.isDefault).firstOrNull ?? wallets.firstOrNull;
    if (defaultWallet != null) {
      return (defaultWallet.id, defaultWallet.name);
    }
    
    return null;
  }

  /// Extract note (the whole sentence minus other extracted parts)
  String? _extractNote(String text) {
    // For now, return the original text as note
    // In a more sophisticated implementation, remove extracted parts
    return text.isNotEmpty ? text : null;
  }
}
