// lib/models/lunar.dart
class Lunar {
  final int day;
  final int month;
  final int year;
  final bool isLeap;

  // bổ sung thông tin Can/Chi và tên tháng, giờ tốt
  final String lunarMonthName;
  final String canChiDay;
  final String canChiMonth;
  final String canChiYear;
  final List<String> goodHours;

  const Lunar({
    required this.day,
    required this.month,
    required this.year,
    required this.isLeap,
    required this.lunarMonthName,
    required this.canChiDay,
    required this.canChiMonth,
    required this.canChiYear,
    required this.goodHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'month': month,
      'year': year,
      'isLeap': isLeap ? 1 : 0,
      'lunarMonthName': lunarMonthName,
      'canChiDay': canChiDay,
      'canChiMonth': canChiMonth,
      'canChiYear': canChiYear,
      'goodHours': goodHours,
    };
  }

  static Lunar fromJson(Map<String, dynamic> j) {
    return Lunar(
      day: j['day'] as int,
      month: j['month'] as int,
      year: j['year'] as int,
      isLeap: (j['isLeap'] as int) != 0,
      lunarMonthName: j['lunarMonthName'] as String,
      canChiDay: j['canChiDay'] as String,
      canChiMonth: j['canChiMonth'] as String,
      canChiYear: j['canChiYear'] as String,
      goodHours: (j['goodHours'] as List).cast<String>(),
    );
  }

  @override
  String toString() =>
      '$day/$month/${year}${isLeap ? " (Nhuận)" : ""} — $lunarMonthName — $canChiDay';
}
