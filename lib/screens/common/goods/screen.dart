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

class Goods extends Entity {
  static const List<String> ctx = ['goods'];

  static List<Field> schema = [
    const Field('name', StringType()),
    const Field('uom', ReferenceType(['uom'])),
    Field('qty', CalculatedType((MemoryItem goods) async => "?"))
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "goods";

  @override
  IconData icon() => Icons.widgets_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_${DateTime.now().toString()}__'),
      ctx: ctx,
      list: const GoodsScreen(),
      view: GoodsEdit(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
      ), // action == "edit" ? UomEdit(entity: entity) : UomView(entity: entity),
    );
  }
}

class GoodsScreen extends StatelessWidget {
  const GoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: Goods.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.goodsListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterGoodss(value));
        },
      ),
      body: const GoodsListBuilder(),
    );
  }
}

class GoodsListBuilder extends StatelessWidget {
  const GoodsListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      ctx: Goods.ctx,
      schema: Goods.schema,
      title: (MemoryItem item) => item.name(),
      subtitle: (MemoryItem item) => '',
      onTap: (MemoryItem item) => context.read<UiBloc>().add(ChangeView(Goods.ctx, entity: item)),
    );
  }
}
