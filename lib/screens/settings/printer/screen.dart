import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
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

class Printer extends Entity {
  static const List<String> ctx = ['printer'];

  static const List<Field> schema = [
    fName,
    Field('ip', StringType()),
    Field('port', StringType()),
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => cPrinter;

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
    final theme = Theme.of(context);
    return ScaffoldList(
      entityType: Printer.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.productListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_fab',
        backgroundColor: theme.primaryColorDark,
        onPressed: () {
          context.read<UiBloc>().add(ChangeView(Printer.ctx, action: 'edit', entity: MemoryItem.create()));
        },
        tooltip: AppLocalizations.of(context).translate("new printer"),
        child: Icon(
          Icons.add,
          color: theme.primaryColorLight,
        ),
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
      title: (MemoryItem item) => Text(item.name()),
      subtitle: (MemoryItem item) => Text('${item.json['ip']}:${item.json['port']}'),
      onTap: (context, item) => context.read<UiBloc>().add(ChangeView(Printer.ctx, entity: item)),
    );
  }
}
