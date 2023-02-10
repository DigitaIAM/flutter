import 'package:flutter/material.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_list.dart';

import 'edit.dart';

class Person extends Entity {
  static const List<String> ctx = ['person'];

  static const List<Field> schema = [
    Field('name', StringType()),
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "person";

  @override
  IconData icon() => Icons.person_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_${DateTime.now().toString()}__'),
      ctx: ctx,
      list: const UomScreen(),
      // action == "edit" ? UomEdit(entity: entity) : UomView(entity: entity),
      view: PersonEdit(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
      ),
    );
  }
}

class UomScreen extends StatelessWidget {
  const UomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: Person.ctx,
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
    return const MemoryList(
      ctx: Person.ctx,
      cols: Person.schema,
    );
  }
}
