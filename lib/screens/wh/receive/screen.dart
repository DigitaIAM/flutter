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

import 'edit_fullscreen/edit_fullscreen.dart';

class WHReceive extends Entity {
  static const List<String> ctx = ['warehouse', 'receive', 'document'];

  static final List<Field> schema = [
    fDate,
    fCounterparty,
    fStorage,
    const Field(
        'goods',
        ListType([
          fStorage,
          // Field('ref', ReferenceType(['goods'])),
          Field('batch', StringType()),
          fGoods,
          fUomAtQty,
          fQty,
          // Field('price', NumberType()),
          // Field('cost', NumberType()),
        ]))
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "warehouse receive";

  @override
  IconData icon() => Icons.input;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}'),
      // _${DateTime.now().toString()}__'),
      ctx: ctx,
      schema: schema,
      list: const WHReceiveScreen(),
      view: WHReceiveEditFS(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
      ),
//       view: action == "edit"
//           ? WHReceiveEditFS(
//               key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
//               entity: entity,
//             )
//           : WHReceiveView(
//               key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
//               entity: entity,
//               tabIndex: 0,
//             ),
    );
  }
}

class WHReceiveScreen extends StatelessWidget {
  const WHReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaffoldList(
      entityType: WHReceive.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.WHReceiveListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_fab',
        backgroundColor: theme.primaryColorDark,
        onPressed: () {
          context.read<UiBloc>().add(ChangeView(WHReceive.ctx,
              action: 'edit', entity: MemoryItem.create()));
        },
        tooltip:
            AppLocalizations.of(context).translate("new warehouse inventory"),
        child: Icon(
          Icons.add,
          color: theme.primaryColorLight,
        ),
      ),
      body: const WHReceiveListBuilder(),
    );
  }
}

class WHReceiveListBuilder extends StatelessWidget {
  const WHReceiveListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      ctx: WHReceive.ctx,
      schema: WHReceive.schema,
      // groupBy: (element) => element.json['date'] ?? '',
      groupBy: (element) => element,
      title: (MemoryItem item) =>
          Text(fCounterparty.resolve(item.json)?.name() ?? ''),
      subtitle: (MemoryItem item) =>
          Text(fStorage.resolve(item.json)?.name() ?? ''),
      onTap: (context, item) =>
          context.read<UiBloc>().add(ChangeView(WHReceive.ctx, entity: item)),
    );
  }
}
