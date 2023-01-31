import 'package:equatable/equatable.dart';
import 'package:nae_hr/model/memory/item.dart';

import '../../memory.dart';

abstract class UiEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ChangeView extends UiEvent {
  ChangeView(this.ctx, {this.entity = const MemoryItem(id: '', json: {})});

  final List<String> ctx;
  final MemoryItem entity;

  @override
  List<Object> get props => [ctx, entity];
}

class MenuVisibility extends UiEvent {
  MenuVisibility({this.visible = true, this.collapsed = false});

  final bool visible;
  final bool collapsed;

  @override
  List<Object> get props => [visible, collapsed];
}