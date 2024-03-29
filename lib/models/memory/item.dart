import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:nae/api.dart';
import 'package:nae/constants.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/utils/cache.dart';

class MemoryItem extends Equatable {
  const MemoryItem({required this.id, required this.json, this.updatedAt = 0});

  final String id;
  final Map<String, dynamic> json;
  final int updatedAt;

  get uuid => json[cUuid];

  get isNew => id == 'new';

  get isEmpty => json.isEmpty;

  get isNotEmpty => !isEmpty;

  @override
  List<Object> get props => [id, updatedAt];

  MemoryItem.clone(MemoryItem item)
      : this(
            id: item.id,
            json: jsonDecode(jsonEncode(item.json)),
            updatedAt: item.updatedAt);

  MemoryItem clone() {
    return MemoryItem.clone(this);
  }

  MemoryItem? operator [](Object? key) {
    final o = json[key];
    if (o is MemoryItem) {
      return o;
    } else if (o is Map<String, dynamic>) {
      return MemoryItem.from(o);
    }
    return null;
  }

  String name() {
    // workaround for product
    final partNumber = json["part_number"];
    if (partNumber is String) {
      return "$partNumber ${json[cName] ?? ""}";
    }
    // workaround: use 'date' as name for batch objects
    return json[cName] ?? json[cDate] ?? "";
  }

  String balance() {
    String uomName = "";
    final uom = json[cUom];
    if (uom is MemoryItem) {
      uomName = uom.name();
    }
    final balance = json["_balance"];
    if (balance is Map<String, dynamic>) {
      return "${balance[cQty] ?? ""} $uomName";
    }
    return "-";
  }

  save() {
    // TODO?
  }

  Map<String, dynamic> toJson() {
    return processMap(json);
  }

  Map<String, dynamic> processMap(Map<String, dynamic> map) {
    final Map<String, dynamic> data = {};

    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is MemoryItem) {
        final id = value.id;
        // assert(id.isNotEmpty && id != 'new');
        if (id.isNotEmpty && id != 'new') {
          data[key] = id;
        }
      } else if (value is Map<String, dynamic>) {
        data[key] = processMap(value);
      } else {
        data[key] = value;
      }
    }

    return data;
  }

  Future<MemoryItem> enrich(List<Field> schema) async {
    if (schema.isEmpty) return this;

    // TODO make configurable?

    final cache = Cache();

    final Map<String, dynamic> copy = Map.from(json);
    for (final field in schema) {
      if (field.type is CalculatedType) {
        final name = field.name;
        final type = field.type as CalculatedType;

        if (copy[name] == null) {
          copy[name] = await type.eval(MemoryItem(id: id, json: copy));
        }
      } else if (field.type is QtyType) {
        final name = field.name;
        // final type = field.type as QtyType;

        final qty = field.resolve(copy);
        if (qty != null) {
          copy[name] = await qty.enrich(cache);
        }
      } else if (field.type is ReferenceType) {
        final type = field.type as ReferenceType;

        final dynamic value = field.resolve(copy); // copy[name]
        if (value is Map) {
          if (value is Map<String, dynamic> && value[cId] != null) {
            field.update(copy, MemoryItem.from(value));
          }
        } else if (value is! MemoryItem) {
          final String id = value ?? '';
          if (id.isNotEmpty) {
            try {
              final cached = cache.get(id);
              if (cached != null) {
                // copy[name] = cached;
                field.update(copy, cached);
              } else {
                final response = await Api.feathers()
                    .get(serviceName: "memories", objectId: id, params: {
                  "oid": Api.instance.oid,
                  "ctx": type.ctx,
                });

                var item = MemoryItem.from(response);
                cache.add(item);

                item = await item.enrich(type.fields);
                cache.add(item);

                // copy[name] = item;
                field.update(copy, item);
              }
            } catch (e) {
              // copy[name] = MemoryItem(id: id, json: const {});
              field.update(copy, MemoryItem(id: id, json: const {}));
            }
          } else {
            // copy[name] = MemoryItem(id: id, json: const {});
            field.update(copy, MemoryItem(id: id, json: const {}));
          }
        }
      }
    }

    return MemoryItem(
        id: id, json: copy, updatedAt: DateTime.now().millisecondsSinceEpoch);
  }

  static create() => const MemoryItem(id: 'new', json: {});

  static empty() => const MemoryItem(id: 'empty', json: {});

  static MemoryItem from(Map<String, dynamic> json) => MemoryItem(
        id: json[cId] ?? json['id'],
        json: json,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
}

class Holder {
  final Map<String, dynamic> data;
  final Iterable<MapEntry<String, dynamic>> entries;

  Holder(this.data, this.entries);
}
