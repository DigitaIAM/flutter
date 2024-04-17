import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/production/pallets/document_edit.dart';
import 'package:nae/screens/production/pallets/edit.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/entity_screens.dart';

import 'package:nae/widgets/memory_list.dart';

import 'package:nae/widgets/scaffold_list_calendar.dart';

class PalletPacking extends Entity {
  static const List<String> ctx = ['production', 'pallet', 'packing'];
  static const List<String> ctxOfDispatch = [
    'production',
    'pallet',
    'dispatch'
  ];

  static final List<Field> schema = [fDate, fStorage, fGoods, fQtyNew];

  @override
  List<String> route() => ctx;

  @override
  String name() => "pallet packing";

  @override
  IconData icon() => Icons.pallet;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}'),
      // _${DateTime.now().toString()}__'),
      ctx: ctx,
      schema: schema,
      list: ScaffoldListCalendar(
        entityType: PalletPacking.ctx,
        newBtn: (context) {
          context.read<UiBloc>().add(ChangeView(PalletPacking.ctx,
              action: 'edit', entity: MemoryItem.create()));
        },
        newBtnTooltip: (context) =>
            AppLocalizations.of(context).translate("pallet packing"),
        onDateChange: (context, date) {
          context.read<MemoryBloc>().add(
                MemoryFetch(
                  'memories',
                  PalletPacking.ctx,
                  schema: PalletPacking.schema,
                  filter: {'date': date.toYMD()},
                  reset: true,
                ),
              );
        },
        listBuilder: (date) => PalletListBuilder(date: date),
      ),
      view: action == 'view'
          ? FormationOfPalletsEdit(
              key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
              entity: entity,
            )
          : PalletDocumentEdit(
              entity: entity,
            ),
    );
  }
}

class PalletListBuilder extends StatelessWidget {
  const PalletListBuilder({super.key, required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      mode: Mode.mobile,
      ctx: PalletPacking.ctx,
      filter: date == null ? {} : {'date': date!.toYMD()},
      schema: PalletPacking.schema,
      groupBy: (element) {
        final id = element.json[cDate] ?? '';
        //  print('json: ${element.json}');
        return MemoryItem(id: id, json: {cId: id, cName: id});
      },
      title: (MemoryItem item) => Text(fStorage.resolve(item.json)?.name()),
      subtitle: (MemoryItem item) => ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        title: Text(item['goods']?.name() ?? ''), // widget.title(item),
        subtitle: Text((item.json['qty'] as Qty).toStringAggregated()),
      ),
      onTap: (context, item) => context
          .read<UiBloc>()
          .add(ChangeView(PalletPacking.ctx, entity: item)),
    );
  }
}
