import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/memory_list.dart';
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

class _WHBalanceScreenState extends State<WHBalanceScreen> with TickerProviderStateMixin {
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
      onClose: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Wrapper())),
      appBarBottom: TabBar(
        controller: _controller,
        isScrollable: true,
        tabs: [
          Tab(text: localization.translate('stock')),
          ..._filters.map((e) => Tab(text: localization.translate(e.value.name()))).toList()
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
    widgets.add(ListBuilder(filters: const [], down: cb));

    final List<Pair> pairs = [];
    for (final pair in _filters) {
      pairs.add(pair);
      widgets.add(ListBuilder(filters: List.from(pairs), down: cb));
    }

    return widgets;
  }

  void cb(List<Pair> filters) {
    setState(() {
      _filters.clear();
      _filters.addAll(filters);
      updateController();
    });
  }
}

class Pair {
  final String label;
  final MemoryItem value;

  Pair(this.label, this.value);
}

class ListBuilder extends StatelessWidget {
  const ListBuilder({super.key, required this.filters, required this.down});

  final List<Pair> filters;
  final void Function(List<Pair>) down;

  // final UiState? state;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    final Map<String, dynamic> filter = {};
    for (final pair in filters) {
      filter[pair.label] = pair.value.uuid ?? '';
    }

    final cache = {};

    return BlocProvider(
      create: (context) => MemoryBloc(),
      // ..add(MemoryFetch('memories', ctx, schema: schema, filter: filter)),
      child: MemoryList(
        ctx: WHBalance.ctx,
        schema: WHBalance.schema,
        filter: filter,
        groupBy: (element) {
          final id = element.json['_category'] ?? '';
          final o = cache[id];
          if (o != null) {
            return o;
          }
          final name = localization.translate(id);
          final n = MemoryItem(id: id, json: {"_uuid": id, "name": name});
          cache[id] = n;
          return n;
        },
        groupComparator: (a, b) {
          convert(id) {
            if (id == 'storage') {
              return 1;
            } else if (id == 'category') {
              return 2;
            } else if (id == 'goods') {
              return 3;
            } else if (id == 'batch') {
              return 4;
            } else {
              return 5;
            }
          }

          return convert(a.id).compareTo(convert(b.id));
        },
        sortByName: true,
        title: (MemoryItem item) {
          final category = item.json['_category'];
          if (category == 'stock') {
            return Text(fName.resolve(item.json['goods'] ?? '') ?? '');
          } else if (category == 'batch') {
            print('_batch: ${item.json}');
            return Text('партия ${item.json['batch']?['barcode'] ?? ''}');
          } else {
            return Text(fName.resolve(item.json) ?? '');
          }
        },
        subtitle: (MemoryItem item) {
          final category = item.json['_category'];
          if (category == 'stock') {
            // print("item: ${item.json}");
            return Text('${fQty.resolve(item.json) ?? ''} ${fUomAtGoods.resolve(item.json)?.name() ?? ''}, '
                '${item.json['cost']?['number'] ?? ''} сум');
          } else if (category == 'batch') {
            // print("item: ${item.json}");
            return Text('${item.json['_cost']?['qty'] ?? ''} ${fUomAtGoods.resolve(item.json)?.name() ?? ''}, '
                '${item.json['_cost']?['cost'] ?? ''} сум');
          } else {
            return Text('${item.json['_cost'] ?? ''} сум');
          }
        },
        onTap: (MemoryItem item) {
          var category = item.json['_category'];
          if (category == 'stock') {
            final List<Pair> nf = List.from(filters);
            // print("item: ${item.json}");
            nf.add(Pair(category, MemoryItem.from(item.json['goods'])));
            down(nf);
          } else if (category == 'batch') {
            return context.read<UiBloc>().add(ChangeView(WHBalance.ctx, entity: item));
          } else {
            final List<Pair> nf = List.from(filters);
            nf.add(Pair(category, item));

            down(nf);
          }
        },
      ),
    );
  }
}
