import 'package:flutter/material.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/wh/list_builder.dart';
import 'package:nae/screens/wh/movements/report.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/scaffold_list.dart';

import 'view.dart';

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
      view: WHMovementView(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
        // tabIndex: 0,
      ), // action == "edit" ? UomEdit(entity: entity) : UomView(entity: entity),
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
      body: MovementReportScreen(),
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

  final List<Pair> _filters = [];

  @override
  void initState() {
    super.initState();

    _controller = TabController(
      vsync: this, length: _filters.length + 1,
      initialIndex: 0, // widget.isFilter ? 0 : state.WHDispatchUIState.tabIndex
    );
  }

  void updateController() {
    final oldIndex = _controller.index;
    _controller.dispose();
    _controller = TabController(
      length: _filters.length + 1,
      initialIndex: oldIndex,
      vsync: this,
    );
    _controller.animateTo(_filters.length);
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
                  tabs: [
                    Tab(text: localization.translate('movement')),
                    ..._filters
                        .map((e) => Tab(
                            text: localization
                                .translate(e.value.name().toLowerCase())))
                        .toList()
                  ],
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
    widgets.add(MovementReportScreen());
    //widgets.add(ListBuilder(
    //   filters: const [],
    //   down: cb,
    //   ctx: WHMovement.ctx,
    //   schema: WHMovement.schema,
    // ));

    // final List<Pair> pairs = [];
    // for (final pair in _filters) {
    //   pairs.add(pair);
    //   widgets.add(ListBuilder(
    //     filters: List.from(pairs),
    //     down: cb,
    //     ctx: WHMovement.ctx,
    //     schema: WHMovement.schema,
    //   ));
    // }

    return widgets;
  }

  Future<void> cb(BuildContext context, List<Pair> filters) async {
    setState(() {
      _filters.clear();
      _filters.addAll(filters);
      updateController();
    });
  }
}
