// test/services/voice_parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vn_expense_tracker/services/voice_parser_service.dart';

void main() {
  group('VoiceParserService', () {
    group('Amount Parsing', () {
      test('parses thousands with "k"', () {
        final result = VoiceParserService.parse('chi 100k');
        expect(result.amount, 100000);
      });

      test('parses millions with "triệu"', () {
        final result = VoiceParserService.parse('nhận 10 triệu');
        expect(result.amount, 10000000);
      });

      test('parses decimal millions', () {
        final result = VoiceParserService.parse('mua sắm 1.5 triệu');
        expect(result.amount, 1500000);
      });

      test('parses billions with "tỷ"', () {
        final result = VoiceParserService.parse('đầu tư 2 tỷ');
        expect(result.amount, 2000000000);
      });

      test('parses number with Vietnamese thousand separator', () {
        final result = VoiceParserService.parse('chi 120.000');
        expect(result.amount, 120000);
      });
    });

    group('Type Detection', () {
      test('detects expense from "chi"', () {
        final result = VoiceParserService.parse('chi 50k');
        expect(result.type, 'expense');
      });

      test('detects expense from "mua"', () {
        final result = VoiceParserService.parse('mua sắm 100k');
        expect(result.type, 'expense');
      });

      test('detects income from "nhận"', () {
        final result = VoiceParserService.parse('nhận lương 10 triệu');
        expect(result.type, 'income');
      });

      test('detects income from "thu"', () {
        final result = VoiceParserService.parse('thu 5 triệu');
        expect(result.type, 'income');
      });

      test('defaults to expense if amount present but no clear type', () {
        final result = VoiceParserService.parse('120k ăn trưa');
        expect(result.type, 'expense');
      });
    });

    group('Category Matching', () {
      test('matches food category from "ăn"', () {
        final result = VoiceParserService.parse('chi 50k ăn trưa');
        expect(result.categoryName, 'Ăn uống');
      });

      test('matches food category from "cafe"', () {
        final result = VoiceParserService.parse('chi 45k cafe');
        expect(result.categoryName, 'Ăn uống');
      });

      test('matches transportation from "grab"', () {
        final result = VoiceParserService.parse('chi 80k grab');
        expect(result.categoryName, 'Di chuyển');
      });

      test('matches shopping from "mua sắm"', () {
        final result = VoiceParserService.parse('mua sắm 200k');
        expect(result.categoryName, 'Mua sắm');
      });

      test('matches salary from "lương"', () {
        final result = VoiceParserService.parse('nhận lương 10 triệu');
        expect(result.categoryName, 'Lương');
      });

      test('matches bills from "điện"', () {
        final result = VoiceParserService.parse('trả tiền điện 500k');
        expect(result.categoryName, 'Hóa đơn');
      });
    });

    group('Wallet Detection', () {
      test('detects Vietcombank', () {
        final result = VoiceParserService.parse('chi 100k dùng vietcombank');
        expect(result.walletName, 'Vietcombank');
      });

      test('detects VCB abbreviation', () {
        final result = VoiceParserService.parse('chi 100k vcb');
        expect(result.walletName, 'Vietcombank');
      });

      test('detects cash wallet', () {
        final result = VoiceParserService.parse('chi 100k tiền mặt');
        expect(result.walletName, 'Tiền mặt');
      });

      test('detects Techcombank', () {
        final result = VoiceParserService.parse('chi 100k techcombank');
        expect(result.walletName, 'Techcombank');
      });
    });

    group('Date Parsing', () {
      test('parses "hôm nay" as today', () {
        final result = VoiceParserService.parse('hôm nay chi 100k');
        final today = DateTime.now();
        expect(result.date?.day, today.day);
        expect(result.date?.month, today.month);
        expect(result.date?.year, today.year);
      });

      test('parses "hôm qua" as yesterday', () {
        final result = VoiceParserService.parse('hôm qua chi 100k');
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(result.date?.day, yesterday.day);
        expect(result.date?.month, yesterday.month);
      });

      test('parses specific date "15/1"', () {
        final result = VoiceParserService.parse('chi 100k ngày 15/1');
        expect(result.date?.day, 15);
        expect(result.date?.month, 1);
      });

      test('parses Vietnamese date format', () {
        final result = VoiceParserService.parse('ngày 20 tháng 2 chi 100k');
        expect(result.date?.day, 20);
        expect(result.date?.month, 2);
      });
    });

    group('Complete Phrase Parsing', () {
      test('parses complete Vietnamese phrase', () {
        final result = VoiceParserService.parse(
          'hôm nay chi 120 ngàn ăn trưa tại VinMart dùng Vietcombank'
        );
        
        expect(result.amount, 120000);
        expect(result.type, 'expense');
        expect(result.categoryName, 'Ăn uống');
        expect(result.walletName, 'Vietcombank');
        expect(result.date, isNotNull);
      });

      test('parses income phrase', () {
        final result = VoiceParserService.parse('nhận lương 10 triệu');
        
        expect(result.amount, 10000000);
        expect(result.type, 'income');
        expect(result.categoryName, 'Lương');
      });

      test('parses shopping phrase', () {
        final result = VoiceParserService.parse('mua sắm hết 1.5 triệu');
        
        expect(result.amount, 1500000);
        expect(result.type, 'expense');
        expect(result.categoryName, 'Mua sắm');
      });

      test('parses transportation phrase', () {
        final result = VoiceParserService.parse('đi grab 80k');
        
        expect(result.amount, 80000);
        expect(result.type, 'expense');
        expect(result.categoryName, 'Di chuyển');
      });
    });

    group('Completeness Check', () {
      test('identifies complete transaction', () {
        final result = VoiceParserService.parse('chi 100k ăn trưa');
        expect(result.isComplete, true);
      });

      test('identifies incomplete transaction - missing amount', () {
        final result = VoiceParserService.parse('ăn trưa');
        expect(result.isComplete, false);
        expect(result.getMissingFields(), contains('Số tiền'));
      });

      test('identifies incomplete transaction - missing category', () {
        final result = VoiceParserService.parse('chi 100k');
        expect(result.isComplete, false);
        expect(result.getMissingFields(), contains('Danh mục'));
      });
    });

    group('Edge Cases', () {
      test('handles empty input', () {
        final result = VoiceParserService.parse('');
        expect(result.amount, isNull);
        expect(result.type, isNull);
        expect(result.categoryName, isNull);
      });

      test('handles gibberish input', () {
        final result = VoiceParserService.parse('xyz abc 123');
        expect(result.categoryName, isNull);
      });

      test('handles mixed Vietnamese and English', () {
        final result = VoiceParserService.parse('spent 100k for lunch');
        expect(result.amount, 100000);
        expect(result.type, 'expense');
      });
    });
  });
}
