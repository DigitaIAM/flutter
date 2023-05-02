import 'package:flutter/material.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/wh/list_builder.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scaffold_view.dart';
import 'package:nae/wrapper.dart';

import 'view.dart';

class WHBalance extends Entity {
  static const List<String> ctx = ['warehouse', 'stock'];

  static List<Field> schema = [
    fStorage,
    fBatch,
    fGoods,
    // fQty,
    fUomAtGoods,
    // Field('qty', CalculatedType((MemoryItem goods) async => goods.balance()))
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "stock";

  @override
  IconData icon() => Icons.widgets_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_'),
      // ${DateTime.now().toString()}__
      ctx: ctx,
      schema: schema,
      list: WHBalanceScreen(entity: entity),
      view: WHBalanceView(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
        tabIndex: 0,
      ), // action == "edit" ? UomEdit(entity: entity) : UomView(entity: entity),
    );
  }
}

class WHBalanceScreen extends EntityHolder {
  const WHBalanceScreen({super.key, required super.entity});

  @override
  State<WHBalanceScreen> createState() => _WHBalanceScreenState();
}

class _WHBalanceScreenState extends State<WHBalanceScreen>
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

    return ScaffoldView(
      onClose: () => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Wrapper())),
      appBarBottom: TabBar(
        controller: _controller,
        isScrollable: true,
        tabs: [
          Tab(text: localization.translate('stock')),
          ..._filters
              .map((e) => Tab(text: localization.translate(e.value.name())))
              .toList()
        ],
      ),
      body: Builder(builder: (context) {
        return Column(children: <Widget>[
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: buildChildren(),
            ),
          ),
        ]);
      }),
    );
  }

  List<Widget> buildChildren() {
    final List<Widget> widgets = [];
    widgets.add(ListBuilder(
      filters: const [],
      down: cb,
      ctx: WHBalance.ctx,
      schema: WHBalance.schema,
    ));

    final List<Pair> pairs = [];
    for (final pair in _filters) {
      pairs.add(pair);
      widgets.add(ListBuilder(
        filters: List.from(pairs),
        down: cb,
        ctx: WHBalance.ctx,
        schema: WHBalance.schema,
      ));
    }

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
