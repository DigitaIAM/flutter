import 'package:intl/intl.dart';

class DT {
  static DateTime today() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime beginningOfMonth() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static DateTime parse(String date) {
    return DateTime.parse(date);
  }

  static String format(String date) {
    return f(DateTime.parse(date));
  }

  static String f(DateTime date) {
    return DateFormat.yMMMMd('ru').format(date);
  }

  static String pretty(String date) {
    final split = date.toString().split('-');
    return split.length == 3 ? '${split[2]}.${split[1]}.${split[0]}' : '?';
  }
}

extension DateTimeExtension on DateTime {
  String toIso8601StringWithTz() {
    // Get offset
    final timeZoneOffset = this.timeZoneOffset;
    final sign = timeZoneOffset.isNegative ? '-' : '+';
    final hours = timeZoneOffset.inHours.abs().toString();
    final minutes = timeZoneOffset.inMinutes.abs().remainder(60).toString();

    return '${toIso8601String()}$sign${hours.padLeft(2, '0')}:${minutes.padLeft(2, '0')}';
  }
}
