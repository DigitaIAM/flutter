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
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_list.dart';
import 'package:nae/widgets/scaffold_list_calendar.dart';

import 'edit_fullscreen/edit_fullscreen.dart';

class WHReceive extends Entity {
  static const List<String> ctx = ['warehouse', 'receive', 'document'];

  static final List<Field> schema = [
    fDate,
    fCounterparty,
    fStorage,
    const Field(
        cGoods,
        ListType([
          fStorage,
          // Field('ref', ReferenceType([cGoods])),
          Field(cBatch, StringType()),
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
      list: ScaffoldListCalendar(
        entityType: WHReceive.ctx,
        newBtn: (context) {
          context.read<UiBloc>().add(ChangeView(WHReceive.ctx,
              action: 'edit', entity: MemoryItem.create()));
        },
        newBtnTooltip: (context) =>
            AppLocalizations.of(context).translate("new warehouse inventory"),
        onDateChange: (context, date) {
          context.read<MemoryBloc>().add(
                MemoryFetch(
                  'memories',
                  WHReceive.ctx,
                  schema: WHReceive.schema,
                  filter: {'date': date.toYMD()},
                  reset: true,
                ),
              );
        },
        listBuilder: (date) => WHReceiveListBuilder(date: date),
      ),
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

class WHReceiveListBuilder extends StatelessWidget {
  const WHReceiveListBuilder({super.key, required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      mode: Mode.mobile,
      ctx: WHReceive.ctx,
      schema: WHReceive.schema,
      filter: {'data': date.toYMD()},
      // groupBy: (element) => element.json[cDate] ?? '',
      groupBy: (element) {
        final id = element.json[cDate] ?? '';
        return MemoryItem(id: id, json: {cId: id, cName: id});
      },
      title: (MemoryItem item) =>
          Text(fCounterparty.resolve(item.json)?.name() ?? ''),
      subtitle: (MemoryItem item) =>
          Text(fStorage.resolve(item.json)?.name() ?? ''),
      onTap: (context, item) =>
          context.read<UiBloc>().add(ChangeView(WHReceive.ctx, entity: item)),
    );
  }
}
