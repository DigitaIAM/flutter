import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
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
import 'view.dart';

class WHInventory extends Entity {
  static const List<String> ctx = ['warehouse', 'inventory', 'document'];

  static final List<Field> schema = [
    const Field('date', DateType()),
    const Field('storage', ReferenceType(['warehouse', 'storage'])),
    const Field(
        'goods',
        ListType([
          Field('storage', ReferenceType(['warehouse', 'storage'])),
          // Field('ref', ReferenceType(['goods'])),
          Field('code', StringType()),
          Field(
            'goods',
            ReferenceType([
              'goods'
            ], fields: [
              Field('name', StringType()),
              Field('uom', ReferenceType(['uom'])),
            ]),
          ),
          Field('qty', NumberType()),
          // Field('price', NumberType()),
          // Field('cost', NumberType()),
        ]))
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "warehouse inventory";

  @override
  IconData icon() => Icons.fact_check_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}'),
      // _${DateTime.now().toString()}__'),
      ctx: ctx,
      schema: schema,
      list: const WHInventoriesScreen(),
      view: action == "edit"
          ? WHInventoryEdit(
              key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
              entity: entity,
            )
          : WHInventoryView(
              key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
              entity: entity,
              tabIndex: 0,
            ),
    );
  }
}

class WHInventoriesScreen extends StatelessWidget {
  const WHInventoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaffoldList(
      entityType: WHInventory.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.whInventoryListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_fab',
        backgroundColor: theme.primaryColorDark,
        onPressed: () {
          context.read<UiBloc>().add(ChangeView(WHInventory.ctx, action: 'edit', entity: MemoryItem.create()));
        },
        tooltip: AppLocalizations.of(context).translate("new warehouse inventory"),
        child: Icon(
          Icons.add,
          color: theme.primaryColorLight,
        ),
      ),
      body: const WHInventoriesListBuilder(),
    );
  }
}

class WHInventoriesListBuilder extends StatelessWidget {
  const WHInventoriesListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      ctx: WHInventory.ctx,
      schema: WHInventory.schema,
      title: (MemoryItem item) => item.name(),
      subtitle: (MemoryItem item) => '',
      onTap: (MemoryItem item) => context.read<UiBloc>().add(ChangeView(WHInventory.ctx, entity: item)),
    );
  }
}
