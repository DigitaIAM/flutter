import 'package:intl/intl.dart';

class DT {
  static String format(String date) {
    return DateFormat.yMMMMd('ru').format(DateTime.parse(date));
  }
}
