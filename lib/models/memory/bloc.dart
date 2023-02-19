import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:nae/api.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/utils/cache.dart';
import 'package:stream_transform/stream_transform.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class MemoryBloc extends Bloc<MemoryEvent, RequestState> {
  MemoryBloc() : super(RequestState()) {
    print("init RequestState");
    on<MemorySave>(_onSave);
    on<MemoryFetch>(
      _onFetch,
      // transformer: throttleDroppable(throttleDuration),
    );
    // TODO on<MemoryRequest>(_onRequest);
    on<MemoryCreate>(_onCreate);
    on<MemoryCreated>(_onCreated);
    on<MemoryUpdate>(_onUpdate);
    on<MemoryUpdated>(_onUpdated);
    // TODO on<MemoryRemove>(_onRemove);

    // Api.feathers().scketio.reset(serviceName: "memories");

    // TODO can not be unregistered and multiple call for same event
    // streamSubscription = Api.feathers()
    //     .listen<Map<String, dynamic>>(serviceName: "memories", fromJson: (e) { return e; } )
    //     .listen((event) {
    //       print("listen event:");
    //       print(event.type);
    //       print(event.data);
    //       // event is FeathersJsEventData<Message>
    //       // What event is sent by feathers js ?
    //       if (event.type == FeathersJsEventType.created && event.data != null) {
    //         if (event.data is Map<String, dynamic>) {
    //           final json = event.data!;
    //           final id = json["_id"];
    //           print("found id:");
    //           print(id);
    //           if (id != null && id is String && id.isNotEmpty) {
    //             final item = MemoryItem(id: id, json: json);
    //             add(MemoryCreated(item));
    //           }
    //         }
    //       } else if (event.type == FeathersJsEventType.updated) {
    //         if (event.data is Map<String, dynamic>) {
    //           final json = event.data!;
    //           final id = json["_id"];
    //           print("found id:");
    //           print(id);
    //           if (id != null && id is String && id.isNotEmpty) {
    //             final item = MemoryItem(id: id, json: json);
    //             add(MemoryUpdated(item));
    //           }
    //         }
    //       }
    //     },
    //     onError: (e) {
    //       print("onError: ");
    //       print(e);
    //       // e is a FeatherJsError
    //       // You can check what error occured: e.type
    //
    //       // Add the event to flutter_bloc
    //       // add(MessageError(message: e.error));
    //     },
    // );
  }

  StreamSubscription? streamSubscription;

  @override
  Future<void> close() {
    streamSubscription?.cancel();
    return super.close();
  }

  Future<void> _onFetch(MemoryFetch event, Emitter<RequestState> emit) async {
    // print('_onFetching ${state.hasReachedMax}');
    if (state.hasReachedMax) return;
    try {
      if (state.status == RequestStatus.loading) {
        // reset cache
        Cache().clear();
      }
      // if (state.status == RequestStatus.loading) {
      //   final items = await _fetch(event.serviceName, event.ctx);
      //   return emit(state.copyWith(
      //     status: RequestStatus.success,
      //     items: items,
      //     hasReachedMax: false,
      //   ));
      // }

      // print('fetching ${state.items.length}');
      final items = await _fetch(event.serviceName, event.ctx, state.items.length, event.filter);
      // print(items.length);

      // enrich
      if (event.schema != null) {
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          items[i] = await item.enrich(event.schema!);
        }
      }

      emit(items.isEmpty
          ? state.copyWith(status: RequestStatus.success, hasReachedMax: true)
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

  Future<List<MemoryItem>> _fetch(
      String serviceName, List<String> ctx, int startIndex, Map<String, String>? filter) async {
    var query = {
      "oid": Api.instance.oid,
      "ctx": ctx,
      "\$skip": startIndex,
    };

    if (filter != null && filter.isNotEmpty) {
      query['filter'] = filter;
    }

    final response = await Api.feathers().find(serviceName: serviceName, query: query);

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

  Future<void> _onSave(MemorySave event, Emitter<RequestState> emit) async {
    print("_onSave: ${event.data.id}");
    print(event.data.json);
    if (event.data.isNew) {
      return _onCreate(MemoryCreate(event.serviceName, event.ctx, event.data.json), emit);
    } else {
      return _onUpdate(MemoryUpdate(event.serviceName, event.ctx, event.data.json), emit);
    }
  }

  Future<void> _onCreate(MemoryCreate event, Emitter<RequestState> emit) async {
    try {
      final saved = await _create(event.serviceName, event.ctx, event.data);

      final List<MemoryItem> list = List.from(state.items);

      // workaround: update list after save
      bool notFound = true;
      for (int i = 0; i < list.length; i++) {
        final item = list[i];
        if (item.id == saved.id) {
          list[i] = saved;
          notFound = false;
        }
      }
      if (notFound) {
        list.insert(0, saved);
      }

      print("state: ");
      print(state);
      print("list: ");
      print(list);

      return emit(state.copyWith(
        items: list,
        saveStatus: SaveStatus.success,
      ));
    } catch (e, stacktrace) {
      print("ERROR _onCreate:");
      print(e);
      print(stacktrace);
      emit(state.copyWith(saveStatus: SaveStatus.failure));
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

  Future<void> _onUpdate(MemoryUpdate event, Emitter<RequestState> emit) async {
    try {
      final saved = await _update(event.serviceName, event.ctx, event.data);

      final List<MemoryItem> list = List.from(state.items);

      // workaround: update list after save
      for (int i = 0; i < list.length; i++) {
        final item = list[i];
        if (item.id == saved.id) {
          list[i] = saved;
        }
      }

      return emit(state.copyWith(
        items: list,
        saveStatus: SaveStatus.success,
      ));
    } catch (e, stacktrace) {
      print("ERROR _onUpdate:");
      print(e);
      print(stacktrace);
      emit(state.copyWith(saveStatus: SaveStatus.failure));
    }
  }

  Future<MemoryItem> _update(String serviceName, List<String> ctx, Map<String, dynamic> data) async {
    var params = {
      "oid": Api.instance.oid,
      "ctx": ctx,
    };
    final id = data["_id"] as String;
    final response = await Api.feathers().update(serviceName: serviceName, objectId: id, data: data, params: params);
    print("update response:");
    print(response);

    return MemoryItem(
      id: response['_id'],
      json: response,
    );
  }

  Future<void> _onPatch(MemoryPatch event, Emitter<RequestState> emit) async {
    try {
      final saved = await _patch(event.serviceName, event.ctx, event.data);

      final List<MemoryItem> list = List.from(state.items);

      // workaround: update list after save
      for (int i = 0; i < list.length; i++) {
        final item = list[i];
        if (item.id == saved.id) {
          list[i] = saved; // TODO patch it
        }
      }

      return emit(state.copyWith(
        items: list,
        saveStatus: SaveStatus.success,
      ));
    } catch (e, stacktrace) {
      print("ERROR _onPatch:");
      print(e);
      print(stacktrace);
      emit(state.copyWith(saveStatus: SaveStatus.failure));
    }
  }

  Future<MemoryItem> _patch(String serviceName, List<String> ctx, Map<String, dynamic> data) async {
    var params = {
      "oid": Api.instance.oid,
      "ctx": ctx,
    };
    final id = data["_id"] as String;
    final response = await Api.feathers().patch(serviceName: serviceName, objectId: id, data: data, params: params);
    print("patch response:");
    print(response);

    return MemoryItem(
      id: response['_id'],
      json: response,
    );
  }

  Future<void> _onCreated(MemoryCreated event, Emitter<RequestState> emit) async {
    print("_onCreated");
    print(event.item.json);

    // workaround: search for item to avoid duplicate
    for (var item in state.items) {
      if (item.id == event.item.id) {
        print("found");
        return emit(state); // TODO is it possible to emit nothing?
      }
    }

    print("adding");
    final List<MemoryItem> list = List.from(state.items);
    list.insert(0, event.item);
    return emit(state.copyWith(
      items: list,
    ));
  }

  Future<void> _onUpdated(MemoryUpdated event, Emitter<RequestState> emit) async {
    print("_onUpdated");
    print(event.item.json);

    var items = state.items;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.id == event.item.id) {
        print("found and replace");
        items[i] = event.item;
      }
    }

    return emit(state.copyWith(
      items: items,
    ));
  }
}
