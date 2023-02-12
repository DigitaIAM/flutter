import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:nae/api.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/utils/cache.dart';

class MemoryItem extends Equatable {
  const MemoryItem({required this.id, required this.json});

  final String id;
  final Map<String, dynamic> json;

  MemoryItem.clone(MemoryItem item) : this(id: item.id, json: jsonDecode(jsonEncode(item.json))); // Map.from(item.json)

  MemoryItem clone() {
    return MemoryItem.clone(this);
  }

  String name() {
    return json["name"] ?? "";
  }

  save() {
    // TODO?
  }

  get isNew => id == 'new';

  get updatedAt => null;

  @override
  List<Object> get props => [id, json];

  Future<MemoryItem> enrich(List<Field> schema) async {
    // TODO make configurable

    final cache = Cache();

    final Map<String, dynamic> copy = Map.from(json);
    for (final field in schema) {
      if (field.type is ReferenceType) {
        final name = field.name;
        final type = field.type as ReferenceType;

        final String id = copy[name] ?? '';
        if (id.isNotEmpty) {
          try {
            final cached = cache.get(id);
            if (cached != null) {
              copy[name] = cached;
            } else {
              final response = await Api.feathers().get(serviceName: "memories", objectId: id, params: {
                "oid": Api.instance.oid,
                "ctx": type.ctx,
              });

              final item = MemoryItem(id: id, json: response);
              cache.add(item);
              copy[name] = item;
            }
          } catch (e) {
            copy[name] = MemoryItem(id: id, json: const {});
          }
        } else {
          copy[name] = MemoryItem(id: id, json: const {});
        }
      }
    }

    return MemoryItem(id: id, json: copy);
  }

  static create() => const MemoryItem(id: 'new', json: {});

  static MemoryItem from(Map<String, dynamic> json) => MemoryItem(id: json['_id'], json: json);
}
