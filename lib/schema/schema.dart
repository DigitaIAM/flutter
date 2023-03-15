import 'package:nae/models/memory/item.dart';

class Field {
  final String name;
  final List<String>? path;

  final Type type;
  final double width;

  const Field(this.name, this.type, {this.path, this.width = 1.0});

  Field copyWith({
    double? width,
  }) {
    return Field(name, type, path: path, width: width ?? this.width);
  }

  dynamic resolve(Map<String, dynamic> json) {
//     print("resolve: ");
//     print('$path $name');
//     print(json);
    if (path != null) {
      dynamic value = json;

      for (final name in path!) {
        if (value == null) {
          return null;
        } else if (value is MemoryItem) {
          value = value.json[name];
        } else {
          value = value[name];
        }
      }

      return value;
    }
    return json[name];
  }

  void update(Map<String, dynamic> json, MemoryItem value) {
    if (path != null) {
//      print('update: $path $json $value');
      _update(path!, json, value);
    } else {
      json[name] = value;
    }
  }

  void _update(List<String> steps, Map<String, dynamic> json, MemoryItem value) {
    var v = json;

    final last = steps.length - 1;

//    print("----");
    for (var i = 0; i < last; i++) {
      var name = steps[i];

//      print('$name = $v');

      final next = v[name];

      if (next is MemoryItem) {
        final Map<String, dynamic> copy = Map.from(next.json);
        _update(steps.sublist(i+1), copy, value);

        v[name] = MemoryItem(id: next.id, json: copy);
      } else {
        v = next;
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
