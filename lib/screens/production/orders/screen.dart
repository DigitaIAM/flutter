import 'package:flutter/material.dart';
import 'package:nae_hr/model/memory/item.dart';
import 'package:nae_hr/screens/production/orders/edit.dart';
import 'package:nae_hr/screens/production/orders/view.dart';
import 'package:nae_hr/widgets/entity_screens.dart';
import 'package:nae_hr/widgets/list_filter.dart';

import 'package:nae_hr/widgets/scaffold_list.dart';
import 'package:nae_hr/widgets/memory_list.dart';

class ProductionOrdersScreen extends StatelessWidget {
  const ProductionOrdersScreen({super.key});

  static const List<String> route = ['production', 'order'];
  static const icon = Icons.precision_manufacturing_outlined;

  static Widget create(String action, MemoryItem entity) {
    return EntityScreens(
      ctx: route,
      list: const ProductionOrdersScreen(),
      view: action == "edit" ? ProductionOrderEdit(entity: entity) : ProductionOrderView(entity: entity, tabIndex: 0),
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
      body: const ProductionOrdersListBuilder(),
    );
  }
}

class ProductionOrdersListBuilder extends StatelessWidget {
  const ProductionOrdersListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return const MemoryList(ctx: ProductionOrdersScreen.route);
  }
}