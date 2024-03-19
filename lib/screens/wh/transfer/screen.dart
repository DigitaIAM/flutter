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
import 'package:table_calendar/table_calendar.dart';

import 'edit.dart';
import 'edit_fullscreen/edit_fullscreen_mobile.dart';

class WHTransfer extends Entity {
  static const List<String> ctx = ['warehouse', 'transfer', 'document'];

  static final List<Field> schema = [
    fDate,
    const Field(cFrom, ReferenceType(['warehouse', 'storage'])),
    const Field(cInto, ReferenceType(['warehouse', 'storage'])),
//    const Field(
//        cGoods,
//        ListType([
//          fStorage,
//          // Field('ref', ReferenceType([cGoods])),
//          Field(cBatch, StringType()),
//          fGoods,
//          fUomAtQty,
//          fQty,
//          // Field(cPrice, NumberType()),
//          // Field(cCost, NumberType()),
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
      list: ScaffoldListCalendar(
        entityType: WHTransfer.ctx,
        newBtn: (context) {
          context.read<UiBloc>().add(ChangeView(WHTransfer.ctx,
              action: 'edit', entity: MemoryItem.create()));
        },
        newBtnTooltip: (context) =>
            AppLocalizations.of(context).translate("new warehouse transfer"),
        onDateChange: (context, date) {
          context.read<MemoryBloc>().add(
                MemoryFetch(
                  'memories',
                  WHTransfer.ctx,
                  schema: WHTransfer.schema,
                  filter: {'date': date.toYMD()},
                  reset: true,
                ),
              );
        },
        listBuilder: (date) => WHTransferListBuilder(date: date),
      ),
      view: action == 'view'
          ? WHTransferEditMobile(
              key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
              entity: entity,
            )
          : WHTransferEdit(
              key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
              entity: entity,
            ),
      // view: WHTransferEditFS(
      //   key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
      //   entity: entity,
      // ),
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

class WHTransferListBuilder extends StatelessWidget {
  const WHTransferListBuilder({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      mode: Mode.mobile,
      ctx: WHTransfer.ctx,
      schema: WHTransfer.schema,
      filter: {'data': date.toYMD()},
      // groupBy: (element) => element.json[cDate] ?? '',
      groupBy: (element) {
        final id = element.json[cDate] ?? '';
        return MemoryItem(id: id, json: {cId: id, cName: id});
      },
      title: (MemoryItem item) => Text(fFrom.resolve(item.json)?.name() ?? ''),
      subtitle: (MemoryItem item) =>
          Text(fInto.resolve(item.json)?.name() ?? ''),
      onTap: (context, item) =>
          context.read<UiBloc>().add(ChangeView(WHTransfer.ctx, entity: item)),
//          context.read<UiBloc>().add(ChangeView(WHTransfer.ctx, entity: item)),
    );
  }
}
