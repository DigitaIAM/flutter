import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'list_filter.dart';
import 'scaffold_list.dart';

class ScaffoldListCalendar extends StatefulWidget {
  const ScaffoldListCalendar({
    super.key,
    this.entityType,
    this.newBtn,
    this.newBtnTooltip,
    required this.onDateChange,
    required this.listBuilder,
  });

  final List<String>? entityType;

  final Function(BuildContext)? newBtn;
  final String Function(BuildContext)? newBtnTooltip;

  final Function(BuildContext, DateTime) onDateChange;
  final Widget Function(DateTime) listBuilder;

  @override
  State<ScaffoldListCalendar> createState() => _ScaffoldListCalendarState();
}

class _ScaffoldListCalendarState extends State<ScaffoldListCalendar> {
  _ScaffoldListCalendarState();

  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaffoldList(
        entityType: widget.entityType,
        appBarTitle: ListFilter(
          // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
          filter: null, //state.WHTransferListState.filter,
          onFilterChanged: (value) {
            // store.dispatch(FilterProducts(value));
          },
        ),
        floatingActionButton: widget.newBtn == null
            ? null
            : FloatingActionButton(
                heroTag: 'product_fab',
                backgroundColor: theme.primaryColorDark,
                onPressed: () => widget.newBtn?.call(context),
                tooltip: widget.newBtnTooltip?.call(context),
                child: Icon(
                  Icons.add,
                  color: theme.primaryColorLight,
                ),
              ),
        body: Row(
          children: [
            SizedBox(width: 300, child: calendar(context)),
            Flexible(
              flex: 1,
              child: widget.listBuilder(_selectedDay),
            ),
            // Flexible(flex: 1, child: Container()),
            // Expanded(
            //   child: widget.listBuilder(_selectedDay),
            // ),
          ],
        ));
  }

  // body: Row(
  //         children: [
  //           SizedBox(width: 300, child: calendar(context)),
  //           Flexible(
  //               flex: 2, child: ProductionOrdersListBuilder(date: _selectedDay)),
  //         ],
  //       ),

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
          widget.onDateChange(context, selectedDay);
          setState(() {
            _selectedDay = selectedDay;
          });
        }
      },
    );
  }
}
