import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/models/ui/state.dart';
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
    // fQty,
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
      body: BlocBuilder<UiBloc, UiState>(
        builder: (context, state) {
          // print("state.action ${state.action}");
          return state.action.startsWith('category:')
              ? WHBalanceListBuilder(action: state.action)
              : const GoodsCategoriesBuilder();
        },
      ),
      // const GoodsCategoriesBuilder(),
    );
  }
}

class WHBalanceListBuilder extends StatelessWidget {
  final String action;

  const WHBalanceListBuilder({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final id = action.replaceAll("category:", "");

    return MemoryList(
      ctx: WHBalance.ctx,
      schema: WHBalance.schema,
      preprocess: (cats) {
        for (final cat in cats) {
          if (cat.id == id) {
            final List<MemoryItem> list = [];
            for (final item in cat.json["_list"]) {
              list.add(MemoryItem.from(item));
            }
            return list;
          }
        }
        return [];
      },
      groupByDate: false,
      sortByName: true,
      title: (MemoryItem item) => Text(fGoods.resolve(item.json)?.name() ?? ''),
      subtitle: (MemoryItem item) => Text(
        '${fQty.resolve(item.json)} ${fUomAtGoods.resolve(item.json)?.name() ?? ''}',
      ),
      onTap: (MemoryItem item) =>
          context.read<UiBloc>().add(ChangeView(WHBalance.ctx, entity: item)),
    );
  }
}

class GoodsCategoriesBuilder extends StatelessWidget {
  const GoodsCategoriesBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      ctx: WHBalance.ctx,
      schema: WHBalance.schema,
      groupByDate: false,
      sortByName: true,
      title: (MemoryItem item) => Text(fName.resolve(item.json) ?? ''),
      subtitle: (MemoryItem item) => const Text(''),
      onTap: (MemoryItem item) => context
          .read<UiBloc>()
          .add(ChangeView(WHBalance.ctx, action: 'category:${item.id}')),
    );
  }
}
