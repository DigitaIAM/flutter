import 'package:flutter/material.dart';

class FormController {
  final Map<String, TextEditingController> _textControllers = {};

  TextEditingController controller(String id) {
    late TextEditingController? ret = _textControllers[id];
    if (ret == null) {
      TextEditingController newCon = TextEditingController();
      _textControllers.addEntries([MapEntry(id, newCon)]);
      return newCon;
    }
    return ret;
  }
}