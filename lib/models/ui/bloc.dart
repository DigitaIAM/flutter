import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:nae/core/platform.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/models/ui/state.dart';
import 'package:stream_transform/stream_transform.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class UiBloc extends Bloc<UiEvent, UiState> {
  factory UiBloc.create() {
    return UiBloc(UiState(
      isDesktop: isDesktopOS() || isWeb(),
      mediaQueryData: MediaQueryData.fromView(WidgetsBinding.instance.window),
    ));
  }

  UiBloc(UiState state) : super(state) {
    on<ChangeView>(
      (ChangeView event, Emitter<UiState> emit) {
        // print("on ChangeView $event");
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
