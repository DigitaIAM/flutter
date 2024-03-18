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

  static String f(String data) {
    final number = double.tryParse(data);
    if (number != null) {
      return NumberFormat.decimalPattern('ru').format(number.toPrecision(2));
    } else {
      return data;
    }
  }
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}
