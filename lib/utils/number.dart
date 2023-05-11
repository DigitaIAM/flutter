import 'package:intl/intl.dart';

class Number {
  static String format(String data) {
    final number = double.tryParse(data);
    if (number != null) {
      return NumberFormat.compact().format(number);
    } else {
      return data;
    }
  }
}
