import 'package:equatable/equatable.dart';

abstract class MasterDetailEvent extends Equatable {
  const MasterDetailEvent();
}

class LoadItemsEvent extends MasterDetailEvent {
  @override
  List<Object> get props => [];
}

class AddItemEvent extends MasterDetailEvent {
  final dynamic element;

  AddItemEvent(this.element);

  @override
  List<Object> get props => [element];
}

class SelectItemEvent extends MasterDetailEvent {
  final dynamic selected;

  SelectItemEvent(this.selected);

  @override
  List<Object> get props => [selected];
}