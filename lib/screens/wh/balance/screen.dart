import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_list.dart';

import 'view.dart';

class WHBalance extends Entity {
  static const List<String> ctx = ['warehouse', 'stock'];

  static List<Field> schema = [
    fStorage,
    fBatch,
    fGoods,
    fQty,
    fUomAtGoods,
    // Field('qty', CalculatedType((MemoryItem goods) async => goods.balance()))
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "stock";

  @override
  IconData icon() => Icons.widgets_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_'),
      // ${DateTime.now().toString()}__
      ctx: ctx,
      schema: schema,
      list: const WHBalanceScreen(),
      view: WHBalanceView(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
        tabIndex: 0,
      ), // action == "edit" ? UomEdit(entity: entity) : UomView(entity: entity),
    );
  }
}

class WHBalanceScreen extends StatelessWidget {
  const WHBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: WHBalance.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.whBalanceListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterWHBalances(value));
          context.read<MemoryBloc>().add(MemorySearch(value));
        },
      ),
      body: const WHBalanceListBuilder(),
    );
  }
}

class WHBalanceListBuilder extends StatelessWidget {
  const WHBalanceListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      ctx: WHBalance.ctx,
      schema: WHBalance.schema,
      groupByDate: false,
      sortByName: true,
      title: (MemoryItem item) => Text(fGoods.resolve(item.json)?.name() ?? ''),
      subtitle: (MemoryItem item) => Text(
          '${fQty.resolve(item.json)} ${fUomAtGoods.resolve(item.json)?.name() ?? ''}'),
      onTap: (MemoryItem item) =>
          context.read<UiBloc>().add(ChangeView(WHBalance.ctx, entity: item)),
    );
  }
}
