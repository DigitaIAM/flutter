import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/key_value.dart';

class WHDispatchOverview extends StatelessWidget {
  final MemoryItem doc;

  const WHDispatchOverview({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    // print("context in WHDispatchOverview: $context");

    final localization = AppLocalizations.of(context);

    const ctx = ['warehouse', 'dispatch'];
    final filter = {
      cDocument: doc.id,
    };
    final schema = <Field>[
      fGoods.copyWith(width: 3.0),
      fUomAtQty.copyWith(width: 0.5, editable: false),
      fQty.copyWith(width: 1.0),
    ];

    // print("WHTransferOverview doc: $doc");

    final storage = doc.json[cStorage] is MemoryItem ? doc.json[cStorage].name() : doc.json[cStorage][cName] ?? '';
    final counterparty =
        doc.json[cCounterparty] is MemoryItem ? doc.json[cCounterparty].name() : doc.json[cCounterparty][cName] ?? '';

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

        return bloc;
      },
      child: Column(children: <Widget>[
        KeyValue(
          label: localization.translate(cDate),
          value: DT.format(doc.json[cDate]),
          icon: const Icon(Icons.calendar_month),
        ),
        KeyValue(
          label: localization.translate(cStorage),
          value: storage,
          icon: const Icon(Icons.output),
        ),
        KeyValue(
          label: localization.translate(cCounterparty),
          value: counterparty,
          icon: const Icon(Icons.input),
        ),
      ]),
    );
  }
}
