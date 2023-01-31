import 'package:equatable/equatable.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:nae_hr/model/memory/item.dart';

part 'ui_state.g.dart';

// subRoute: [view, edit]

@CopyWith()
class UiState extends Equatable {
  const UiState({
    this.currentRoute = const ["login"],
    this.subRoute,
    this.entity = const MemoryItem(id: '', json: {}),
    this.entityId,

    this.isMenuVisible = true,
    this.isMenuCollapsed = false,
  });

  final List<String> currentRoute;
  final String? subRoute;
  final MemoryItem entity;
  final String? entityId;

  final bool isMenuVisible;
  final bool isMenuCollapsed;

  bool get showMenu => isMenuVisible;

  @override
  List<Object> get props => [currentRoute, subRoute ?? '', entity, entityId ?? '', isMenuVisible, isMenuCollapsed];
}
