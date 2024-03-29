import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:nae/api.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/utils/cache.dart';
import 'package:stream_transform/stream_transform.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class MemoryBloc extends Bloc<MemoryEvent, RequestState> {
  MemoryBloc({this.schema, this.reverse = false})
      : super(RequestState(DateTime.now(), null)) {
    // print("init RequestState");
    on<MemorySearch>(_onSearch);
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
    on<MemoryPatch>(_onPatch);
    // on<MemoryPatched>(_onPatched);
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
    //           final id = json[cId];
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
    //           final id = json[cId];
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

  final List<Field>? schema;
  final bool reverse;

  StreamSubscription? streamSubscription;

  @override
  Future<void> close() {
    streamSubscription?.cancel();
    return super.close();
  }

  Future<void> _onFetch(MemoryFetch event, Emitter<RequestState> emit) async {
    // print('_onFetching max: ${state.hasReachedMax}, reset: ${event.reset}');
    final newState = event.reset
        ? RequestState(DateTime.now(), event, query: state.query)
        : state;

    if (newState.hasReachedMax) return;
    try {
      if (newState.status == RequestStatus.initiate) {
        // reset cache
        Cache().clear();
      }

      List<MemoryItem> result = [];

      while (true) {
        final items =
            await _fetch(event, newState.original.length + result.length);
        // print("fetched ${items.length}");
        // for (final item in items) {
        //   print("item: ${item.id}");
        // }

        // enrich
        final s = event.schema ?? schema ?? [];
        if (s.isNotEmpty) {
          for (int i = 0; i < items.length; i++) {
            final item = items[i];
            result.add(await item.enrich(s));
          }
        } else {
          result.addAll(items);
        }

        if (items.isEmpty) {
          break;
        } else if (event.loadAll) {
          continue;
        }
        break;
      }

      emit(result.isEmpty
          ? newState.copyWith(event,
              status: RequestStatus.success, hasReachedMax: true)
          : newState.copyWith(
              event,
              status: RequestStatus.success,
              original: List.of(newState.original)..addAll(result),
              hasReachedMax: false,
            ));
    } catch (e, stacktrace) {
      // print("ERROR _onFetched:");
      // print(e);
      // print(stacktrace);
      emit(newState.copyWith(event, status: RequestStatus.failure));
    }
  }

  Future<List<MemoryItem>> _fetch(MemoryFetch event, int startIndex) async {
    var query = {
      'oid': Api.instance.oid,
      'ctx': event.ctx,
      '\$limit': event.limit ?? 20,
      '\$skip': startIndex,
      'reverse': event.reverse,
    };

    final limit = event.limit;
    if (limit != null) {
      query['\$limit'] = limit;
    }

    final search = event.search;
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    final filter = event.filter;
    if (filter.isNotEmpty) {
      query['filter'] = filter;
    }

    // print("query $query");

    final response =
        await Api.feathers().find(serviceName: event.serviceName, query: query);

    // print('response $response');
    List<MemoryItem> list = [];

    final data = response['data'] as List;
    for (var json in data) {
      // print('json $json');
      list.add(MemoryItem.from(json));
    }
    // print('list ${list.length}');
    return list;
  }

  Future<void> _onSearch(MemorySearch event, Emitter<RequestState> emit) async {
    // workaround
    // print("_onSearch: ${event.query}");
    var original = state.original;

    final originalQuery = (event.query ?? '').trim();
    final query = originalQuery.toLowerCase();
    if (query.isEmpty) {
      return emit(state.copyWith(
        event,
        original: original,
      ));
    } else {
      List<MemoryItem> filtered = [];
      for (MemoryItem item in original) {
        // workaround to cover only one use case
        final goods = item.json[cGoods];

        if (goods != null && goods is MemoryItem) {
          if (goods.name().toLowerCase().contains(query)) {
            filtered.add(item);
          }
        }
      }

      return emit(state.copyWith(
        event,
        original: original,
        filtered: filtered,
        query: originalQuery,
      ));
    }
  }

  Future<void> _onSave(MemorySave event, Emitter<RequestState> emit) async {
    // print("_onSave: ${event.data.id}");
    // print(event.data.json);
    if (event.data.isNew) {
      return _onCreate(
          MemoryCreate(
              event.serviceName, event.ctx, event.schema, event.data.toJson()),
          emit);
    } else {
      return _onPatch(
        MemoryPatch(event.serviceName, event.ctx, event.schema, event.data.id,
            event.data.toJson()),
        emit,
      );
      // return _onUpdate(MemoryUpdate(event.serviceName, event.ctx, event.schema, event.data.toJson()), emit);
    }
  }

  Future<void> _onCreate(MemoryCreate event, Emitter<RequestState> emit) async {
    try {
      var saved = await _create(event.serviceName, event.ctx, event.data);
      saved = await saved.enrich(event.schema); // ?? schema ?? []);
      // print("schema $schema");
      // print("_onCreate saved $saved");

      final List<MemoryItem> list = List.from(state.original);

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
        if (reverse) {
          list.add(saved);
        } else {
          list.insert(0, saved);
        }
      }

      return emit(state.copyWith(
        event,
        original: list,
        saved: saved,
        // saveStatus: SaveStatus.success,
      ));
    } catch (e, stacktrace) {
      // print("ERROR _onCreate:");
      // print(e);
      // print(stacktrace);
      // emit(state.copyWith(saveStatus: SaveStatus.failure));
      emit(state.copyWith(event,
          saved: MemoryItem(id: "error", json: {cName: e})));
    }
  }

  Future<MemoryItem> _create(
      String serviceName, List<String> ctx, Map<String, dynamic> data) async {
    var params = {
      "oid": Api.instance.oid,
      "ctx": ctx,
    };
    final response = await Api.feathers()
        .create(serviceName: serviceName, data: data, params: params);
    // print("update response:");
    // print(response);

    final item = MemoryItem.from(response);

    // enrich
    final s = schema ?? [];
    if (s.isNotEmpty) {
      return await item.enrich(s);
    }
    return item;
  }

  Future<void> _onUpdate(MemoryUpdate event, Emitter<RequestState> emit) async {
    try {
      var saved = await _update(event.serviceName, event.ctx, event.data);
      saved = await saved.enrich(event.schema); // ?? schema ?? []);
      // print("saved $saved");

      final List<MemoryItem> list = List.from(state.original);

      // workaround: update list after save
      for (int i = 0; i < list.length; i++) {
        final item = list[i];
        if (item.id == saved.id) {
          // workaround for internally calculated data
          final before = list[i];
          for (final pair in before.json.entries) {
            if (pair.key.startsWith("_")) {
              saved.json[pair.key] = pair.value;
            }
          }

          list[i] = saved;
        }
      }

      return emit(state.copyWith(
        event,
        original: list,
        saved: saved,
      ));
    } catch (e, stacktrace) {
      // print("ERROR _onUpdate:");
      // print(e);
      // print(stacktrace);
      // emit(state.copyWith(saveStatus: SaveStatus.failure));
      emit(state.copyWith(event,
          saved: MemoryItem(id: "error", json: {cName: e})));
    }
  }

  Future<MemoryItem> _update(
      String serviceName, List<String> ctx, Map<String, dynamic> data) async {
    var params = {
      "oid": Api.instance.oid,
      "ctx": ctx,
    };
    final id = data[cId] as String;
    final response = await Api.feathers().update(
        serviceName: serviceName, objectId: id, data: data, params: params);
    // print("update response:");
    // print(response);

    final item = MemoryItem.from(response);

    // enrich
    final s = schema ?? [];
    if (s.isNotEmpty) {
      return await item.enrich(s);
    }
    return item;
  }

  Future<void> _onPatch(MemoryPatch event, Emitter<RequestState> emit) async {
    try {
      var saved =
          await _patch(event.serviceName, event.ctx, event.id, event.data);
      saved = await saved.enrich(event.schema); // ?? schema ?? []);
      // print("_onPatch saved ${saved.json}");

      final List<MemoryItem> list = List.from(state.original);

      // workaround: update list after save
      for (int i = 0; i < list.length; i++) {
        final item = list[i];
        if (item.id == saved.id) {
          // workaround for internally calculated data
          final before = list[i];
          for (final pair in before.json.entries) {
            // TODO: refactor this workaround
            if (pair.key.startsWith("_") && pair.key != cStatus) {
              saved.json[pair.key] = pair.value;
            }
          }

          list[i] = saved;
        }
      }

      return emit(state.copyWith(
        event,
        original: list,
        saved: saved,
      ));
    } catch (e, stacktrace) {
      // print("ERROR _onPatch:");
      // print(e);
      // print(stacktrace);
      // emit(state.copyWith(
      //   saved: MemoryItem(id: event.id, json: event.data),
      //   saveStatus: SaveStatus.failure,
      // ));
      emit(state.copyWith(event,
          saved: MemoryItem(id: "error", json: {cName: e})));
    }
  }

  Future<MemoryItem> _patch(String serviceName, List<String> ctx, String id,
      Map<String, dynamic> data) async {
    var params = {
      "oid": Api.instance.oid,
      "ctx": ctx,
    };
    // print("patch request:");
    // print(data);
    final response = await Api.feathers().patch(
        serviceName: serviceName, objectId: id, data: data, params: params);
    // print("patch response:");
    // print(response);

    final item = MemoryItem.from(response);

    // enrich
    final s = schema ?? [];
    if (s.isNotEmpty) {
      return await item.enrich(s);
    }
    return item;
  }

  Future<void> _onCreated(
      MemoryCreated event, Emitter<RequestState> emit) async {
    // print("_onCreated");
    // print(event.item.json);

    // workaround: search for item to avoid duplicate
    for (var item in state.original) {
      if (item.id == event.item.id) {
        // print("found");
        return emit(state); // TODO is it possible to emit nothing?
      }
    }

    // print("adding");
    final List<MemoryItem> list = List.from(state.original);
    list.insert(0, event.item);
    return emit(state.copyWith(
      event,
      original: list,
    ));
  }

  Future<void> _onUpdated(
      MemoryUpdated event, Emitter<RequestState> emit) async {
    // print("_onUpdated");
    // print(event.item.json);

    var items = state.original;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.id == event.item.id) {
        // print("found and replace");
        items[i] = event.item;
      }
    }

    return emit(state.copyWith(
      event,
      original: items,
    ));
  }
}
