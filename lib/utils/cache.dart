import 'dart:collection';

import 'package:nae/models/memory/item.dart';

class Cache {
  static Cache? _instance;

  factory Cache() {
    _instance ??= Cache._internal();

    return _instance!;
  }

  Cache._internal();

  final Map<String, MemoryItem> _cache = HashMap();

  void add(MemoryItem item) {
    _cache[item.id] = item;
    _cache[item.uuid] = item;
  }

  MemoryItem? get(String id) {
    return _cache[id];
  }

  void clear() {
    _cache.clear();
  }
}
