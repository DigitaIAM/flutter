import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/production/pallets/screen.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/key_value.dart';

class PalletOverview extends StatelessWidget {
  final MemoryItem doc;

  const PalletOverview({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context);

    final storage = doc[cStorage]?.name() ?? '';

    return Column(
      children: <Widget>[
        KeyValue(
          label: localization.translate(cDate),
          value: DT.format(doc.json[cDate]),
          icon: const Icon(Icons.calendar_month),
        ),
        KeyValue(
          label: localization.translate(cStorage),
          value: storage,
          icon: const Icon(Icons.input),
        ),
        Container(
            color: theme.secondaryHeaderColor,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            child: Align(
                alignment: Alignment.center,
                child: Text(localization.translate("goods"),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      // color: Colors.white70,
                    )))),
        //good(context, doc.json['goods'], "good"),
        Expanded(child: goodsDetails()),
      ],
    );
  }

  Widget goodsDetails() {
    final schema = <Field>[
      fGoods.copyWith(width: 3.0),
      fQtyNew.copyWith(width: 1.0),
    ];

    return BlocProvider(
      create: (context) {
        final bloc = MemoryBloc(schema: schema, reverse: true);
        bloc.add(MemoryFetch(
          'memories',
          PalletPacking.ctxOfDispatch,
          filter: {
            cDocument: doc.id,
          },
          reverse: true,
          loadAll: true,
        ));

        return bloc;
      },
      child: BlocBuilder<MemoryBloc, RequestState>(
        builder: (BuildContext context, state) {
          final localization = AppLocalizations.of(context);

          switch (state.status) {
            case RequestStatus.failure:
              return Center(
                  child: Text(localization.translate('failed to fetch data')));
            case RequestStatus.success:
              if (state.items.isEmpty) {
                return Center(
                    child: Text(localization.translate('nothing yet')));
              }
              return buildList(context, state);
            case RequestStatus.initiate:
              // trigger initial load
              // loadMore(uiState, state);
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildList(BuildContext context, RequestState state) {
    final items = prepareData(state.items);
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        // if (widget.actions.isEmpty) {
        return card(context, item);
        // }
        // return SwipeActionWidget(
        //   item: item,
        //   actions: widget.actions,
        //   // key: key,
        //   child: card(context, item),
        // );
      },
    );
  }

  Widget card(BuildContext context, MemoryItem item) {
    // print("item ${item.json}");
    return InkWell(
      onDoubleTap: () {
        // widget.onDoubleTap?.call(context, item);
      },
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        child: ListTile(
          contentPadding:
              // const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
          // leading: const Icon(Icons.account_circle),
          title: Text(item['goods']?.name() ?? ''), // widget.title(item),
          subtitle: Text((item.json['qty'] as Qty)
              .toStringAggregated()), // widget.subtitle(item),
          // trailing:
          // widget.onTap == null ? null : const Icon(Icons.arrow_forward),
          // onTap: () {
          //   widget.onTap?.call(context, item);
          // },
        ),
      ),
    );
  }

  List<MemoryItem> prepareData(List<MemoryItem> items) {
    List<MemoryItem> result = [];

    Map<String, Qty> sums = {};
    Map<String, MemoryItem> list = {};

    for (final item in items) {
      final goods = item['goods']!;
      final qty = item.json['qty'];

      sums[goods.id] = (sums[goods.id] ?? Qty.zero()) + qty;

      list[goods.id] = goods;
    }

    for (final entry in sums.entries) {
      result.add(MemoryItem(id: '', json: {
        'goods': list[entry.key],
        'qty': entry.value,
      }));
    }

    return result;
  }
}
