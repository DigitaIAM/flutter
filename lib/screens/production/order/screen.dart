import 'package:flutter/material.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_list.dart';

import 'edit.dart';
import 'view.dart';

class ProductionOrder extends Entity {
  static const List<String> ctx = ['production', 'order'];

  static const List<Field> schema = [
    Field('date', DateType()),
    Field('area', ReferenceType(['production', 'area'])),
    Field('product', ReferenceType(['product'])),
    Field('planned', NumberType()),
    Field('produced', CalculatedType()),
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "production order";

  @override
  IconData icon() => Icons.precision_manufacturing_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_${DateTime.now().toString()}__'),
      ctx: ctx,
      list: const ProductionOrderScreen(),
      view: action == "edit"
          ? ProductionOrderEdit(
              key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
              entity: entity,
            )
          : ProductionOrderView(
              key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
              entity: entity,
              tabIndex: 0,
            ),
    );
  }
}

class ProductionOrderScreen extends StatelessWidget {
  const ProductionOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: ProductionOrder.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.productionOrderListState.filter,
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
    return const MemoryList(
      ctx: ProductionOrder.ctx,
      cols: ProductionOrder.schema,
    );
  }
}
