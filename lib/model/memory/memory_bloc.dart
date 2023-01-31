import 'dart:async';
import 'package:flutter_feathersjs/src/config/helper.dart';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:nae_hr/api.dart';
import 'package:nae_hr/model/memory/item.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:nae_hr/memory.dart';
import 'package:nae_hr/model/memory/memory_event.dart';
import 'package:nae_hr/model/memory/memory_state.dart';


// const _postLimit = 20;
const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class MemoryBloc extends Bloc<MemoryEvent, RequestState> {
  MemoryBloc() : super(const RequestState()) {
    print("init RequestState");
    on<MemoryFetch>(
      _onFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    // TODO on<MemoryRequest>(_onRequest);
    on<MemoryCreate>(_onCreate);
    on<MemoryCreated>(_onCreated);
    on<MemoryUpdate>(_onUpdate);
    // TODO on<MemoryRemove>(_onRemove);

    streamSubscription = Api.feathers()
        .listen<Map<String, dynamic>>(serviceName: "memories", fromJson: (e) { return e; } )
        .listen((event) {
          print("listen event:");
          print(event.type);
          print(event.data);
          // event is FeathersJsEventData<Message>
          // What event is sent by feathers js ?
          if (event.type == FeathersJsEventType.created && event.data != null) {
            if (event.data is Map<String, dynamic>) {
              final json = event.data!;
              final id = json["_id"];
              print(id);
              if (id != null && id is String && id.isNotEmpty) {
                final item = MemoryItem(id: id, json: json);
                add(MemoryCreated("memories", const ["TODO"], item));
              }
            }
          // } else if (event.type == FeathersJsEventType.removed) {
          //   //
          // } else if (event.type == FeathersJsEventType.patched){
          //   // ...
          }
        },
        onError: (e) {
          print("onError: ");
          print(e);
          // e is a FeatherJsError
          // You can check what error occured: e.type

          // Add the event to flutter_bloc
          // add(MessageError(message: e.error));
        },
    );
  }

  StreamSubscription? streamSubscription;

  @override
  Future<void> close() {
    print("onClose: ");
    print(streamSubscription);
    streamSubscription?.cancel();
    return super.close();
  }

  Future<void> _onFetched(MemoryFetch event, Emitter<RequestState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == RequestStatus.loading) {
        final items = await _fetch(event.serviceName, event.ctx);
        return emit(state.copyWith(
          status: RequestStatus.success,
          items: items,
          hasReachedMax: false,
        ));
      }
      final items = await _fetch(event.serviceName, event.ctx, state.items.length);
      emit(items.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
        status: RequestStatus.success,
        items: List.of(state.items)..addAll(items),
        hasReachedMax: false,
      ));
    } catch (e, stacktrace) {
      print("ERROR _onFetched:");
      print(e);
      print(stacktrace);
      emit(state.copyWith(status: RequestStatus.failure));
    }
  }

  Future<List<MemoryItem>> _fetch(String serviceName, List<String> ctx, [int startIndex = 0]) async {
    print("fetching");
    print(Api.instance.oid);
    var query = {
      "oid": Api.instance.oid,
      "ctx": ctx,
      "\$skip": '$startIndex',
      // '$_postLimit'
    };
    final response = await Api.feathers().find(serviceName: serviceName, query: query);
    print("response:");
    print(response);

    List<MemoryItem> list = [];

    final data = response['data'] as List;
    for (var json in data) {
      final item = MemoryItem(
        id: json['_id'],
        json: json,
      );
      list.add(item);
    }
    return list;

    // return data.map((json) {
    //   return MemoryItem(
    //     id: json['_id'],
    //     json: json,
    //   );
    // }).toList();


    // if (response.statusCode == 200) {
    //   ..
    // }
    // throw Exception('error fetching');
  }

  Future<void> _onCreate(MemoryCreate event, Emitter<RequestState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == RequestStatus.loading) {
        final item = await _create(event.serviceName, event.ctx, event.data);
        return emit(state.copyWith(
          status: RequestStatus.success,
          items: [item],
          hasReachedMax: true,
        ));
      }
    } catch (e, stacktrace) {
      print("ERROR _onCreate:");
      print(e);
      print(stacktrace);
      emit(state.copyWith(status: RequestStatus.failure));
    }
  }

  Future<MemoryItem> _create(String serviceName, List<String> ctx, Map<String, dynamic> data) async {
    var params = {
      "oid": Api.instance.oid,
      "ctx": ctx,
    };
    final response = await Api.feathers().create(serviceName: serviceName, data: data, params: params);
    print("update response:");
    print(response);

    return MemoryItem(
      id: response['_id'],
      json: response,
    );
  }

  Future<void> _onCreated(MemoryCreated event, Emitter<RequestState> emit) async {
    // workaround: search for item to avoid duplicate
    for (var item in state.items) {
      if (item.id == event.item.id) {
        return emit(state); // TODO is it possible to emit nothing?
      }
    }
    final List<MemoryItem> list = List.from(state.items);
    list.insert(0, event.item);
    return emit(state.copyWith(
      items: list,
    ));
  }

  Future<void> _onUpdate(MemoryUpdate event, Emitter<RequestState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == RequestStatus.loading) {
        final item = await _update(event.serviceName, event.ctx, event.data);
        return emit(state.copyWith(
          status: RequestStatus.success,
          items: [item],
          hasReachedMax: true,
        ));
      }
    } catch (e, stacktrace) {
      print("ERROR _onUpdate:");
      print(e);
      print(stacktrace);
      emit(state.copyWith(status: RequestStatus.failure));
    }
  }

  Future<MemoryItem> _update(String serviceName, List<String> ctx, Map<String, dynamic> data) async {
    var params = {
      "oid": Api.instance.oid,
      "ctx": ctx,
    };
    final id = data["_id"] as String;
    final response = await Api.feathers().update(
        serviceName: serviceName, objectId: id, data: data, params: params
    );
    print("update response:");
    print(response);

    return MemoryItem(
      id: response['_id'],
      json: response,
    );
  }
}