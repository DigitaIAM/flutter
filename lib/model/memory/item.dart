import 'package:equatable/equatable.dart';

class MemoryItem extends Equatable {
  const MemoryItem({required this.id, required this.json});

  final String id;
  final Map<String, dynamic> json;

  MemoryItem.clone(MemoryItem item): this(id: item.id, json: Map.from(item.json));

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