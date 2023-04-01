import 'dart:math';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Utils {
  static final Utils _singleton = Utils._internal();

  static Map<String, String> httpSimpleJsonHeader(String token, String db, String login, String psw) => {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": token,
        "db": db,
        "login": login.toString(),
        "psw": psw,
        "charset": "utf-8",
      };

  static DateFormat format_YYYY_MM_dd = DateFormat('yyyy-MM-dd');
  static DateFormat format_yyyy_MM_dd_hh_mm = DateFormat('yyyy-MM-dd HH:mm');
  static DateFormat format_dd_MM_yyyy_hh_mm = DateFormat('dd.MM.yyyy HH:mm');
  static DateFormat format_dd_MM_yyyy_hh_mm_ss = DateFormat('dd.MM.yyyy HH:mm:ss');
  static DateFormat format_dd_MM = DateFormat('dd.MM');
  static DateFormat format_dd_MM_yyyy = DateFormat('dd.MM.yyyy');

  static DateFormat format_hh_mm = DateFormat('HH:mm');
  static DateFormat format_hh_mm_ss = DateFormat('HH:mm:ss');
  static NumberFormat num_format_0_00 = NumberFormat.simpleCurrency(name: "", decimalDigits: 2);
  static NumberFormat num_format_0 = NumberFormat.simpleCurrency(name: "", decimalDigits: 0);

  static NumberFormat num_format_current = NumberFormat.simpleCurrency(name: "", decimalDigits: 0);

  static String myDateFormat(DateFormat f, DateTime val) {
    return f.format(val);
  }

  static String myDateFormatFromInt(DateFormat f, int val) {
    return f.format(DateTime.fromMillisecondsSinceEpoch(val * 1000));
  }

  static String myDateFormatFromStr(DateFormat f, String val) {
    return f.format(DateTime.fromMillisecondsSinceEpoch(int.parse(val) * 1000));
  }

  static String myNumFormat(NumberFormat f, double d) {
    if (d == 0) {
      return "-";
    }
    return f.format(d);
  }

  static String myNumFormat2(double d) {
    if (d == 0) {
      return "-";
    }
    if (d == d.roundToDouble()) {
      return Utils.num_format_current.format(d);
    } else {
      return Utils.num_format_0_00.format(d);
    }
  }

  static String myNumFormat0(double d) {
    if (d == 0) {
      return "-";
    }
    return Utils.num_format_current.format(d);
  }

  static String myUUID() {
    return const Uuid().v1();
  }

  static double dp(double val, int places) {
    //double mod = pow(10.0, places);
    return 0.0;
  }

  static double checkDouble(dynamic value) {
    if (value == null) {
      return 0.00;
    }

    if (value is String) {
      if (value == "") {
        return 0.0;
      }
      return double.parse(value);
    } else {
      if (value is int) {
        return value + 0.0;
      } else {
        return value;
      }
    }
  }

  static List<String> get days {
    return ['Все', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  }

  factory Utils() {
    return _singleton;
  }

  Utils._internal();

  static double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  static int getDateInt() {
    DateTime now = DateTime.now();
    DateTime d = DateTime(now.year, now.month, now.day);
    int inSeconds = d.millisecondsSinceEpoch ~/ 1000;
    return inSeconds;
  }

  static DateTime getDate() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static int getNowInt() {
    double inSeconds = DateTime.now().millisecondsSinceEpoch / 1000;
    return inSeconds.toInt();
  }

  static DateTime getNow() {
    return DateTime.now();
  }

  static String today() {
    return DateFormat("yyyy-MM-dd").format(DateTime.now());
  }

  static String yesterday() {
    return DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(const Duration(days: 1)));
  }
}
