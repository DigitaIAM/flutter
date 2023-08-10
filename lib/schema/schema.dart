import 'package:nae/models/memory/item.dart';

class Field {
  final String name;
  final List<String>? path;

  final Type type;
  final double width;

  final bool editable;

  const Field(this.name, this.type, {this.path, this.width = 1.0, this.editable = true});

  Field copyWith({
    double? width,
    bool? editable,
  }) {
    return Field(name, type, path: path, width: width ?? this.width, editable: editable ?? this.editable);
  }

  dynamic resolve(Map<String, dynamic> json) {
    // print("resolve: ");
    // print('$path $name');
    // print(json);
    dynamic value;
    dynamic result;
    if (path != null) {
      value = json;

      for (final name in path!) {
        if (value == null) {
          return null;
        } else if (value is MemoryItem) {
          value = value.json[name];
        } else if (value is Map) {
          value = value[name];
        } else {
          return null; // TODO error?
        }
      }
      result = enrich(value);
    } else {
      value = json[name];
      result = enrich(value);
    }

    if (value != result) {
      update(json, result);
    }

    return result;
  }

  dynamic enrich(dynamic v) {
    if (type is ReferenceType) {
      if (v is MemoryItem) {
        return v;
      } else if (v is Map<String, dynamic>) {
        return MemoryItem.from(v);
      } else if (v is String) {
        return v;
      } else {
        if (v != null) {
          // print("enrich ? $v");
        }
        return v; // TODO raise error?
      }
    } else {
      return v;
    }
  }

  void update(Map<String, dynamic> json, dynamic value) {
    if (path != null) {
//      print('update: $path $json $value');
      _update(path!, json, value);
    } else {
//      print("json[name] = value");
      json[name] = value;
    }
  }

  void _update(List<String> steps, Map<String, dynamic> json, dynamic value) {
    var v = json;

    final last = steps.length - 1;

//    print("----");
    for (var i = 0; i < last; i++) {
      var name = steps[i];

//      print('$name = $v');

      final next = v[name];

//      print('$next');

      if (next is MemoryItem) {
        final Map<String, dynamic> copy = Map.from(next.json);
        _update(steps.sublist(i + 1), copy, value);

        v[name] = MemoryItem(id: next.id, json: copy);
      } else if (next is Map<String, dynamic>) {
        v = next;
      } else if (next == null) {
        final Map<String, dynamic> copy = {};
        v[name] = copy;
        v = copy;
      } else {
        // TODO problem in case next is not null
        // throw const FormatException();
        return;
      }
    }

//    print("==== ${steps[last]}");

    v[steps[last]] = value;
  }
}

abstract class Type {
  const Type();
}

class StringType extends Type {
  const StringType();
}

class NumberType extends Type {
  const NumberType();
}

class DateType extends Type {
  const DateType();
}

class ReferenceType extends Type {
  final List<String> ctx;
  final List<Field> fields;

  const ReferenceType(this.ctx, {this.fields = const []});
}

class ListType extends Type {
  final List<Field> fields;

  const ListType(this.fields);
}

class CalculatedType extends Type {
  CalculatedType(this.eval);

  final Future<String> Function(MemoryItem) eval;
}

class PopupMenuButtonType extends Type {
  const PopupMenuButtonType();
}
