import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return MemoryList(
      ctx: Printer.ctx,
      schema: Printer.schema,
      title: (MemoryItem item) => item.name(),
      subtitle: (MemoryItem item) => '${item.json['ip']}:${item.json['port']}',
      onTap: (MemoryItem item) => context.read<UiBloc>().add(ChangeView(Printer.ctx, entity: item)),
    );
  }
}
