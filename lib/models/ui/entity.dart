import 'package:flutter/material.dart';
import 'package:nae_hr/models/memory/item.dart';

abstract class Entity {
  List<String> route();
  IconData icon();
  String name();

  Widget screen(String action, MemoryItem entity);
}
