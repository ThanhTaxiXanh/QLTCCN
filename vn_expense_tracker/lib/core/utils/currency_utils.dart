// lib/core/utils/currency_utils.dart
import 'package:intl/intl.dart';

class CurrencyUtils {
  static final _vndFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  
  static final _usdFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );
  
  static final _compactFormatter = NumberFormat.compact(locale: 'vi_VN');
  
  /// Format amount with currency symbol
  static String format(double amount, {String currency = 'VND'}) {
    if (currency == 'VND') {
      return _vndFormatter.format(amount);
    } else if (currency == 'USD') {
      return _usdFormatter.format(amount);
    }
    return amount.toStringAsFixed(0);
  }
  
  /// Format amount in compact form (1K, 1M, etc.)
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
  
  /// Format with thousand separator only (no symbol)
  static String formatNumber(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amount);
  }
  
  /// Parse Vietnamese number text to double
  /// Handles: "100k", "1.5 triệu", "10 triệu", etc.
  static double? parseVietnameseNumber(String text) {
    text = text.toLowerCase().trim();
    
    // Remove currency symbols
    text = text.replaceAll(RegExp(r'[₫đvnd]'), '');
    text = text.replaceAll(',', '.');
    
    // Handle "k" (thousand)
    if (text.contains('k')) {
      final numStr = text.replaceAll('k', '').trim();
      final num = double.tryParse(numStr);
      return num != null ? num * 1000 : null;
    }
    
    // Handle "triệu" (million)
    if (text.contains('triệu') || text.contains('tr')) {
      final numStr = text
          .replaceAll('triệu', '')
          .replaceAll('tr', '')
          .trim();
      final num = double.tryParse(numStr);
      return num != null ? num * 1000000 : null;
    }
    
    // Handle "tỷ" (billion)
    if (text.contains('tỷ')) {
      final numStr = text.replaceAll('tỷ', '').trim();
      final num = double.tryParse(numStr);
      return num != null ? num * 1000000000 : null;
    }
    
    // Handle "nghìn" or "ngàn" (thousand)
    if (text.contains('nghìn') || text.contains('ngàn')) {
      final numStr = text
          .replaceAll('nghìn', '')
          .replaceAll('ngàn', '')
          .trim();
      final num = double.tryParse(numStr);
      return num != null ? num * 1000 : null;
    }
    
    // Remove dots used as thousand separators (Vietnamese style)
    text = text.replaceAll('.', '');
    
    // Try parsing as regular number
    return double.tryParse(text);
  }
  
  /// Format percentage
  static String formatPercentage(double percentage, {bool showSign = true}) {
    final sign = showSign && percentage > 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(1)}%';
  }
  
  /// Get color for percentage (green for positive, red for negative)
  static bool isPositivePercentage(double percentage, {bool isExpense = false}) {
    if (isExpense) {
      // For expenses, negative change is good
      return percentage < 0;
    } else {
      // For income, positive change is good
      return percentage > 0;
    }
  }
}
