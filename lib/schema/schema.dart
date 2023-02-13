import 'package:nae/models/memory/item.dart';

class Field {
  final String name;
  final Type type;

  const Field(this.name, this.type);
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

  const ReferenceType(this.ctx);
}

class CalculatedType extends Type {
  CalculatedType(this.eval);

  final Future<String> Function(MemoryItem) eval;
}
