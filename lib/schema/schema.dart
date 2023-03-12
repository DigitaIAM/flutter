import 'package:nae/models/memory/item.dart';

class Field {
  final String name;
  final List<String>? path;

  final Type type;
  final double width;

  const Field(this.name, this.type, {this.path, this.width = 1.0});

  dynamic resolve(Map<String, dynamic> json) {
    // print("resolve: ");
    // print(path);
    // print(json);
    if (path != null) {
      dynamic value = json;

      for (final name in path!) {
        if (value == null) {
          return null;
        }
        value = value[name];
      }

      return value;
    }
    return json[name];
  }

  void update(Map<String, dynamic> json, MemoryItem value) {
    if (path != null) {
      var v = json;

      final steps = path!;
      final last = steps.length - 1;

      // print("----");
      for (final name in steps.sublist(0, last)) {
        // print(name);
        v = v[name];
      }

      // print("====");
      // print(_path[_last]);

      v[steps[last]] = value;
    } else {
      json[name] = value;
    }
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
