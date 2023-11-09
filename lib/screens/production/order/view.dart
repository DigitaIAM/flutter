import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/screens/production/order/screen.dart';
import 'package:nae/screens/production/order/widgets/MaterialView.dart';
import 'package:nae/screens/production/order/widgets/ProducedEdit.dart';
import 'package:nae/screens/production/order/widgets/ProducedView.dart';
import 'package:nae/screens/wh/goods_dispatch.dart';
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
    _controller = TabController(vsync: this, length: 6, initialIndex: 2);
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

    final date = widget.entity.json[cDate] ?? '';
    // final area = widget.entity.json[cArea]; // not used variable

    final editable = date.compareTo(Utils.daysAgo(14)) >= 0;
    // final editable = date == Utils.today() || date == Utils.yesterday() || area.json[cType] == 'roll';

    return ScaffoldView(
      appBarBottom: TabBar(
        controller: _controller,
        isScrollable: true,
        tabs: [
          Tab(text: localization.translate("raw material")),
          Tab(text: localization.translate("products")),
          Tab(text: localization.translate("overview")),
          Tab(text: localization.translate("production")),
          Tab(text: localization.translate("used raw material")),
          Tab(text: localization.translate("produced raw material")),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.edit_note_outlined),
          tooltip: localization.translate("edit"),
          onPressed: () {
            context.read<UiBloc>().add(ChangeView(ProductionOrder.ctx, action: 'edit', entity: widget.entity));
          },
        ),
      ],
      body: Builder(builder: (context) {
        return Column(children: <Widget>[
          Expanded(
            child: TabBarView(controller: _controller, children: <Widget>[
              MaterialView(order: widget.entity),
              POProducedView(order: widget.entity),
              ProductionOrderOverview(order: widget.entity),
              ...(editable
                  ? [
                      POProducedEdit(order: widget.entity),
                    ]
                  : [
                      POProducedView(order: widget.entity),
                    ]),
              GoodsDispatch(
                ctx: const ['production', 'material', 'used'],
                doc: widget.entity,
                schema: ProductionOrder.schema,
                enablePrinting: false,
                allowGoodsCreation: false,
              ),
              GoodsRegistration(
                ctx: const ['production', 'material', 'produced'],
                doc: widget.entity,
                schema: ProductionOrder.schema,
                enablePrinting: true,
                allowGoodsCreation: false,
              ),
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
    final operator = order.json[cOperator];
    if (operator is MemoryItem) {
      operatorName = operator.name();
    }

    final widgets = <Widget>[
      Text(localization.translate("material product"),
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      EntityHeader(pairs: [
        // Pair(localization.translate("production order"), memoryItem.json[cDate])
        Pair(localization.translate("plan"), order.json['planned'] ?? '-'),
        Pair(localization.translate("produced"), order.json['produced']?['piece'] ?? '-'),
        Pair(localization.translate("boxes"), order.json['produced']?['box'] ?? '-'),
      ]),
      KeyValue(
        label: localization.translate(cProduct),
        value: order.json[cProduct][cName] ?? order.json[cProduct].name(),
        icon: const Icon(Icons.question_mark),
      ),
      ...additional(context),
      KeyValue(
        label: localization.translate(cArea),
        value: order.json[cArea][cName] ?? order.json[cArea].name(),
        icon: const Icon(Icons.question_mark),
      ),
      KeyValue(
        label: localization.translate(cOperator),
        value: operatorName ?? ' ',
        icon: const Icon(Icons.question_mark),
      ),
      KeyValue(
        label: localization.translate(cDate),
        value: DT.format(order.json[cDate]),
        icon: const Icon(Icons.question_mark),
      ),
      ListDivider(),
      Text(localization.translate("materials"),
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      EntityHeader(pairs: [
        Pair(localization.translate("used material"), order.json['_material']?['sum']?['used'] ?? '-'),
        Pair(localization.translate("produced material"), order.json['_material']?['sum']?['produced'] ?? '-'),
        Pair(localization.translate("delta"), order.json['_material']?['sum']?['delta'] ?? '-'),
      ]),
      ...buildItemsList(context, order.json['_material']?['used'], "materials used"),
      ...buildItemsList(context, order.json['_material']?['produced'], "materials produced"),
    ];

    return ScrollableListView(
      children: widgets,
    );
  }

  List<Widget> buildItemsList(BuildContext context, dynamic data, String label) {
    final localization = AppLocalizations.of(context);

    var children = <Widget>[];

    // print('buildItemsList $data');

    if (data != null) {
      if (data is List) {
        if (data.isNotEmpty) {
          children.add(Text(localization.translate(label), textAlign: TextAlign.center));
        }

        for (Map item in data) {
          children.add(KeyValue(
            label: item['name'] ?? '',
            value: item['used'] ?? item['produced'] ?? '',
            icon: const Icon(Icons.question_mark),
          ));
        }
      } else if (data is Map) {
        if (data.isNotEmpty) {
          children.add(Text(localization.translate(label), textAlign: TextAlign.center));
        }

        children.add(KeyValue(
          label: data['name'] ?? '',
          value: data['used'] ?? data['produced'] ?? '',
          icon: const Icon(Icons.question_mark),
        ));
      }
    }

    return children;
  }

  List<Widget> additional(BuildContext context) {
    final product = order.json[cProduct] ?? MemoryItem.empty;
    final type = product is MemoryItem ? product.json[cType] ?? '' : product[cType] ?? '';
    if (type == 'roll') {
      final localization = AppLocalizations.of(context);

      return [
        KeyValue(
          label: localization.translate("raw material"),
          value: order.json['material'] ?? '',
          icon: const Icon(Icons.question_mark),
        ),
        KeyValue(
          label: localization.translate("thickness"),
          value: order.json['thickness'] ?? '',
          icon: const Icon(Icons.question_mark),
        ),
      ];
    }
    return [];
  }
}
