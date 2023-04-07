import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_list.dart';

import 'edit.dart';

class Product extends Entity {
  static const List<String> ctx = ['product'];

  static List<Field> schema = [
    fName,
    const Field('part_number', StringType()),
    fUom,
    Field('qty', CalculatedType((MemoryItem product) async => "?"))
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "product";

  @override
  IconData icon() => Icons.catching_pokemon_outlined;

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
    return MemoryList(
      ctx: Product.ctx,
      schema: Product.schema,
      title: (MemoryItem item) => Text(item.name()),
      subtitle: (MemoryItem item) => const Text(''),
      onTap: (MemoryItem item) =>
          context.read<UiBloc>().add(ChangeView(Product.ctx, entity: item)),
    );
  }
}
