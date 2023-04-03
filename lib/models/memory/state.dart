import 'package:equatable/equatable.dart';
import 'package:nae/models/memory/item.dart';

enum RequestStatus { loading, success, failure }

enum SaveStatus { ready, saving, success, failure }

class RequestState extends Equatable {
  RequestState({
    this.status = RequestStatus.loading,
    this.original = const <MemoryItem>[],
    this.filtered = const <MemoryItem>[],
    this.query,
    this.hasReachedMax = false,
    this.saveStatus = SaveStatus.ready,
    DateTime? ts,
  }) : updated = ts ?? DateTime.now();

  RequestState.loading() : this();

  RequestState.success(List<MemoryItem> items) : this(status: RequestStatus.success, original: items);

  RequestState.failure() : this(status: RequestStatus.failure);

  final DateTime updated;

  final RequestStatus status;

  final List<MemoryItem> original;
  final List<MemoryItem> filtered;
  final String? query;

  final bool hasReachedMax;

  final SaveStatus saveStatus;

  List<MemoryItem> get items => (query == null || query!.trim().isEmpty) ? original : filtered;

  RequestState copyWith({
    RequestStatus? status,
    List<MemoryItem>? original,
    List<MemoryItem>? filtered,
    String? query,
    bool? hasReachedMax,
    SaveStatus? saveStatus,
  }) {
    return RequestState(
        status: status ?? this.status,
        original: original ?? this.original,
        filtered: filtered ?? original ?? this.original,
        query: query,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        saveStatus: saveStatus ?? this.saveStatus);
  }

  @override
  List<Object> get props => [status, original, hasReachedMax];
}
