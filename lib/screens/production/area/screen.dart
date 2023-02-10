import 'package:flutter/material.dart';
import 'package:nae_hr/models/memory/item.dart';
import 'package:nae_hr/models/ui/entity.dart';
import 'package:nae_hr/schema/schema.dart';
import 'package:nae_hr/widgets/entity_screens.dart';
import 'package:nae_hr/widgets/list_filter.dart';
import 'package:nae_hr/widgets/memory_list.dart';
import 'package:nae_hr/widgets/scaffold_list.dart';

import 'edit.dart';

class ProductionArea extends Entity {
  static const List<String> ctx = ['production', 'area'];

  static const List<Field> schema = [
    Field('name', StringType()),
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "area";

  @override
  IconData icon() => Icons.handyman_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_${DateTime.now().toString()}__'),
      ctx: ctx,
      list: const ProductionAreaScreen(),
      // action == "edit" ? UomEdit(entity: entity) : UomView(entity: entity),
      view: ProductionAreaEdit(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
      ),
    );
  }
}

class ProductionAreaScreen extends StatelessWidget {
  const ProductionAreaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: ProductionArea.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.productListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      body: const ProductionAreaListBuilder(),
    );
  }
}

class ProductionAreaListBuilder extends StatelessWidget {
  const ProductionAreaListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return const MemoryList(
      ctx: ProductionArea.ctx,
      cols: ProductionArea.schema,
    );
  }
}
