import 'dart:async';

import 'package:nae/constants.dart';

class Debouncer {
  Debouncer({
    this.milliseconds = cDebounceUpdate,
  });

  final int milliseconds;

  Timer? timer;

  void run(void Function() action) {
    timer?.cancel();
    timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
