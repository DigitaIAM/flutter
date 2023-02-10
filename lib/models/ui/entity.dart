import 'package:flutter/material.dart';
import 'package:nae/models/memory/item.dart';

abstract class Entity {
  List<String> route();

  IconData icon();

  String name();

  Widget screen(String action, MemoryItem entity);
}
