import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/models/ui/state.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_view.dart';

import '../../../api.dart';
import 'screen.dart';

class WHBalanceView extends EntityHolder {
  final int tabIndex;

  const WHBalanceView(
      {super.key, required super.entity, required this.tabIndex});

  @override
  State<WHBalanceView> createState() => _WHBalanceViewState();
}

class _WHBalanceViewState extends State<WHBalanceView>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();

    // final state = widget.viewModel.state;
    _controller = TabController(
      vsync: this, length: 1,
      initialIndex: 0, // widget.isFilter ? 0 : state.WHDispatchUIState.tabIndex
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

    return ScaffoldView(
      appBarBottom: TabBar(
        controller: _controller,
        isScrollable: true,
        tabs: [
          Tab(text: localization.translate("overview")),
//          Tab(text: localization.translate("goods")),
        ],
      ),
      body: Builder(builder: (context) {
        return Column(children: <Widget>[
          Expanded(
            child: TabBarView(controller: _controller, children: <Widget>[
              WHTransactionsBuilder(widget.entity)
            ] //WHDispatchOverview(doc: widget.entity), WHDispatchGoods(doc: widget.entity)]),
                ),
          ),
        ]);
      }),
    );
  }
}

class WHTransactionsBuilder extends StatelessWidget {
  final MemoryItem entity;

  const WHTransactionsBuilder(this.entity, {super.key});

  @override
  Widget build(BuildContext context) {
    final schema = [
      Field('description', CalculatedType((MemoryItem rec) async {
        final t = rec.json['type'];
        if (t == 'open_balance' || t == 'close_balance') {
          return 'balance at ${rec.json['date']}';
        } else {
          final response = await Api.feathers()
              .get(serviceName: "memories", objectId: rec.id, params: {"oid": Api.instance.oid, "ctx": []});

          final Map map = Map.from(response);

          final id = map['document'].toString();

          final ctx = id.split('/');

          final document = await Api.feathers()
              .get(serviceName: "memories", objectId: id, params: {"oid": Api.instance.oid, "ctx": ctx.sublist(0, 3)});

          final Map map_doc = Map.from(document);

          return map_doc['date'].toString();
        }
      })),
      Field(
          'receive',
          CalculatedType((MemoryItem rec) async {
            switch (rec.json['type']) {
              case 'receive':
              case 'open_balance':
              case 'close_balance':
                return rec.json['qty'];
              default:
                return '';
            }
          })),
//              == 'receive' ? rec.json['qty'] : '')),
      Field(
          'issue',
          CalculatedType((MemoryItem rec) async =>
              rec.json['type'] == 'issue' ? rec.json['qty'] : '')),
    ];

//    let goods = this.entity.

//    print("entity ${this.entity.toJson()}");

    final filter = {
      'dates': {'from': '2022-12-01', 'till': '2023-03-30'},
      'storage': this.entity.toJson()['storage'].toString(),
      'goods': this.entity.toJson()['goods'].toString(),
      'batch_id': this.entity.toJson()['batch']['id'].toString(),
      'batch_date': this.entity.toJson()['batch']['date'].toString(),
    };

    print("FILTER: ${filter}");

    return BlocBuilder<UiBloc, UiState>(
      builder: (context, uiState) => MemoryBlocHolder(
        init: (bloc) => bloc.add(
            MemoryFetch('inventory', const [], schema: schema, filter: filter)),
        child: screen(context, uiState, schema, filter),
      ),
    );
  }

  Widget screen(BuildContext context, UiState uiState, List<Field> schema,
      Map<String, dynamic> filter) {
    return MemoryList(
      service: 'inventory',
      ctx: const [],
      schema: schema,
      filter: filter,
      title: (MemoryItem item) => item.name(),
      subtitle: (MemoryItem item) =>
          '${fQty.resolve(item.json)} ${fUom.resolve(item.json)}',
      onTap: (MemoryItem item) =>
          context.read<UiBloc>().add(ChangeView(WHBalance.ctx, entity: item)),
    );
  }
}
