// lib/services/lunar_calendar_service.dart
import 'dart:math' as math;
import '../models/lunar.dart';

class LunarCalendarService {
  static const double _JD_EPOCH = 2415021.076998695;

  static const List<String> LUNAR_MONTH = [
    "Tháng Giêng","Tháng Hai","Tháng Ba","Tháng Tư","Tháng Năm","Tháng Sáu",
    "Tháng Bảy","Tháng Tám","Tháng Chín","Tháng Mười","Tháng Một","Tháng Chạp"
  ];

  static const List<String> CAN = [
    "Canh","Tân","Nhâm","Quý","Giáp","Ất","Bính","Đinh","Mậu","Kỷ"
  ];

  static const List<String> CHI = [
    "Thân","Dậu","Tuất","Hợi","Tí","Sửu","Dần","Mão","Thìn","Tỵ","Ngọ","Mùi"
  ];

  static const List<bool> GIO_HOANG_DAO_RULE = [
    true, true, false, false, true, true, false, true, false, false, true, false
  ];

  static const List<String> HOUR = [
    "Tí (23h-1h)","Sửu (1h-3h)","Dần (3h-5h)","Mão (5h-7h)",
    "Thìn (7h-9h)","Tỵ (9h-11h)","Ngọ (11h-13h)","Mùi (13h-15h)",
    "Thân (15h-17h)","Dậu (17h-19h)","Tuất (19h-21h)","Hợi (21h-23h)"
  ];

  /// Trả về model Lunar (bao gồm can/chi ngày, tháng, năm và giờ hoàng đạo)
  static Lunar convertSolar2Lunar(int dd, int mm, int yy, double timeZone) {
    final dayNumber = _jdFromDate(dd, mm, yy);

    final chiDayIndex = (dayNumber + 5) % 12;
    final canChiDay = '${CAN[(dayNumber + 3) % 10]} ${CHI[chiDayIndex]}';

    final List<String> goodHours = [];
    final shift = (chiDayIndex % 6) * 2;
    for (int i = 0; i < 12; i++) {
      if (GIO_HOANG_DAO_RULE[(i - shift + 12) % 12]) {
        goodHours.add(HOUR[i]);
      }
    }

    int k = ((dayNumber - _JD_EPOCH) / 29.530588853).floor();
    int monthStart = _getNewMoonDay(k + 1, timeZone);
    if (monthStart > dayNumber) monthStart = _getNewMoonDay(k, timeZone);

    int a11 = _getLunarMonth11(yy, timeZone);
    int b11 = a11;
    int lunarYear;
    if (a11 >= monthStart) {
      lunarYear = yy;
      a11 = _getLunarMonth11(yy - 1, timeZone);
    } else {
      lunarYear = yy + 1;
      b11 = _getLunarMonth11(yy + 1, timeZone);
    }

    int lunarDay = dayNumber - monthStart + 1;
    int diff = ((monthStart - a11) / 29).floor();
    int lunarMonth = diff + 11;
    bool isLeap = false;

    if (b11 - a11 > 365) {
      int leapMonthDiff = _getLeapMonthOffset(a11, timeZone);
      if (diff >= leapMonthDiff) {
        lunarMonth = diff + 10;
        if (diff == leapMonthDiff) isLeap = true;
      }
    }

    if (lunarMonth > 12) lunarMonth -= 12;
    if (lunarMonth >= 11 && diff < 4) lunarYear--;

    final lunarMonthName =
        LUNAR_MONTH[lunarMonth - 1] + (isLeap ? " Nhuận" : "");

    final canYearIndex = lunarYear % 10;
    final canMonthOffset =
        canYearIndex % 5 + ((canYearIndex % 5 + 7) % 10) * 2;

    final canChiMonth =
        '${CAN[(canMonthOffset + lunarMonth - 1) % 10]} ${CHI[(lunarMonth + 5) % 12]}';

    final canChiYear = '${CAN[canYearIndex]} ${CHI[lunarYear % 12]}';

    return Lunar(
      day: lunarDay,
      month: lunarMonth,
      year: lunarYear,
      isLeap: isLeap,
      lunarMonthName: lunarMonthName,
      canChiDay: canChiDay,
      canChiMonth: canChiMonth,
      canChiYear: canChiYear,
      goodHours: goodHours,
    );
  }

  static DateTime convertLunar2Solar(
      int lunarDay, int lunarMonth, int lunarYear, int lunarLeap, double timeZone) {
    int a11, b11;
    if (lunarMonth < 11) {
      a11 = _getLunarMonth11(lunarYear - 1, timeZone);
      b11 = _getLunarMonth11(lunarYear, timeZone);
    } else {
      a11 = _getLunarMonth11(lunarYear, timeZone);
      b11 = _getLunarMonth11(lunarYear + 1, timeZone);
    }

    int k = (0.5 + (a11 - _JD_EPOCH) / 29.530588853).floor();
    int off = lunarMonth - 11;
    if (off < 0) off += 12;

    if (b11 - a11 > 365) {
      int leapOff = _getLeapMonthOffset(a11, timeZone);
      int leapMonth = leapOff - 2;
      if (leapMonth < 0) leapMonth += 12;
      if (lunarLeap != 0 && lunarMonth != leapMonth) {
        throw Exception('Invalid lunar leap month');
      } else if (lunarLeap != 0 || off >= leapOff) {
        off += 1;
      }
    }

    int monthStart = _getNewMoonDay(k + off, timeZone);
    return _jdToDate(monthStart + lunarDay - 1);
  }

  // ---------- core astronomical helpers (giữ nguyên thuật toán gốc) ----------

  static int _getLeapMonthOffset(int a11, double timeZone) {
    int k = ((a11 - _JD_EPOCH) / 29.530588853).floor();
    int last = 0;
    int i = 1;
    int arc =
        (_getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone) / 30).floor();
    do {
      last = arc;
      i++;
      arc = (_getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone) / 30).floor();
    } while (arc != last && i < 14);
    return i - 1;
  }

  static double _sunLongitudeAA98(double jdn) {
    double T = (jdn - 2451545.0) / 36525;
    double T2 = T * T;
    double dr = math.pi / 180;
    double M = 357.52910 + 35999.05030 * T - 0.0001559 * T2 - 0.00000048 * T * T2;
    double L0 = 280.46645 + 36000.76983 * T + 0.0003032 * T2;
    double DL = (1.914600 - 0.004817 * T - 0.000014 * T2) * math.sin(dr * M);
    DL += (0.019993 - 0.000101 * T) * math.sin(dr * 2 * M) + 0.000290 * math.sin(dr * 3 * M);
    double L = L0 + DL;
    return L - 360 * (L / 360).floor();
  }

  static double _getSunLongitude(int dayNumber, double timeZone) =>
      _sunLongitudeAA98(dayNumber - 0.5 - timeZone / 24);

  static int _getLunarMonth11(int yy, double timeZone) {
    double off = _jdFromDate(31, 12, yy) - _JD_EPOCH;
    int k = (off / 29.530588853).floor();
    int nm = _getNewMoonDay(k, timeZone);
    if ((_getSunLongitude(nm, timeZone) / 30).floor() >= 9) {
      nm = _getNewMoonDay(k - 1, timeZone);
    }
    return nm;
  }

  static double _newMoonAA98(int k) {
    double T = k / 1236.85;
    double T2 = T * T;
    double T3 = T2 * T;
    double dr = math.pi / 180;
    double jd = 2415020.75933 + 29.53058868 * k + 0.0001178 * T2 - 0.000000155 * T3;
    jd += 0.00033 * math.sin((166.56 + 132.87 * T - 0.009173 * T2) * dr);
    double M = 359.2242 + 29.10535608 * k - 0.0000333 * T2 - 0.00000347 * T3;
    double Mpr = 306.0253 + 385.81691806 * k + 0.0107306 * T2 + 0.00001236 * T3;
    double F = 21.2964 + 390.67050646 * k - 0.0016528 * T2 - 0.00000239 * T3;
    double C1 = (0.1734 - 0.000393 * T) * math.sin(dr * M) +
        0.0021 * math.sin(2 * dr * M) -
        0.4068 * math.sin(dr * Mpr) +
        0.0161 * math.sin(dr * 2 * Mpr) -
        0.0004 * math.sin(dr * 3 * Mpr) +
        0.0104 * math.sin(dr * 2 * F) -
        0.0051 * math.sin(dr * (M + Mpr)) -
        0.0074 * math.sin(dr * (M - Mpr)) +
        0.0004 * math.sin(dr * (2 * F + M)) -
        0.0004 * math.sin(dr * (2 * F - M)) -
        0.0006 * math.sin(dr * (2 * F + Mpr)) +
        0.0010 * math.sin(dr * (2 * F - Mpr)) +
        0.0005 * math.sin(dr * (2 * Mpr + M));
    double deltat;
    if (T < -11) {
      deltat = 0.001 + 0.000839 * T + 0.0002261 * T2 - 0.00000845 * T3 - 0.000000081 * T * T3;
    } else {
      deltat = -0.000278 + 0.000265 * T + 0.000262 * T2;
    }
    return jd + C1 - deltat;
  }

  static int _getNewMoonDay(int k, double timeZone) => (_newMoonAA98(k) + 0.5 + timeZone / 24).floor();

  static int _jdFromDate(int dd, int mm, int yy) {
    int a = (14 - mm) ~/ 12;
    int y = yy + 4800 - a;
    int m = mm + 12 * a - 3;
    int jd = dd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
    if (jd < 2299161) {
      jd = dd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - 32083;
    }
    return jd;
  }

  static DateTime _jdToDate(int jd) {
    int a, b, c;
    if (jd > 2299160) {
      a = jd + 32044;
      b = (4 * a + 3) ~/ 146097;
      c = a - (b * 146097) ~/ 4;
    } else {
      b = 0;
      c = jd + 32082;
    }
    int d = (4 * c + 3) ~/ 1461;
    int e = c - (1461 * d) ~/ 4;
    int m = (5 * e + 2) ~/ 153;
    int day = e - (153 * m + 2) ~/ 5 + 1;
    int month = m + 3 - 12 * (m ~/ 10);
    int year = b * 100 + d - 4800 + m ~/ 10;
    return DateTime(year, month, day);
  }
}
