import 'package:intl/intl.dart';

class DT {
  static String format(String date) {
    return DateFormat.yMMMMd('ru').format(DateTime.parse(date));
  }

  static String pretty(String date) {
    final split = date.toString().split('-');
    return split.length == 3 ? '${split[2]}.${split[1]}.${split[0]}' : '?';
  }
}
