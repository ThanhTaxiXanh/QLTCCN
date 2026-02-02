// test/core/utils/currency_utils_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vn_expense_tracker/core/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils', () {
    group('Vietnamese Number Parsing', () {
      test('parses "100k" as 100,000', () {
        expect(CurrencyUtils.parseVietnameseNumber('100k'), 100000);
      });

      test('parses "1.5 triệu" as 1,500,000', () {
        expect(CurrencyUtils.parseVietnameseNumber('1.5 triệu'), 1500000);
      });

      test('parses "10 triệu" as 10,000,000', () {
        expect(CurrencyUtils.parseVietnameseNumber('10 triệu'), 10000000);
      });

      test('parses "2 tỷ" as 2,000,000,000', () {
        expect(CurrencyUtils.parseVietnameseNumber('2 tỷ'), 2000000000);
      });

      test('parses "50 nghìn" as 50,000', () {
        expect(CurrencyUtils.parseVietnameseNumber('50 nghìn'), 50000);
      });

      test('handles currency symbols', () {
        expect(CurrencyUtils.parseVietnameseNumber('100k₫'), 100000);
        expect(CurrencyUtils.parseVietnameseNumber('10 triệu đ'), 10000000);
      });

      test('handles commas as decimal separator', () {
        expect(CurrencyUtils.parseVietnameseNumber('1,5 triệu'), 1500000);
      });

      test('handles dots as thousand separator', () {
        expect(CurrencyUtils.parseVietnameseNumber('100.000'), 100000);
        expect(CurrencyUtils.parseVietnameseNumber('1.500.000'), 1500000);
      });

      test('returns null for invalid input', () {
        expect(CurrencyUtils.parseVietnameseNumber('abc'), isNull);
        expect(CurrencyUtils.parseVietnameseNumber(''), isNull);
      });
    });

    group('Formatting', () {
      test('formats VND correctly', () {
        expect(CurrencyUtils.format(1000000), contains('1.000.000'));
        expect(CurrencyUtils.format(1000000), contains('₫'));
      });

      test('formats compact numbers', () {
        expect(CurrencyUtils.formatCompact(1500), '1K');
        expect(CurrencyUtils.formatCompact(1500000), '1.5M');
        expect(CurrencyUtils.formatCompact(500), '500');
      });

      test('formats percentage', () {
        expect(CurrencyUtils.formatPercentage(12.5), '+12.5%');
        expect(CurrencyUtils.formatPercentage(-5.2), '-5.2%');
        expect(CurrencyUtils.formatPercentage(12.5, showSign: false), '12.5%');
      });
    });
  });
}
