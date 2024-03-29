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

class Counterparty extends Entity {
  static const List<String> ctx = ['counterparty'];

  static const List<Field> schema = [
    fName,
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => cCounterparty;

  @override
  IconData icon() => Icons.work_outline;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_${DateTime.now().toString()}__'),
      ctx: ctx,
      list: const CounterpartyScreen(),
      // action == "edit" ? CounterpartyEdit(entity: entity) : CounterpartyView(entity: entity),
      view: CounterpartyEdit(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
      ),
    );
  }
}

class CounterpartyScreen extends StatelessWidget {
  const CounterpartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: Counterparty.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.productListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      body: const CounterpartyListBuilder(),
    );
  }
}

class CounterpartyListBuilder extends StatelessWidget {
  const CounterpartyListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      ctx: Counterparty.ctx,
      schema: Counterparty.schema,
      title: (MemoryItem item) => Text(item.name()),
      subtitle: (MemoryItem item) => const Text(''),
      onTap: (context, item) => context.read<UiBloc>().add(ChangeView(Counterparty.ctx, entity: item)),
    );
  }
}
