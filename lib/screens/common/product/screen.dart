import 'package:flutter/material.dart';
import 'package:nae_hr/models/memory/item.dart';
import 'package:nae_hr/models/ui/entity.dart';
import 'package:nae_hr/schema/schema.dart';
import 'package:nae_hr/widgets/entity_screens.dart';
import 'package:nae_hr/widgets/list_filter.dart';
import 'package:nae_hr/widgets/memory_list.dart';
import 'package:nae_hr/widgets/scaffold_list.dart';

import 'edit.dart';

class Product extends Entity {
  static const List<String> ctx = ['product'];

  static const List<Field> schema = [
    Field('name', StringType()),
    Field('part_number', StringType()),
    Field('uom', ReferenceType(['uom'])),
    Field('qty', CalculatedType()),
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "product";

  @override
  IconData icon() => Icons.widgets_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_${DateTime.now().toString()}__'),
      ctx: ctx,
      list: const ProductScreen(),
      view: ProductEdit(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
      ), // action == "edit" ? UomEdit(entity: entity) : UomView(entity: entity),
    );
  }
}

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: Product.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.productListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      body: const ProductListBuilder(),
    );
  }
}

class ProductListBuilder extends StatelessWidget {
  const ProductListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return const MemoryList(
      ctx: Product.ctx,
      cols: Product.schema,
    );
  }
}
