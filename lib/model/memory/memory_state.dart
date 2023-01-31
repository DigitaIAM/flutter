import 'package:equatable/equatable.dart';
import 'package:nae_hr/model/memory/item.dart';

enum RequestStatus { loading, success, failure }

class RequestState extends Equatable {
  const RequestState({
    this.status = RequestStatus.loading,
    this.items = const <MemoryItem>[],
    this.hasReachedMax = false,
  });

  const RequestState.loading() : this();

  const RequestState.success(List<MemoryItem> items)
      : this(status: RequestStatus.success, items: items);

  const RequestState.failure() : this(status: RequestStatus.failure);

  final RequestStatus status;
  final List<MemoryItem> items;
  final bool hasReachedMax;

  RequestState copyWith({
    RequestStatus? status,
    List<MemoryItem>? items,
    bool? hasReachedMax,
  }) {
    return RequestState(
      status: status ?? this.status,
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [status, items, hasReachedMax];
}
