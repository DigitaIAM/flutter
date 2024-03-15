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
import 'package:table_calendar/table_calendar.dart';

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
      list: const WHTransferScreen(),
      view: WHTransferEditMobile(
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

class WHTransferScreen extends StatefulWidget {
  const WHTransferScreen({super.key});

  @override
  State<WHTransferScreen> createState() => _WHTransferScreenState();
}

class _WHTransferScreenState extends State<WHTransferScreen> {
  _WHTransferScreenState();

  DateTime _selectedDay = DateTime.now();
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
        body: Row(
          children: [
            SizedBox(width: 300, child: calendar(context)),
            Expanded(
              child: WHTransferListBuilder(
                date: _selectedDay,
              ),
            ),
          ],
        ));
  }

  Widget calendar(BuildContext context) {
    return TableCalendar(
      locale: 'ru',
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      startingDayOfWeek: StartingDayOfWeek.monday,
      firstDay: DateTime(2023, 1, 1),
      lastDay: DateTime.now().add(const Duration(days: 1)),
      focusedDay: _selectedDay,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            context.read<MemoryBloc>().add(
                  MemoryFetch(
                    'memories',
                    WHTransfer.ctx,
                    schema: WHTransfer.schema,
                    filter: {'date': selectedDay.toYMD()},
                    reset: true,
                  ),
                );
          });
        }
      },
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
