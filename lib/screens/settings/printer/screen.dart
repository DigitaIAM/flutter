import 'package:flutter/material.dart';
import 'package:nae_hr/models/memory/item.dart';
import 'package:nae_hr/models/ui/entity.dart';
import 'package:nae_hr/schema/schema.dart';
import 'package:nae_hr/widgets/entity_screens.dart';
import 'package:nae_hr/widgets/list_filter.dart';
import 'package:nae_hr/widgets/memory_list.dart';
import 'package:nae_hr/widgets/scaffold_list.dart';

import 'edit.dart';

class Printer extends Entity {
  static const List<String> ctx = ['printer'];

  static const List<Field> schema = [
    Field('name', StringType()),
    Field('ip', StringType()),
    Field('port', StringType()),
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "printer";

  @override
  IconData icon() => Icons.print_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_${DateTime.now().toString()}__'),
      ctx: ctx,
      list: const PrinterScreen(),
      // action == "edit" ? UomEdit(entity: entity) : UomView(entity: entity),
      view: PrinterEdit(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
      ),
    );
  }
}

class PrinterScreen extends StatelessWidget {
  const PrinterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: Printer.ctx,
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
      ctx: Printer.ctx,
      cols: Printer.schema,
    );
  }
}
