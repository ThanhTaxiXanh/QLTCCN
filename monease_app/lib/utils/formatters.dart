// lib/utils/formatters.dart
import 'package:intl/intl.dart';

class AppFormatters {
  // Currency formatter for Vietnamese Dong
  static final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  
  // Compact currency formatter (10K, 1.5M, etc.)
  static String formatCompactCurrency(double amount) {
    if (amount.abs() >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B₫';
    } else if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M₫';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K₫';
    } else {
      return '${amount.toStringAsFixed(0)}₫';
    }
  }
  
  // Date formatters
  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat timeFormat = DateFormat('HH:mm');
  static final DateFormat dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat monthYearFormat = DateFormat('MM/yyyy');
  static final DateFormat fullDateFormat = DateFormat('EEEE, dd MMMM yyyy', 'vi_VN');
  static final DateFormat dayMonthFormat = DateFormat('dd/MM');
  
  // Weekday names in Vietnamese
  static String getWeekdayName(DateTime date) {
    const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return weekdays[date.weekday % 7];
  }
  
  // Format percentage
  static String formatPercentage(double value) {
    final formatted = value.toStringAsFixed(1);
    return value >= 0 ? '+$formatted%' : '$formatted%';
  }
  
  // Format amount with sign for transaction display
  static String formatTransactionAmount(double amount, String type) {
    final formatted = currencyFormatter.format(amount.abs());
    return type == 'income' ? '+$formatted' : '-$formatted';
  }
}
