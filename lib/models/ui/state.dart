import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/screens/common/person/screen.dart';
import 'package:nae/screens/common/product/screen.dart';
import 'package:nae/screens/common/uom/screen.dart';
import 'package:nae/screens/production/area/screen.dart';
import 'package:nae/screens/production/order/screen.dart';
import 'package:nae/screens/settings/printer/screen.dart';
import 'package:nae/widgets/blank_screen.dart';

part 'state.g.dart';

// subRoute: [view, edit]

@CopyWith()
class UiState extends Equatable {
  UiState({
    required this.mediaQueryData,
    this.currentRoute = const ["login"],
    this.action = 'view',
    this.entity = const MemoryItem(id: '', json: {}),
    // this.entityId = '',

    this.isDesktop = true,
    this.isMenuVisible = true,
    this.isMenuCollapsed = false,
    this.isMenuFloated = false,
  });

  // blockSizeHorizontal = screenWidth! / 100;
  // blockSizeVertical = screenHeight! / 100;

  final MediaQueryData mediaQueryData;

  double get screenWidth => mediaQueryData.size.width;

  double get screenHeight => mediaQueryData.size.height;

  final List<String> currentRoute;
  final String action;
  final MemoryItem entity;

  // final String entityId;

  final bool isMenuVisible;

  final bool isDesktop;
  final bool isMenuCollapsed;
  final bool isMenuFloated;

  bool get showMenu => isMenuVisible;

  bool get isFullScreen => !isDesktop;

  bool get isMobile => !isDesktop;

  final List<List<Entity>> entities = [
    [ProductionOrder()],
    [Product(), Uom(), ProductionArea()],
    [Person()],
    [Printer()],
  ];

  @override
  List<Object> get props => [
        currentRoute, action, entity, // entityId,
        entities,
        isDesktop,
        isMenuVisible, isMenuCollapsed, isMenuFloated
      ];

  Widget entityScreen() {
    print("entityScreen $currentRoute");
    for (final list in entities) {
      for (final item in list) {
        if (currentRoute == item.route()) {
          return item.screen(action, entity);
        }
      }
    }

    return const BlankScreen();
  }
}
