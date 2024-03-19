import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/entity_screens.dart';

import 'package:nae/widgets/memory_list.dart';

import 'package:nae/widgets/scaffold_list_calendar.dart';

import 'edit_fullscreen/edit_fullscreen.dart';

// [cGoods] => ['warehouse','inventory'],
//              ['warehouse','receive'],
//              ['warehouse','transfer'],
//              ['warehouse','dispatch']
class WHDispatch extends Entity {
  static const List<String> ctx = ['warehouse', 'dispatch', 'document'];

  static final List<Field> schema = [
    fDate,
    fCounterparty,
    fStorage,
    const Field(
        cGoods,
        ListType([
          fStorage,
          // Field('ref', ReferenceType([cGoods])),
          // Field(cBatch, StringType()),
          fGoods,
          fUomAtQty,
          fQty,
          // Field(cPrice, NumberType()),
          // Field(cCost, NumberType()),
        ]))
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "warehouse dispatch";

  @override
  IconData icon() => Icons.output;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}'),
      // _${DateTime.now().toString()}__'),
      ctx: ctx,
      schema: schema,
      list: ScaffoldListCalendar(
        entityType: WHDispatch.ctx,
        newBtn: (context) {
          context.read<UiBloc>().add(ChangeView(WHDispatch.ctx,
              action: 'edit', entity: MemoryItem.create()));
        },
        newBtnTooltip: (context) =>
            AppLocalizations.of(context).translate("new warehouse transfer"),
        onDateChange: (context, date) {
          context.read<MemoryBloc>().add(
                MemoryFetch(
                  'memories',
                  WHDispatch.ctx,
                  schema: WHDispatch.schema,
                  filter: {'date': date.toYMD()},
                  reset: true,
                ),
              );
        },
        listBuilder: (date) => WHDispatchListBuilder(date: date),
      ),
      view: WHDispatchEditFS(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
      ),
//       view: action == "edit"
//           ? WHDispatchEditFS(
//               key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
//               entity: entity,
//             )
//           : WHDispatchView(
//               key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
//               entity: entity,
//               tabIndex: 0,
//             ),
    );
  }
}

class WHDispatchListBuilder extends StatelessWidget {
  const WHDispatchListBuilder({super.key, required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      mode: Mode.mobile,
      ctx: WHDispatch.ctx,
      schema: WHDispatch.schema,
      filter: {'data': date.toYMD()},
      // groupBy: (element) => element.json[cDate] ?? '',
      groupBy: (element) {
        final id = element.json[cDate] ?? '';
        return MemoryItem(id: id, json: {cId: id, cName: id});
      },
      title: (MemoryItem item) =>
          Text(fStorage.resolve(item.json)?.name() ?? ''),
      subtitle: (MemoryItem item) =>
          Text(fCounterparty.resolve(item.json)?.name() ?? ''),
      onTap: (context, item) =>
          context.read<UiBloc>().add(ChangeView(WHDispatch.ctx, entity: item)),
    );
  }
}
