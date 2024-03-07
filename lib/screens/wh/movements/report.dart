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

const String openQty = 'open.qty';
const String receiveQty = 'receive.qty';
const String issueQty = 'issue.qty';
const String closeQty = 'close.qty';

class MovementReportScreen extends StatefulWidget {
  const MovementReportScreen(
      {super.key,
      required this.entity,
      required this.cb,
      required this.closeReport});

  final MemoryItem entity;
  final Function(MemoryItem) cb;
  final Function() closeReport;

  @override
  State<MovementReportScreen> createState() => _MovementReportScreenState();
}

class _MovementReportScreenState extends State<MovementReportScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime fromDate = DateTime.now();
  DateTime? tillDate;

  late CleanCalendarController calendarController;

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    // print("MovementReportScreen.build");

    final localization = AppLocalizations.of(context);

    var label = '';
    if (tillDate == null) {
      label = 'на ${DT.f(fromDate)}';
    } else {
      label = 'с ${DT.f(fromDate)} по ${DT.f(tillDate!)}';
    }

    final cols = [
      Col("Название"),
      GCol('На начало', [Col("кол-во"), Col("сумма")]),
      GCol('Приход', [Col("кол-во"), Col("сумма")]),
      GCol('Расход', [Col("кол-во"), Col("сумма")]),
      GCol('На конец', [Col("кол-во"), Col("сумма")]),
    ];

    var schema = [
      const Field('store', ReferenceType([cWarehouse, cStorage])),
      fGoods,
      const Field(openQty, path: ['open_balance', 'qty'], QtyType()),
      const Field(receiveQty, path: ['receive', 'qty'], QtyType()),
      const Field(issueQty, path: ['issue', 'qty'], QtyType()),
      const Field(closeQty, path: ['close_balance', 'qty'], QtyType()),
    ];

    final filter = {
      'dates': {cFrom: '2022-01-01', 'till': Utils.today()},
      cStorage: widget.entity.json[cStorage],
      //cGoods: widget.entity.json['goods'],
      //'batch_id': widget.entity.json[cBatch]['batch_id'],
      //'batch_date': widget.entity.json[cBatch][cDate],
    };

    final goods = widget.entity.json['goods'];
    // print('goods $goods');

    var detailed = false;
    if (goods != null) {
      detailed = true;

      filter[cGoods] = goods;
      filter['batch_id'] = widget.entity.json[cBatch]['id'];
      filter['batch_date'] = widget.entity.json[cBatch][cDate];

      schema = [
        fGoods,
        fFrom,
        fInto,
        const Field('qty', QtyType()),
      ];
    }

    // TODO: implement build
    return BlocProvider(
      create: (ctx) {
        return MemoryBloc(schema: schema)
          ..add(MemoryFetch('inventory', const [],
              schema: schema, filter: filter));
        // ..add(MemoryFetch('memories', const ['warehouse', 'stock']));
      },
      child: BlocBuilder<MemoryBloc, RequestState>(builder: (context, state) {
        return Column(children: [
          calendar(context),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "$label",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  alignment: FractionalOffset.topRight,
                  child: IconButton(
                    onPressed: () {
                      widget.closeReport();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ],
            ),
          ),
          headline(cols),
          Expanded(
              child: SingleChildScrollView(
                  child: Row(
            children: [
              Expanded(
                  child: Column(
                children: state.items.map((item) {
                  // print("item ${item.json}");
                  if (detailed) {
                    return RowDetailedWidget(item: item, cb: widget.cb);
                  } else {
                    return RowWidget(item: item, cb: widget.cb);
                  }
                }).toList(),
              )),
            ],
          ))),
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
          datacell(label),
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
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }

  Widget datacell(String content, {bool isNumber = false}) {
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
              // setState(() {
              //   highlighting = true;
              // });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white70, // highlighting ? Colors.white :
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

class RowWidget extends StatefulWidget {
  const RowWidget({super.key, required this.item, required this.cb});

  final MemoryItem item;
  final Function(MemoryItem) cb;

  @override
  State<RowWidget> createState() => _RowWidgetState();
}

class _RowWidgetState extends State<RowWidget> {
  bool highlighting = false;

  @override
  Widget build(BuildContext context) {
    // print("RowWidget.build");
    final item = widget.item;
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          datacell(item.json['goods'].name()),
          datacell(
            item.json[openQty].toString(),
            isNumber: true,
          ),
          datacell(
            Number.f(item.json['open_balance']?['cost'] ?? ''),
            isNumber: true,
          ),
          datacell(
            item.json[receiveQty].toString(),
            isNumber: true,
          ),
          datacell(
            Number.f(item.json['receive']?['cost'] ?? ''),
            isNumber: true,
          ),
          datacell(
            item.json[issueQty].toString(),
            isNumber: true,
          ),
          datacell(
            Number.f(item.json['issue']['cost'] ?? ''),
            isNumber: true,
          ),
          datacell(
            item.json[closeQty].toString(),
            isNumber: true,
          ),
          datacell(
            Number.f(item.json['close_balance']['cost'] ?? ''),
            isNumber: true,
          ),
        ],
      ),
    );
  }

  Widget datacell(String content, {bool isNumber = false}) {
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
            onDoubleTap: () {
              //  print("click ${widget.item.json}");
              widget.cb(MemoryItem.from({
                'id': '1',
                cName: widget.item.json[cGoods].name(),
                'dates': {cFrom: '2024-02-01', cTill: '2024-02-29'},
                cStorage: widget.item.json['store'].uuid,
                cGoods: widget.item.json['goods'].uuid,
                cBatch: widget.item.json[cBatch]
              }));
            },
            onHover: (val) {
              setState(() {
                highlighting = val;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              decoration: BoxDecoration(
                color: highlighting ? Colors.white : const Color(0xDDFFFFFF),
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

Widget datacell(String content, {bool isNumber = false}) {
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white70, // highlighting ? Colors.white :
          border: Border.all(color: Colors.black45, width: 0.4),
        ),
        child: Align(
          alignment: isNumber ? Alignment.centerRight : Alignment.center,
          heightFactor: 1.5,
          child: text,
        ),
      ));
}

class RowDetailedWidget extends StatefulWidget {
  const RowDetailedWidget({super.key, required this.item, required this.cb});

  final MemoryItem item;
  final Function(MemoryItem) cb;

  @override
  State<RowDetailedWidget> createState() => _RowDetailedWidget();
}

class _RowDetailedWidget extends State<RowDetailedWidget> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    print('json: ${item.json}');
    final opType = item.json['type'];

    //item.json[openQty].toString(),

    if (opType == 'open_balance') {
      return SizedBox(
          height: 30,
          child: Row(children: [
            datacell(''),
            datacell(
              item.json['qty'].toString(),
              isNumber: true,
            ),
            datacell(
              Number.f(item.json['cost'] ?? ''),
              isNumber: true,
            ),
            datacell(''),
            datacell(''),
            datacell(''),
            datacell(''),
            datacell(''),
            datacell(''),
          ]));
    } else if (opType == 'receive') {
      return SizedBox(
          height: 30,
          child: Row(children: [
            datacell(item.json['into'].name()),
            datacell(''),
            datacell(''),
            datacell(
              item.json['qty'].toString(),
              isNumber: true,
            ),
            datacell(
              Number.f(item.json['cost'] ?? ''),
              isNumber: true,
            ),
            datacell(''),
            datacell(''),
            datacell(''),
            datacell(''),
          ]));
    } else if (opType == 'issue') {
      return SizedBox(
          height: 30,
          child: Row(children: [
            datacell(item.json['into'].name()),
            datacell(''),
            datacell(''),
            datacell(''),
            datacell(''),
            datacell(
              item.json['qty'].toString(),
              isNumber: true,
            ),
            datacell(
              Number.f(item.json['cost'] ?? ''),
              isNumber: true,
            ),
            datacell(''),
            datacell(''),
          ]));
    } else if (opType == 'close_balance') {
      return SizedBox(
          height: 30,
          child: Row(children: [
            datacell(''),
            datacell(''),
            datacell(''),
            datacell(''),
            datacell(''),
            datacell(''),
            datacell(''),
            datacell(
              item.json['qty'].toString(),
              isNumber: true,
            ),
            datacell(
              Number.f(item.json['cost'] ?? ''),
              isNumber: true,
            ),
          ]));
    } else {
      return const SizedBox(height: 30, child: Row(children: []));
    }
  }
}
