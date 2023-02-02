import 'package:equatable/equatable.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';

import 'package:nae_hr/model/memory/item.dart';
import 'package:nae_hr/screens/common/uom/screen.dart';
import 'package:nae_hr/screens/production/orders/screen.dart';
import 'package:nae_hr/widgets/blank_screen.dart';

part 'ui_state.g.dart';

// subRoute: [view, edit]

@CopyWith()
class UiState extends Equatable {
  const UiState({
    this.currentRoute = const ["login"],
    this.action = 'view',
    this.entity = const MemoryItem(id: '', json: {}),
    // this.entityId = '',

    this.isSaving = false,

    this.isMenuVisible = true,
    this.isMenuCollapsed = false,
    this.isMenuFloated = false,
  });

  final List<String> currentRoute;
  final String action;
  final MemoryItem entity;
  // final String entityId;

  final bool isSaving;

  final bool isMenuVisible;
  final bool isMenuCollapsed;
  final bool isMenuFloated;

  bool get showMenu => isMenuVisible;

  @override
  List<Object> get props => [
    currentRoute, action, entity, // entityId,
    isSaving,
    isMenuVisible, isMenuCollapsed, isMenuFloated
  ];

  Widget entityScreen() {
    Widget screen = const BlankScreen();
    if (currentRoute == ProductionOrdersScreen.route) {
      screen = ProductionOrdersScreen.create(action, entity.clone());
    } else if (currentRoute == UomScreen.route) {
      screen = UomScreen.create(action, entity.clone());
    }
    return screen;
  }
}
