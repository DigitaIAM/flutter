import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/key_value.dart';

class WHInventoryOverview extends StatelessWidget {
  final MemoryItem doc;

  const WHInventoryOverview({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    // print("context in WHReceiveOverview: $context");
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context);

    const ctx = ['warehouse', 'inventory'];
    final filter = {
      cDocument: doc.id,
    };
    final schema = <Field>[
      fGoods.copyWith(width: 3.0),
      // fUomAtQty.copyWith(width: 0.5, editable: false),
      fQtyNew.copyWith(width: 1.0),
    ];

    //  print("doc: ${doc.json}");

    final storage = doc.json[cStorage] is MemoryItem
        ? doc.json[cStorage].name()
        : doc.json[cStorage][cName] ?? '';

    return BlocProvider(
      create: (context) {
        final bloc = MemoryBloc(schema: schema, reverse: true);
        bloc.add(MemoryFetch(
          'memories',
          ctx,
          filter: filter,
          reverse: true,
          loadAll: true,
        ));

        //print("bloc $bloc");

        return bloc;
      },
      child: BlocConsumer<MemoryBloc, RequestState>(
        listener: (context, state) {
          // do stuff here based on BlocA's state
        },
        builder: (context, state) => ListView(children: <Widget>[
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
            child: const Align(
              alignment: Alignment.center,
              child: Text('',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    // color: Colors.white70,
                  )),
            ),
          ),
          ...buildItemsList(context, state.items, ''),
        ]),
      ),
    );
  }

  List<Widget> buildItemsList(
      BuildContext context, List<MemoryItem> data, String label) {
    // final localization = AppLocalizations.of(context);

    var children = <Widget>[];

    // print('buildItemsList $data');

    Map<(String?, String?, String?, String?), Qty> numbers = {};
    Map<String, MemoryItem?> goods = {};
    Map<String, MemoryItem?> batches = {};

    for (final item in data) {
      goods[item['goods']?.id ?? ''] = item['goods'];
      batches[item['batch']?.id ?? ''] = item['batch'];

      final key = (
        item['goods']?.id,
        item.json['customer'] as String?,
        item.json['label'] as String?,
        item['batch']?.id,
      );

      final qty = Qty.fromJson(item.json['qty']);

      // print("data ${item.json['qty']}");
      // print("qty $qty");

      final num = numbers[key];
      if (num == null) {
        numbers[key] = qty;
      } else {
        numbers[key] = num + qty;
      }
    }

    final keys = List.from(numbers.keys);
    keys.sort((a, b) {
      final ga = goods[a.$1];
      final gb = goods[b.$1];

      final gc = (ga?.name() ?? '').compareTo(gb?.name() ?? '');
      if (gc != 0) {
        return gc;
      }

      final cc = (a.$2 ?? '').compareTo(b.$2 ?? '');
      if (cc != 0) {
        return cc;
      }

      final lc = (a.$3 ?? '').compareTo(b.$3 ?? '');
      if (lc != 0) {
        return lc;
      }

      final ba = batches[a.$4 ?? ''];
      final bb = batches[b.$4 ?? ''];

      return (ba?.json['date'] ?? '').compareTo(bb?.json['date'] ?? '');
    });

    for (final key in keys) {
      final value = numbers[key];
      final qty = value.toString();
      // print("key ${entry.key} = $qty");

      final g = goods[key.$1 ?? ''];
      final b = batches[key.$4 ?? ''];

      String title = '${g?.name() ?? '?'}\n';
      if (key.$2 != null) {
        title += '${key.$2 ?? ''} ';
      }
      if (key.$3 != null) {
        title += '${key.$3 ?? ''} ';
      }
      if (title[title.length - 1] == ' ') {
        title += '\n';
      }
      title += b?.json['date'] ?? '';

      children.add(card(
        context,
        Text(title),
        Text(qty),
      ));
    }

    return children;
  }

  Widget card(BuildContext context, Widget title, Widget subtitle) {
    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: ListTile(
        contentPadding:
            // const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
        // leading: const Icon(Icons.account_circle),
        title: title,
        subtitle: subtitle,
      ),
    );
  }
}
