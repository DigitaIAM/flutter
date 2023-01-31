import 'package:equatable/equatable.dart';
import 'package:nae_hr/model/memory/item.dart';

import '../../memory.dart';

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

class MemoryCreate extends MemoryEvent {
  MemoryCreate(this.serviceName, this.ctx, this.data);

  final String serviceName;
  final List<String> ctx;
  final Map<String, dynamic> data;
}

class MemoryCreated extends MemoryEvent {
  MemoryCreated(this.serviceName, this.ctx, this.item);

  final String serviceName;
  final List<String> ctx;
  final MemoryItem item;
}

class MemoryUpdate extends MemoryEvent {
  MemoryUpdate(this.serviceName, this.ctx, this.data);

  final String serviceName;
  final List<String> ctx;
  final Map<String, dynamic> data;
}

class MemoryRemove extends MemoryEvent {
  MemoryRemove(this.serviceName, this.ctx, this.id);

  final String serviceName;
  final List<String> ctx;
  final String id;
}