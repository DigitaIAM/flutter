import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/list_divider.dart';

class WHTransferOverview extends StatelessWidget {
  final MemoryItem doc;

  const WHTransferOverview({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    print("context in WHTransferOverview: $context");

    final localization = AppLocalizations.of(context);

    final ctx = const ['warehouse', 'transfer'];
    final filter = {
      'document': doc.id,
    };
    final schema = <Field>[
      fGoods.copyWith(width: 3.0),
      fUomAtQty.copyWith(width: 0.5, editable: false),
      fQty.copyWith(width: 1.0),
    ];

    // print("WHTransferOverview doc: $doc");

    final from = doc.json['from'] is MemoryItem
        ? doc.json['from'].name()
        : doc.json['from'];
    final into = doc.json['into'] is MemoryItem
        ? doc.json['into'].name()
        : doc.json['into'];

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
        ListDivider(),
        ListTile(
          title: Text(doc.json['date']),
          subtitle: Text(localization.translate("date")),
        ),
        ListTile(
          title: Text(from),
          subtitle: Text(localization.translate("from")),
        ),
        ListTile(
          title: Text(into),
          subtitle: Text(localization.translate("into")),
        ),
        ListDivider(),
      ]),
    );
  }
}
