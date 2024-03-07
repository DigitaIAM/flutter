import 'package:flutter/material.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/common/uom/edit.dart';
import 'package:nae/screens/wh/list_builder.dart';
import 'package:nae/screens/wh/movements/report.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/scaffold_list.dart';

class WHMovement extends Entity {
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
  IconData icon() => Icons.assignment_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_'),
      // ${DateTime.now().toString()}__
      ctx: ctx,
      schema: schema,
      list: WHMovementScreen(entity: entity),
      view: UomEdit(entity: entity),
      // action == "edit" ? UomEdit(entity: entity) : UomView(entity: entity),
    );
  }
}

class WHMovementScreen extends EntityHolder {
  const WHMovementScreen({super.key, required super.entity});

  @override
  State<WHMovementScreen> createState() => _WHMovementScreenState();
}

class _WHMovementScreenState extends State<WHMovementScreen> {
  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return ScaffoldList(
      entityType: null,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.WHReceiveListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      floatingActionButton: null,
      body: WHMovementReportScreen(entity: widget.entity),
      // WHMovementReportScreen(entity: widget.entity),
    );
  }
}

class WHMovementReportScreen extends EntityHolder {
  const WHMovementReportScreen({super.key, required super.entity});

  @override
  State<WHMovementReportScreen> createState() => _WHMovementReportScreenState();
}

class _WHMovementReportScreenState extends State<WHMovementReportScreen>
    with TickerProviderStateMixin {
  // with SingleTickerProviderStateMixin {
  late TabController _controller;

  final List<MemoryItem> reports = [
    MemoryItem.from({
      'id': '1',
      cName: 'Отчет о движении ТМЦ по складу за февраль 2024 года',
      'dates': {cFrom: '2024-02-01', cTill: '2024-02-29'},
      cStorage: '404037f2-3db7-4dae-9884-6a79fd9cd94e',
      // cGoods: '0cf13464-658f-4405-b540-d4df4d774682',
      // cBatch: {
      //   'id': '130d13a0-4d29-402f-acb5-eb3140507257',
      //   'date': '2024-02-10',
    }),
  ];

  @override
  void initState() {
    super.initState();

    _controller = TabController(
      vsync: this, length: reports.length,
      initialIndex: 0, // widget.isFilter ? 0 : state.WHDispatchUIState.tabIndex
    );
  }

  void updateController() {
    var oldIndex = _controller.index;
    if (oldIndex == reports.length) {
      if (reports.length == 0) {
        oldIndex = 0;
      } else {
        oldIndex = reports.length - 1;
      }
    }
    _controller.dispose();
    _controller = TabController(
      length: reports.length,
      initialIndex: oldIndex,
      vsync: this,
    );
    // _controller.animateTo(reports.length - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kBottomNavigationBarHeight),
        child: Container(
          color: theme.appBarTheme.backgroundColor,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                TabBar(
                  labelStyle: theme.appBarTheme.titleTextStyle,
                  indicatorColor: theme.appBarTheme.foregroundColor,
                  controller: _controller,
                  isScrollable: true,
                  tabs: reports.map((e) => Tab(text: e.name())).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Builder(builder: (context) {
          return Column(children: <Widget>[
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: buildChildren(),
              ),
            ),
          ]);
        }),
      ),
    );
  }

  List<Widget> buildChildren() {
    final List<Widget> widgets = [];

    for (final report in reports) {
      widgets.add(
        MovementReportScreen(
          entity: report,
          addReport: (report) => setState(() {
            reports.add(report);
            updateController();
            _controller.animateTo(reports.length - 1);
          }),
          closeReport: () => setState(() {
            reports.remove(report);
            var oldIndex = _controller.index;
            updateController();
            if (oldIndex > 0) {
              _controller.index = oldIndex - 1;
            }
          }),
          updateReport: (report) => setState(() {
            print("updateReport ${report.json}");
            final index = reports.indexOf(report);
            reports[index] = report;
          }),
        ),
      );
    }

    return widgets;
  }
}
