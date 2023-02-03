import 'dart:convert';
import 'package:equatable/equatable.dart';

class MemoryItem extends Equatable {
  const MemoryItem({required this.id, required this.json});

  final String id;
  final Map<String, dynamic> json;

  MemoryItem.clone(MemoryItem item): this(id: item.id, json: jsonDecode(jsonEncode(item.json))); // Map.from(item.json)

  MemoryItem clone() {
    return MemoryItem.clone(this);
  }

  String label() {
    return json["label"] ?? json["name"] ?? "";
  }

  save() {
    // TODO?
  }

  get isNew => id == 'new';
  get updatedAt => null;

  @override
  List<Object> get props => [id, json];

  static create() => const MemoryItem(id: 'new', json: {});
}