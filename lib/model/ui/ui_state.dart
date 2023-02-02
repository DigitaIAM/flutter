import 'package:equatable/equatable.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';

import 'package:nae_hr/model/memory/item.dart';
import 'package:nae_hr/screens/common/uom/uom_edit.dart';
import 'package:nae_hr/screens/common/uom/uom_screen.dart';
import 'package:nae_hr/screens/common/uom/uom_view.dart';
import 'package:nae_hr/screens/home.dart';
import 'package:nae_hr/screens/production/orders/edit.dart';
import 'package:nae_hr/screens/production/orders/view.dart';
import 'package:nae_hr/screens/production/orders/screen.dart';
import 'package:nae_hr/widgets/blank_screen.dart';
import 'package:nae_hr/widgets/entity_screens.dart';

part 'ui_state.g.dart';

// subRoute: [view, edit]

@CopyWith()
class UiState extends Equatable {
  const UiState({
    this.currentRoute = const ["login"],
    this.subRoute,
    this.entity = const MemoryItem(id: '', json: {}),
    this.entityId,

    this.isSaving = false,

    this.isMenuVisible = true,
    this.isMenuCollapsed = false,
    this.isMenuFloated = false,
  });

  final List<String> currentRoute;
  final String? subRoute;
  final MemoryItem entity;
  final String? entityId;

  final bool isSaving;

  final bool isMenuVisible;
  final bool isMenuCollapsed;
  final bool isMenuFloated;

  bool get showMenu => isMenuVisible;

  @override
  List<Object> get props => [
    currentRoute, subRoute ?? '', entity, entityId ?? '',
    isSaving,
    isMenuVisible, isMenuCollapsed, isMenuFloated
  ];

  Widget entityScreen() {
    Widget screen = const BlankScreen();
    if (currentRoute == ProductionOrdersScreen.route) {
      screen = EntityScreens(
        list: const ProductionOrdersScreen(),
        view: subRoute == "edit" ? ProductionOrderEdit(entity: entity) : ProductionOrderView(entity: entity, tabIndex: 0),
      );
    } else if (currentRoute == UomScreen.route) {
      screen = EntityScreens(
        list: const UomScreen(),
        view: subRoute == "edit" ? UomEdit(entity: entity) : UomView(entity: entity),
      );
    }
    return screen;
  }
}
