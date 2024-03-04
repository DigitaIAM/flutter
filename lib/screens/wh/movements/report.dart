import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/utils/number.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';

class MovementReportScreen extends StatefulWidget {
  const MovementReportScreen({super.key});

  static const List<String> ctx = ['warehouse', 'movement'];

  static List<Field> schema = [
    fStorage,
    fBatch,
    fGoods,
    // fQty,
    fUomAtGoods,
    // Field(cQty, CalculatedType((MemoryItem goods) async => goods.balance()))
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "movement";

  @override
  State<MovementReportScreen> createState() => _MovementReportScreenState();
}

class _MovementReportScreenState extends State<MovementReportScreen> {
  DateTime fromDate = DateTime.now();
  DateTime? tillDate;

  (int, int)? hoverFocus;

  late CleanCalendarController calendarController;

  void setRange(DateTime firstDate, DateTime? secondDate) {
    setState(() {
      fromDate = firstDate;
      tillDate = secondDate;
    });
  }

  @override
  void initState() {
    super.initState();

    calendarController = CleanCalendarController(
      minDate: DateTime.now().subtract(const Duration(days: 365)),
      maxDate: DateTime.now().add(const Duration(days: 365)),
      onRangeSelected: setRange,
      onDayTapped: (date) {},
      // readOnly: true,
      onPreviousMinDateTapped: (date) {},
      onAfterMaxDateTapped: (date) {},
      weekdayStart: DateTime.monday,
      initialFocusDate: DateTime.now(),
      // initialDateSelected: DateTime(2022, 3, 15),
      // endDateSelected: DateTime(2022, 3, 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    var label = '';
    if (tillDate == null) {
      label = 'на ${DT.f(fromDate)}';
    } else {
      label = 'с ${DT.f(fromDate)} по ${DT.f(tillDate!)}';
    }

    var counter = 1;

    final cols = [
      Col("Название"),
      GCol('На начало', [Col("кол-во"), Col("сумма")]),
      GCol('Приход', [Col("кол-во"), Col("сумма")]),
      GCol('Расход', [Col("кол-во"), Col("сумма")]),
      GCol('На конец', [Col("кол-во"), Col("сумма")]),
    ];

    final schema = [
      const Field('store', ReferenceType([cWarehouse, cStorage])),
      fGoods,
    ];

    // TODO: implement build
    return BlocProvider(
      create: (ctx) {
        return MemoryBloc(schema: schema)
          ..add(MemoryFetch('inventory', const [],
              schema: schema,
              filter: {
                'dates': {cFrom: '2024-01-01', cTill: Utils.today()},
                cStorage: '404037f2-3db7-4dae-9884-6a79fd9cd94e',
              }));
        // ..add(MemoryFetch('memories', const ['warehouse', 'stock']));
      },
      child: BlocBuilder<MemoryBloc, RequestState>(builder: (context, state) {
        // LinkedHashMap<String, List<MemoryItem>> categories = LinkedHashMap();
        // for (final item in state.items) {
        //   categories.update(
        //     item.json['_category'],
        //     (list) => list..add(item),
        //     ifAbsent: () => [item],
        //   );
        // }

        return Column(children: [
          calendar(context),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Отчет о движении ТМЦ $label',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          headline(cols),
          Expanded(
              child: Row(
            children: [
              Expanded(
                  child: Column(
                children: state.items
                    .map((item) {
                      // final category = e.key;
                      // final list = e.value;

                      List<Widget> rows = [];
                      // rows.add(groupRow(
                      //     counter++, localization.translate(category)));
                      // for (final item in e) {
                      print("item ${item.json}");
                      if (item.json['goods'].isEmpty) {
                        rows.add(rowStore(counter++, item));
                      } else {
                        rows.add(rowGoods(counter++, item));
                      }
                      // }

                      return rows;
                    })
                    .expand((i) => i)
                    .toList(),
              )),
            ],
          )),
        ]);
      }),
    );
  }

  Widget headline(List<Col> cols) {
    return SizedBox(
        height: 50,
        child: Row(
          children: cols.map((item) {
            if (item is GCol) {
              return groupcell(item);
            } else {
              return titlecell(item.label);
            }
          }).toList(),
        ));
  }

  Widget groupcell(GCol group) {
    return Flexible(
      flex: 10,
      child: Column(
        children: [
          Expanded(
              child: Row(
            children: [titlecell(group.label)],
          )),
          Expanded(
              child: Row(
            children: group.cols.map((e) => titlecell(e.label)).toList(),
          ))
        ],
      ),
    );
  }

  Widget groupRow(int index, String label) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          datacell((1, index), label),
        ],
      ),
    );
  }

  Widget rowStore(int index, MemoryItem item) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          datacell(
              (1, index), (item.json['store'] ?? MemoryItem.empty()).name()),
          datacell(
            (2, index),
            '', // Number.f(item.json['open_balance']?['qty'] ?? ''),
            isNumber: true,
          ),
          datacell(
            (3, index),
            Number.f(item.json['open_balance'] ?? ''),
            isNumber: true,
          ),
          datacell(
            (4, index),
            '', // Number.f(item.json['_cost'] ?? ''),
            isNumber: true,
          ),
          datacell(
            (5, index),
            Number.f(item.json['_cost'] ?? ''),
            isNumber: true,
          ),
          datacell(
            (6, index),
            Number.f(item.json['_cost'] ?? ''),
            isNumber: true,
          ),
          datacell(
            (7, index),
            Number.f(item.json['_cost'] ?? ''),
            isNumber: true,
          ),
          datacell((8, index), item.json['_cost'] ?? ''),
          datacell(
            (9, index),
            Number.f(item.json['_cost'] ?? ''),
            isNumber: true,
          ),
        ],
      ),
    );
  }

  Widget rowGoods(int index, MemoryItem item) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          datacell(
              (1, index), (item.json['goods'] ?? MemoryItem.empty()).name()),
          datacell(
            (2, index),
            // Number.f(item.json['open_balance']?['qty'] ?? ''),
            item.json['open_balance']?['qty']?.toString() ?? '',
            isNumber: true,
          ),
          datacell(
            (3, index),
            Number.f(item.json['open_balance']?['cost'] ?? ''),
            isNumber: true,
          ),
          datacell(
            (4, index),
            Number.f(item.json['receive']?['qty']?.toString() ?? ''),
            isNumber: true,
          ),
          datacell(
            (5, index),
            Number.f(item.json['receive']?['cost'] ?? ''),
            isNumber: true,
          ),
          datacell(
            (6, index),
            Number.f(item.json['issue']?['qty']?.toString() ?? ''),
            isNumber: true,
          ),
          datacell(
            (7, index),
            Number.f(item.json['issue']['cost'] ?? ''),
            isNumber: true,
          ),
          datacell(
              (8, index), item.json['close_balance']?['qty']?.toString() ?? ''),
          datacell(
            (9, index),
            Number.f(item.json['close_balance']['cost'] ?? ''),
            isNumber: true,
          ),
        ],
      ),
    );
  }

  Widget calendar(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => Dialog(
              child: SizedBox(
                width: 500,
                height: 750,
                child: Column(children: [
                  Row(children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.close),
                    )
                  ]),
                  SizedBox(
                    width: 500,
                    height: 700,
                    child: ScrollableCleanCalendar(
                      calendarController: calendarController,
                      layout: Layout.BEAUTY,
                      calendarCrossAxisSpacing: 0,
                    ),
                  ),
                ]),
              ),
            ),
          ),
          child: const Icon(Icons.calendar_today_outlined, color: Colors.white),
        ),
      ],
    );
  }

  Widget titlecell(String content) {
    return Flexible(
        flex: 5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            border: Border.all(color: Colors.black45, width: 0.4),
          ),
          child: Align(
            child: Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              content,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }

  Widget datacell((int, int) index, String content, {bool isNumber = false}) {
    final highlighting = hoverFocus != null &&
        (hoverFocus!.$2 == index.$2 || hoverFocus!.$1 == index.$1);

    Widget text = Text(
      content,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.normal,
      ),
    );
    if (content.length > 20) {
      text = Tooltip(message: content, child: text);
    }
    return Flexible(
        flex: 5,
        child: InkWell(
            onDoubleTap: () {},
            onHover: (val) {
              setState(() {
                hoverFocus = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              decoration: BoxDecoration(
                color: highlighting ? Colors.white : Colors.white70,
                border: Border.all(color: Colors.black45, width: 0.4),
              ),
              child: Align(
                alignment: isNumber ? Alignment.centerRight : Alignment.center,
                heightFactor: 1.5,
                child: text,
              ),
            )));
  }
}

class Col {
  final String label;

  Col(this.label);
}

class GCol extends Col {
  final List<Col> cols;

  GCol(super.label, this.cols);
}
