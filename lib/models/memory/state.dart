import 'package:equatable/equatable.dart';
import 'package:nae/models/memory/item.dart';

enum RequestStatus { initiate, success, failure }

enum SaveStatus { ready, saving, success, failure }

class RequestState extends Equatable {
  RequestState(
    this.created, {
    this.status = RequestStatus.initiate,
    this.original = const <MemoryItem>[],
    this.filtered = const <MemoryItem>[],
    this.query,
    this.hasReachedMax = false,
    this.saved,
    this.saveStatus = SaveStatus.ready,
    DateTime? ts,
  }) : updated = ts ?? DateTime.now();

  // RequestState.loading() : this(DateTime.now());
  // RequestState.success(List<MemoryItem> items) : this(DateTime.now(), status: RequestStatus.success, original: items);
  // RequestState.failure() : this(DateTime.now(), status: RequestStatus.failure);

  final DateTime created;
  final DateTime updated;

  final RequestStatus status;

  final List<MemoryItem> original;
  final List<MemoryItem> filtered;
  final String? query;

  final bool hasReachedMax;

  final MemoryItem? saved;
  final SaveStatus saveStatus;

  List<MemoryItem> get items => (query == null || query!.trim().isEmpty) ? original : filtered;

  RequestState copyWith({
    RequestStatus? status,
    List<MemoryItem>? original,
    List<MemoryItem>? filtered,
    String? query,
    bool? hasReachedMax,
    MemoryItem? saved,
    SaveStatus? saveStatus,
  }) {
    return RequestState(
      created,
      status: status ?? this.status,
      original: original ?? this.original,
      filtered: filtered ?? original ?? this.original,
      query: query,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      saved: saved ?? this.saved,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }

  @override
  List<Object> get props => [status, original, hasReachedMax];
}
