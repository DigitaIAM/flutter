import 'package:equatable/equatable.dart';
import 'package:nae/models/memory/item.dart';

enum RequestStatus { loading, success, failure }

enum SaveStatus { ready, saving, success, failure }

class RequestState extends Equatable {
  RequestState({
    this.status = RequestStatus.loading,
    this.items = const <MemoryItem>[],
    this.hasReachedMax = false,
    this.saveStatus = SaveStatus.ready,
    DateTime? ts,
  }) : updated = ts ?? DateTime.now();

  RequestState.loading() : this();

  RequestState.success(List<MemoryItem> items) : this(status: RequestStatus.success, items: items);

  RequestState.failure() : this(status: RequestStatus.failure);

  final DateTime updated;

  final RequestStatus status;
  final List<MemoryItem> items;
  final bool hasReachedMax;

  final SaveStatus saveStatus;

  RequestState copyWith({
    RequestStatus? status,
    List<MemoryItem>? items,
    bool? hasReachedMax,
    SaveStatus? saveStatus,
  }) {
    return RequestState(
        status: status ?? this.status,
        items: items ?? this.items,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        saveStatus: saveStatus ?? this.saveStatus);
  }

  @override
  List<Object> get props => [status, items, hasReachedMax];
}
