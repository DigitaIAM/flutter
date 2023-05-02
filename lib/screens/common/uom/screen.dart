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

class Uom extends Entity {
  static const List<String> ctx = ['uom'];

  static const List<Field> schema = [
    fName,
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "uom";

  @override
  IconData icon() => Icons.square_foot_rounded;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_${DateTime.now().toString()}__'),
      ctx: ctx,
      list: const UomScreen(),
      // action == "edit" ? UomEdit(entity: entity) : UomView(entity: entity),
      view: UomEdit(
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
    final theme = Theme.of(context);
    return ScaffoldList(
      entityType: Uom.ctx,
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
          context.read<UiBloc>().add(
              ChangeView(Uom.ctx, action: 'edit', entity: MemoryItem.create()));
        },
        tooltip: AppLocalizations.of(context).translate("new uom"),
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
      ctx: Uom.ctx,
      schema: Uom.schema,
      title: (MemoryItem item) => Text(item.name()),
      subtitle: (MemoryItem item) => const Text(''),
      onTap: (context, item) =>
          context.read<UiBloc>().add(ChangeView(Uom.ctx, entity: item)),
    );
  }
}
