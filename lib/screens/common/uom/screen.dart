import 'package:flutter/material.dart';

import 'package:nae_hr/model/memory/item.dart';
import 'package:nae_hr/screens/common/uom/edit.dart';
import 'package:nae_hr/widgets/entity_screens.dart';
import 'package:nae_hr/widgets/list_filter.dart';
import 'package:nae_hr/widgets/scaffold_list.dart';
import 'package:nae_hr/widgets/memory_list.dart';

class UomScreen extends StatelessWidget {
  const UomScreen({super.key});

  static const List<String> route = ['uom'];
  static const icon = Icons.square_foot_rounded;

  static Widget create(String action, MemoryItem entity) {
    return  EntityScreens(
      ctx: route,
      list: const UomScreen(),
      view: UomEdit(
          key: ValueKey('__uom_${entity.id}_${entity.updatedAt}__'),
          entity: entity
      ), // action == "edit" ? UomEdit(entity: entity) : UomView(entity: entity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: route,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.productListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      body: const UomListBuilder(),
    );
  }
}

class UomListBuilder extends StatelessWidget {
  const UomListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return const MemoryList(ctx: UomScreen.route);
  }
}