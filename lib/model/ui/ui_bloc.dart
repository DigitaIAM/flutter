import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:nae_hr/model/ui/ui_event.dart';
import 'package:nae_hr/model/ui/ui_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class UiBloc extends Bloc<UiEvent, UiState> {
  UiBloc() : super(const UiState()) {
    on<ChangeView>(
      (ChangeView event, Emitter<UiState> emit) {
        emit(state.copyWith(
          currentRoute: event.ctx.isNotEmpty ? event.ctx : state.currentRoute,
          action: event.action,
          entity: event.entity,
        ));
      },
      transformer: throttleDroppable(throttleDuration),
    );

    on<MenuVisibility>(
      (MenuVisibility event, Emitter<UiState> emit) {
        emit(state.copyWith(
          isMenuVisible: event.visible,
          isMenuCollapsed: event.collapsed,
        ));
      },
      transformer: throttleDroppable(throttleDuration),
    );
  }
}