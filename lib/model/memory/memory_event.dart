import 'package:equatable/equatable.dart';
import 'package:nae_hr/model/memory/item.dart';

abstract class MemoryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class MemoryFetch extends MemoryEvent {
  MemoryFetch(this.serviceName, this.ctx);

  final String serviceName;
  final List<String> ctx;
}

class MemoryRequest extends MemoryEvent {
  MemoryRequest(this.serviceName, this.ctx, this.id);

  final String serviceName;
  final List<String> ctx;
  final String id;
}

class MemorySave extends MemoryEvent {
  MemorySave(this.serviceName, this.ctx, this.data);

  final String serviceName;
  final List<String> ctx;
  final MemoryItem data;
}

class MemoryCreate extends MemoryEvent {
  MemoryCreate(this.serviceName, this.ctx, this.data);

  final String serviceName;
  final List<String> ctx;
  final Map<String, dynamic> data;
}

class MemoryCreated extends MemoryEvent {
  MemoryCreated(this.item);

  final MemoryItem item;
}

class MemoryUpdate extends MemoryEvent {
  MemoryUpdate(this.serviceName, this.ctx, this.data);

  final String serviceName;
  final List<String> ctx;
  final Map<String, dynamic> data;
}

class MemoryUpdated extends MemoryEvent {
  MemoryUpdated(this.item);

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