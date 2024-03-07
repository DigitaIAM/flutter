import 'package:equatable/equatable.dart';
import 'package:nae/models/memory/item.dart';

import 'event.dart';

enum RequestStatus { initiate, success, failure }

class RequestState extends Equatable {
  RequestState(
    this.created,
    this.event, {
    this.status = RequestStatus.initiate,
    this.original = const <MemoryItem>[],
    this.filtered = const <MemoryItem>[],
    this.query,
    this.hasReachedMax = false,
    this.saved,
    DateTime? ts,
  }) : updated = ts ?? DateTime.now();

  // RequestState.loading() : this(DateTime.now());
  // RequestState.success(List<MemoryItem> items) : this(DateTime.now(), status: RequestStatus.success, original: items);
  // RequestState.failure() : this(DateTime.now(), status: RequestStatus.failure);

  final DateTime created;
  final DateTime updated;

  final MemoryEvent? event;

  final RequestStatus status;

  final List<MemoryItem> original;
  final List<MemoryItem> filtered;
  final String? query;

  final bool hasReachedMax;

  final MemoryItem? saved;

  List<MemoryItem> get items =>
      (query == null || query!.trim().isEmpty) ? original : filtered;

  bool isUpdated(MemoryItem entity) {
    return saved != null && saved!.updatedAt > entity.updatedAt;
  }

  RequestState copyWith(
    MemoryEvent event, {
    RequestStatus? status,
    List<MemoryItem>? original,
    List<MemoryItem>? filtered,
    String? query,
    bool? hasReachedMax,
    MemoryItem? saved,
  }) {
    return RequestState(
      created,
      event,
      status: status ?? this.status,
      original: original ?? this.original,
      filtered: filtered ?? original ?? this.original,
      query: query,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      saved: saved,
    );
  }

  @override
  List<Object> get props => [status, original, hasReachedMax];
}
