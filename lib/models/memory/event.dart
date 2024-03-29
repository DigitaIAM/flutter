import 'package:equatable/equatable.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/schema/schema.dart';

abstract class MemoryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class MemoryFetch extends MemoryEvent {
  MemoryFetch(
    this.serviceName,
    this.ctx, {
    this.schema,
    this.limit,
    this.search,
    this.filter = const {},
    this.loadAll = false,
    this.reverse = false,
    this.reset = false,
  });

  final String serviceName;
  final List<String> ctx;
  final List<Field>? schema;
  final int? limit;
  final String? search;
  final Map<String, dynamic> filter;
  final bool reverse;
  final bool loadAll;
  final bool reset;
}

class MemoryRequest extends MemoryEvent {
  MemoryRequest(this.serviceName, this.ctx, this.id);

  final String serviceName;
  final List<String> ctx;
  final String id;
}

class MemorySave extends MemoryEvent {
  MemorySave(this.serviceName, this.ctx, this.schema, this.data);

  final String serviceName;
  final List<String> ctx;
  final List<Field> schema;
  final MemoryItem data;
}

class MemoryCreate extends MemoryEvent {
  MemoryCreate(this.serviceName, this.ctx, this.schema, this.data);

  final String serviceName;
  final List<String> ctx;
  final List<Field> schema;
  final Map<String, dynamic> data;
}

class MemoryCreated extends MemoryEvent {
  MemoryCreated(this.item);

  final MemoryItem item;
}

class MemoryUpdate extends MemoryEvent {
  MemoryUpdate(this.serviceName, this.ctx, this.schema, this.data);

  final String serviceName;
  final List<String> ctx;
  final List<Field> schema;
  final Map<String, dynamic> data;
}

class MemoryUpdated extends MemoryEvent {
  MemoryUpdated(this.item);

  final MemoryItem item;
}

class MemoryPatch extends MemoryEvent {
  MemoryPatch(this.serviceName, this.ctx, this.schema, this.id, this.data);

  final String serviceName;
  final List<String> ctx;
  final List<Field> schema;
  final String id;
  final Map<String, dynamic> data;
}

class MemoryPatched extends MemoryEvent {
  MemoryPatched(this.item);

  final MemoryItem item;
}

class MemoryRemove extends MemoryEvent {
  MemoryRemove(this.serviceName, this.ctx, this.id);

  final String serviceName;
  final List<String> ctx;
  final String id;
}

class MemoryRemoved extends MemoryEvent {
  MemoryRemoved(this.item);

  final MemoryItem item;
}

class MemorySearch extends MemoryEvent {
  MemorySearch(this.query);

  final String? query;

  @override
  List<Object> get props => [query ?? ''];
}
