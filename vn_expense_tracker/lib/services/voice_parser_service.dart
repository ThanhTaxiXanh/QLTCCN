// lib/services/voice_parser_service.dart

import '../core/utils/currency_utils.dart';

/// Parsed transaction data from voice input
class ParsedTransaction {
  final double? amount;
  final String? type; // 'expense' or 'income'
  final String? categoryName;
  final String? walletName;
  final DateTime? date;
  final String? note;
  final String originalText;

  const ParsedTransaction({
    this.amount,
    this.type,
    this.categoryName,
    this.walletName,
    this.date,
    this.note,
    required this.originalText,
  });

  bool get isComplete =>
      amount != null && type != null && categoryName != null;

  List<String> getMissingFields() {
    final missing = <String>[];
    if (amount == null) missing.add('Số tiền');
    if (type == null) missing.add('Loại giao dịch');
    if (categoryName == null) missing.add('Danh mục');
    return missing;
  }

  ParsedTransaction copyWith({
    double? amount,
    String? type,
    String? categoryName,
    String? walletName,
    DateTime? date,
    String? note,
    String? originalText,
  }) {
    return ParsedTransaction(
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryName: categoryName ?? this.categoryName,
      walletName: walletName ?? this.walletName,
      date: date ?? this.date,
      note: note ?? this.note,
      originalText: originalText ?? this.originalText,
    );
  }
}

/// Vietnamese voice input parser
/// Handles natural language processing for Vietnamese transaction commands
class VoiceParserService {
  // Expense keywords (chi tiêu)
  static const _expenseKeywords = [
    'chi',
    'trả',
    'mua',
    'tiêu',
    'cost',
    'spent',
    'pay',
    'shopping',
    'hết',
    'tốn',
  ];

  // Income keywords (thu nhập)
  static const _incomeKeywords = [
    'nhận',
    'thu',
    'income',
    'salary',
    'lương',
    'thưởng',
    'kiếm',
    'được',
    'earn',
  ];

  // Category mappings (Vietnamese)
  static const _categoryMappings = {
    // Expense categories
    'ăn': 'Ăn uống',
    'uống': 'Ăn uống',
    'cafe': 'Ăn uống',
    'cà phê': 'Ăn uống',
    'nhà hàng': 'Ăn uống',
    'quán': 'Ăn uống',
    'trưa': 'Ăn uống',
    'tối': 'Ăn uống',
    'sáng': 'Ăn uống',
    'cơm': 'Ăn uống',
    'phở': 'Ăn uống',
    
    'xe': 'Di chuyển',
    'grab': 'Di chuyển',
    'taxi': 'Di chuyển',
    'xăng': 'Di chuyển',
    'bus': 'Di chuyển',
    'xe buýt': 'Di chuyển',
    'gửi xe': 'Di chuyển',
    
    'mua sắm': 'Mua sắm',
    'shopping': 'Mua sắm',
    'siêu thị': 'Mua sắm',
    'vinmart': 'Mua sắm',
    'coopmart': 'Mua sắm',
    
    'điện': 'Hóa đơn',
    'nước': 'Hóa đơn',
    'internet': 'Hóa đơn',
    'điện thoại': 'Hóa đơn',
    'bill': 'Hóa đơn',
    
    'phim': 'Giải trí',
    'game': 'Giải trí',
    'karaoke': 'Giải trí',
    'du lịch': 'Giải trí',
    'vui chơi': 'Giải trí',
    
    'thuốc': 'Y tế',
    'bệnh viện': 'Y tế',
    'khám': 'Y tế',
    'y tế': 'Y tế',
    
    'sách': 'Giáo dục',
    'học': 'Giáo dục',
    'khóa học': 'Giáo dục',
    
    'nhà': 'Nhà cửa',
    'thuê': 'Nhà cửa',
    'sửa chữa': 'Nhà cửa',
    
    'quần áo': 'Quần áo',
    'giày': 'Quần áo',
    'áo': 'Quần áo',
    
    // Income categories
    'lương': 'Lương',
    'salary': 'Lương',
    
    'thưởng': 'Thưởng',
    'bonus': 'Thưởng',
    
    'cổ phiếu': 'Đầu tư',
    'invest': 'Đầu tư',
    'đầu tư': 'Đầu tư',
    
    'bán': 'Bán hàng',
    'sell': 'Bán hàng',
  };

  // Wallet/Bank name mappings
  static const _walletMappings = {
    'vietcombank': 'Vietcombank',
    'vcb': 'Vietcombank',
    'techcombank': 'Techcombank',
    'tcb': 'Techcombank',
    'vietinbank': 'VietinBank',
    'viettinbank': 'VietinBank',
    'mbbank': 'MB Bank',
    'mb': 'MB Bank',
    'acb': 'ACB',
    'vpbank': 'VPBank',
    'bidv': 'BIDV',
    'agribank': 'Agribank',
    'sacombank': 'Sacombank',
    'tiền mặt': 'Tiền mặt',
    'cash': 'Tiền mặt',
    'thẻ': 'Thẻ tín dụng',
    'card': 'Thẻ tín dụng',
  };

  /// Parse Vietnamese voice input into structured transaction data
  static ParsedTransaction parse(String text) {
    text = text.toLowerCase().trim();
    
    return ParsedTransaction(
      amount: _parseAmount(text),
      type: _parseType(text),
      categoryName: _parseCategory(text),
      walletName: _parseWallet(text),
      date: _parseDate(text),
      note: _extractNote(text),
      originalText: text,
    );
  }

  /// Extract amount from text
  static double? _parseAmount(String text) {
    // Try Vietnamese number parsing
    final amount = CurrencyUtils.parseVietnameseNumber(text);
    if (amount != null) return amount;

    // Try regex patterns
    final patterns = [
      r'(\d+(?:[.,]\d+)?)\s*(?:triệu|tr|million)',
      r'(\d+(?:[.,]\d+)?)\s*(?:nghìn|ngàn|k|thousand)',
      r'(\d+(?:[.,]\d+)?)\s*(?:tỷ|billion)',
      r'(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d+)?)',
    ];

    for (final pattern in patterns) {
      final regex = RegExp(pattern);
      final match = regex.firstMatch(text);
      if (match != null) {
        final numStr = match.group(1)!.replaceAll(',', '.');
        final num = double.tryParse(numStr);
        if (num != null) {
          // Apply multiplier based on unit
          if (text.contains('triệu') || text.contains('tr') || text.contains('million')) {
            return num * 1000000;
          } else if (text.contains('nghìn') || text.contains('ngàn') || text.contains('k')) {
            return num * 1000;
          } else if (text.contains('tỷ') || text.contains('billion')) {
            return num * 1000000000;
          }
          return num;
        }
      }
    }

    return null;
  }

  /// Determine transaction type (expense or income)
  static String? _parseType(String text) {
    // Check for expense keywords
    for (final keyword in _expenseKeywords) {
      if (text.contains(keyword)) {
        return 'expense';
      }
    }

    // Check for income keywords
    for (final keyword in _incomeKeywords) {
      if (text.contains(keyword)) {
        return 'income';
      }
    }

    // Default to expense if amount is mentioned but no clear type
    if (_parseAmount(text) != null) {
      return 'expense';
    }

    return null;
  }

  /// Extract category from text using fuzzy matching
  static String? _parseCategory(String text) {
    // Direct match
    for (final entry in _categoryMappings.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }

    // Fuzzy match (partial word matching)
    String? bestMatch;
    int bestScore = 0;

    for (final entry in _categoryMappings.entries) {
      final keyword = entry.key;
      final words = text.split(' ');
      
      for (final word in words) {
        if (word.contains(keyword) || keyword.contains(word)) {
          final score = keyword.length;
          if (score > bestScore) {
            bestScore = score;
            bestMatch = entry.value;
          }
        }
      }
    }

    return bestMatch;
  }

  /// Extract wallet/bank name from text
  static String? _parseWallet(String text) {
    for (final entry in _walletMappings.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Parse date from text
  static DateTime? _parseDate(String text) {
    final now = DateTime.now();

    // Check for "today" keywords
    if (text.contains('hôm nay') || 
        text.contains('today') || 
        text.contains('bây giờ')) {
      return now;
    }

    // Check for "yesterday" keywords
    if (text.contains('hôm qua') || text.contains('yesterday')) {
      return now.subtract(const Duration(days: 1));
    }

    // Check for "tomorrow" keywords
    if (text.contains('ngày mai') || text.contains('tomorrow')) {
      return now.add(const Duration(days: 1));
    }

    // Try parsing specific dates: "15/1", "ngày 15 tháng 1"
    final datePattern = RegExp(r'(\d{1,2})[\/\-](\d{1,2})(?:[\/\-](\d{2,4}))?');
    final match = datePattern.firstMatch(text);
    
    if (match != null) {
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final yearStr = match.group(3);
      final year = yearStr != null ? int.parse(yearStr) : now.year;
      
      try {
        return DateTime(year, month, day);
      } catch (e) {
        return null;
      }
    }

    // Vietnamese date format: "ngày 15 tháng 1"
    final vnDatePattern = RegExp(r'ngày\s+(\d{1,2})\s+tháng\s+(\d{1,2})');
    final vnMatch = vnDatePattern.firstMatch(text);
    
    if (vnMatch != null) {
      final day = int.parse(vnMatch.group(1)!);
      final month = int.parse(vnMatch.group(2)!);
      
      try {
        return DateTime(now.year, month, day);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Extract note/description from text
  static String? _extractNote(String text) {
    // Remove parsed components and return remainder as note
    // This is a simplified implementation
    // You might want to be more sophisticated here
    
    if (text.length > 100) {
      return text.substring(0, 100);
    }
    
    return null;
  }

  /// Get example phrases for UI display
  static List<String> getExamplePhrases() {
    return [
      'Hôm nay chi 120 ngàn ăn trưa tại VinMart dùng Vietcombank',
      'Nhận lương 10 triệu',
      'Mua sắm hết 1.5 triệu',
      'Trả tiền điện 500k',
      'Chi 50k cafe',
      'Đổ xăng 200 ngàn',
      'Nhận thưởng 5 triệu',
      'Mua quần áo 300k',
    ];
  }
}
