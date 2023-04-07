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

import 'edit_fullscreen.dart';

class WHTransfer extends Entity {
  static const List<String> ctx = ['warehouse', 'transfer', 'document'];

  static final List<Field> schema = [
    fDate,
    const Field('from', ReferenceType(['warehouse', 'storage'])),
    const Field('into', ReferenceType(['warehouse', 'storage'])),
//    const Field(
//        'goods',
//        ListType([
//          fStorage,
//          // Field('ref', ReferenceType(['goods'])),
//          Field('batch', StringType()),
//          fGoods,
//          fUomAtQty,
//          fQty,
//          // Field('price', NumberType()),
//          // Field('cost', NumberType()),
//        ]))
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "warehouse transfer";

  @override
  IconData icon() => Icons.move_down_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}'),
      // _${DateTime.now().toString()}__'),
      ctx: ctx,
      schema: schema,
      list: const WHTransferScreen(),
      view: WHTransferEditFS(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
      ),
//       view: action == "edit"
//           ? WHTransferEditFS(
//               key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
//               entity: entity,
//             )
//           : WHTransferView(
//               key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
//               entity: entity,
//               tabIndex: 0,
//             ),
    );
  }
}

class WHTransferScreen extends StatelessWidget {
  const WHTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaffoldList(
      entityType: WHTransfer.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.WHTransferListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_fab',
        backgroundColor: theme.primaryColorDark,
        onPressed: () {
          context.read<UiBloc>().add(ChangeView(WHTransfer.ctx,
              action: 'edit', entity: MemoryItem.create()));
        },
        tooltip:
            AppLocalizations.of(context).translate("new warehouse transfer"),
        child: Icon(
          Icons.add,
          color: theme.primaryColorLight,
        ),
      ),
      body: const WHTransferListBuilder(),
    );
  }
}

class WHTransferListBuilder extends StatelessWidget {
  const WHTransferListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      ctx: WHTransfer.ctx,
      schema: WHTransfer.schema,
      title: (MemoryItem item) => Text(fFrom.resolve(item.json)?.name() ?? ''),
      subtitle: (MemoryItem item) =>
          Text(fInto.resolve(item.json)?.name() ?? ''),
      onTap: (MemoryItem item) =>
          context.read<UiBloc>().add(ChangeView(WHTransfer.ctx, entity: item)),
//          context.read<UiBloc>().add(ChangeView(WHTransfer.ctx, entity: item)),
    );
  }
}
