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
import 'package:nae/widgets/scrollable_list_view.dart';

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

    // print("doc: ${doc.json}");

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

        print("bloc $bloc");

        return bloc;
      },
      child: BlocConsumer<MemoryBloc, RequestState>(
        listener: (context, state) {
          // do stuff here based on BlocA's state
        },
        builder: (context, state) => Column(children: <Widget>[
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
    final localization = AppLocalizations.of(context);

    var children = <Widget>[];

    print('buildItemsList $data');

    if (data.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.all(5),
        child: Text(localization.translate(label), textAlign: TextAlign.right),
      ));
    }

    for (final item in data) {
      print("item $item");
      final value = Qty.fromJson(item['qty']).toString();

      children.add(KeyValue(
        label: item['goods']?.name() ?? '',
        value: value,
        icon: const Icon(Icons.question_mark),
      ));
    }

    return children;
  }
}
