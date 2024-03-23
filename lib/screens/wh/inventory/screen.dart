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
import 'package:nae/screens/wh/inventory/edit_fullscreen/edit_fullscreen_mobile.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_list.dart';
import 'package:nae/widgets/scaffold_list_calendar.dart';

import 'edit_fullscreen/edit_fullscreen.dart';

class WHInventory extends Entity {
  static const List<String> ctx = ['warehouse', 'inventory', 'document'];

  static final List<Field> schema = [
    fDate,
    fStorage,
    // const Field(
    //     cGoods,
    //     ListType([
    //       fStorage,
    //       // Field('ref', ReferenceType([cGoods])),
    //       // Field(cBatch, StringType()),
    //       fGoods,
    //       fUomAtQty,
    //       fQty,
    // Field(cPrice, NumberType()),
    // Field(cCost, NumberType()),
    //]))
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "warehouse inventory";

  @override
  IconData icon() => Icons.inventory_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}'),
      // _${DateTime.now().toString()}__'),
      ctx: ctx,
      schema: schema,
      list: ScaffoldListCalendar(
        entityType: WHInventory.ctx,
        newBtn: (context) {
          context.read<UiBloc>().add(ChangeView(WHInventory.ctx,
              action: 'edit', entity: MemoryItem.create()));
        },
        newBtnTooltip: (context) =>
            AppLocalizations.of(context).translate("new warehouse inventory"),
        onDateChange: (context, date) {
          context.read<MemoryBloc>().add(
                MemoryFetch(
                  'memories',
                  WHInventory.ctx,
                  schema: WHInventory.schema,
                  filter: {'date': date.toYMD()},
                  reset: true,
                ),
              );
        },
        listBuilder: (date) => WHInventoriesListBuilder(date: date),
      ),

      view: action == 'view'
      ? WHInventoryEditMobile(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
      )
          : WHInventoryEditFS(
              key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
              entity: entity,
            ),
      //     : WHInventoryView(
      //         key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
      //         entity: entity,
      //         tabIndex: 0,
      //       ),
    );
  }
}

class WHInventoriesListBuilder extends StatelessWidget {
  const WHInventoriesListBuilder({super.key, required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      mode: Mode.mobile,
      ctx: WHInventory.ctx,
      schema: WHInventory.schema,
      filter: date == null ? {} : {'date': date!.toYMD()},
      //groupBy: (element) => element,
      groupBy: (element) {
        final id = element.json[cDate] ?? '';
        return MemoryItem(id: id, json: {cId: id, cName: id});
      },
      title: (MemoryItem item) => Text(fStorage.resolve(item.json)?.name()),
      subtitle: (MemoryItem item) => const Text(''),
      onTap: (context, item) =>
          context.read<UiBloc>().add(ChangeView(WHInventory.ctx, entity: item)),
    );
  }
}
