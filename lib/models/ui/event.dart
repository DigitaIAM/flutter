import 'package:equatable/equatable.dart';
import 'package:nae/models/memory/item.dart';

abstract class UiEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ChangeView extends UiEvent {
  ChangeView(
    this.ctx, {
    this.action = 'view',
    this.entity = const MemoryItem(id: '', json: {}, updatedAt: 0),
  });

  final List<String> ctx;
  final String action;
  final MemoryItem entity;

  @override
  List<Object> get props => [ctx, action, entity];
}

class PreviousRoute extends UiEvent {}

class MenuVisibility extends UiEvent {
  MenuVisibility({this.visible = true, this.collapsed = false});

  final bool visible;
  final bool collapsed;

  @override
  List<Object> get props => [visible, collapsed];
}
