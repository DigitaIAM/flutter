import 'package:flutter/material.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/screens/production/order/widgets/ProducedEdit.dart';
import 'package:nae/screens/production/order/widgets/ProducedView.dart';
import 'package:nae/screens/wh/goods_registration.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/entity_header.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/key_value.dart';
import 'package:nae/widgets/list_divider.dart';
import 'package:nae/widgets/scaffold_view.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class ProductionOrderView extends EntityHolder {
  final int tabIndex;

  const ProductionOrderView({super.key, required super.entity, required this.tabIndex});

  @override
  State<ProductionOrderView> createState() => _ProductionOrderViewState();
}

class _ProductionOrderViewState extends State<ProductionOrderView> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();

    // final state = widget.viewModel.state;
    _controller = TabController(
        vsync: this, length: 4, initialIndex: 1 // widget.isFilter ? 0 : state.productionOrderUIState.tabIndex
        );
    _controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    // if (widget.isFilter) {
    //   return;
    // }

    // final store = StoreProvider.of<AppState>(context);
    // store.dispatch(UpdateProductTab(tabIndex: _controller.index));
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tabIndex != widget.tabIndex) {
      _controller.index = widget.tabIndex;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    final date = widget.entity.json["date"];
    final area = widget.entity.json["area"];

    final editable = date == Utils.today() || date == Utils.yesterday() || area.json['type'] == 'roll';

    return ScaffoldView(
      appBarBottom: TabBar(
        controller: _controller,
        isScrollable: true,
        tabs: [
          Tab(text: localization.translate("list")),
          Tab(text: localization.translate("overview")),
          Tab(text: localization.translate("production")),
          Tab(text: localization.translate("raw material")),
        ],
      ),
      body: Builder(builder: (context) {
        return Column(children: <Widget>[
          Expanded(
            child: TabBarView(controller: _controller, children: <Widget>[
              POProducedView(order: widget.entity),
              ProductionOrderOverview(order: widget.entity),
              ...(editable
                  ? [
                      POProducedEdit(order: widget.entity),
                      GoodsRegistration(
                        ctx: const ['warehouse', 'issue'],
                        doc: widget.entity,
                        enablePrinting: false,
                        allowGoodsCreation: false,
                      ),
                    ]
                  : [
                      POProducedView(order: widget.entity),
                      GoodsRegistration(
                        ctx: const ['warehouse', 'issue'],
                        doc: widget.entity,
                        enablePrinting: false,
                        allowGoodsCreation: false,
                      ),
                    ]),
            ]),
          ),
        ]);
      }),
    );
  }
}

class ProductionOrderOverview extends StatelessWidget {
  final MemoryItem order;

  const ProductionOrderOverview({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    String? operatorName;
    final operator = order.json['operator'];
    if (operator is MemoryItem) {
      operatorName = operator.name();
    }

    final widgets = <Widget>[
      EntityHeader(pairs: [
        // Pair(localization.translate("production order"), memoryItem.json['date'])
        Pair(localization.translate("plan"), order.json['planned'] ?? '-'),
        Pair(localization.translate("produced"), order.json['produced']?['piece'] ?? '-'),
        Pair(localization.translate("boxes"), order.json['produced']?['box'] ?? '-'),
      ]),
      ListDivider(),
      KeyValue(
        label: localization.translate("product"),
        value: order.json['product'].name(),
        icon: const Icon(Icons.question_mark),
      ),
      KeyValue(
        label: localization.translate("area"),
        value: order.json['area'].name(),
        icon: const Icon(Icons.question_mark),
      ),
      KeyValue(
        label: localization.translate("operator"),
        value: operatorName ?? ' ',
        icon: const Icon(Icons.question_mark),
      ),
      KeyValue(
        label: localization.translate("date"),
        value: DT.format(order.json['date']),
        icon: const Icon(Icons.question_mark),
      ),
      ListDivider(),
    ];

    return ScrollableListView(
      children: widgets,
    );
  }
}
