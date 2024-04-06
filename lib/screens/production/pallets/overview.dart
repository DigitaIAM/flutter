import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
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
    final isOpen = doc['packed_at'] == null;

    final widget = Column(children: <Widget>[
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
      if (isOpen != false)
        KeyValue(
          label: 'дата и время упаковки',
          value: doc.json['packed_at'] ?? '-',
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
                  )))),
      Expanded(child: goodsDetails()),
    ]);

    return Scaffold(
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          heroTag: 'pallets_register_and_print',
          backgroundColor: theme.primaryColorDark,
          onPressed: () {
            chooseAndPrint(context, doc);
          },
          tooltip: localization.translate('print'.toString()),
          child: Icon(
            Icons.print,
            color: theme.primaryColorLight,
          ),
        ),
      ),
      body: widget,
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
          return card(context, item);
        });
  }

  Widget card(BuildContext context, MemoryItem item) {
    // print("item ${item.json}");
    return InkWell(
      onDoubleTap: () {},
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

  Future chooseAndPrint(BuildContext context, MemoryItem doc) async {
    final list = await getPrinters(doc);

    return showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: list,
      ),
    );
  }

  Future<Widget> getPrinters(MemoryItem doc) async {
    final response = await Api.feathers().find(serviceName: "memories", query: {
      "oid": Api.instance.oid,
      "ctx": const ['printer'],
    });

    // print("printers ${response.runtimeType} ${response}");

    final printers = response['data'];

    final children = <Widget>[];

    children.add(const Text("Choose printer"));

    if (printers is List) {
      for (var printer in printers) {
        children.add(ListTile(
          title: Text(printer[cName] ?? ''),
          onTap: () async {
            final ip = printer['ip'];
            final port = int.parse(printer['port']);

            final result = await Labels.connect(
              ip,
              port,
              (printer) async => validateAndPrint(printer, doc),
            );

            if (result != PrintResult.success) {
              showToast(result.msg,
                  // context: context,
                  axis: Axis.horizontal,
                  alignment: Alignment.center,
                  position: StyledToastPosition.bottom);
            }
          },
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

Future<PrintResult> validateAndPrint(
  NetworkPrinter printer,
  MemoryItem d,
) async {
  try {
    // request data from server
    final doc = await Api.feathers()
        .get(serviceName: 'memories', objectId: d.id, params: {
      'oid': Api.instance.oid,
      'ctx': PalletPacking.ctx,
    });
    //print("doc $doc");

    final lines = await Api.feathers().find(serviceName: 'memories', query: {
      'oid': Api.instance.oid,
      'ctx': PalletPacking.ctxOfDispatch,
      '\$skip': 0,
      '\$limit': 20,
      'filter': {
        cDocument: d.id,
      }
    });
    //print("lines $lines");

    // aggregation
    Map<String, Qty> sums = {};
    Map<String, dynamic> list = {};

    for (final item in lines['data']) {
      // print("item $item");
      final goods = item['goods'];
      final goodsId = goods['_id'];

      final qty = Qty.fromJson(item['qty']);

      sums[goodsId] = (sums[goodsId] ?? Qty.zero()) + qty;

      list[goodsId] = goods;
    }

    // validation
    if (sums.length == 1) {
      for (final entry in sums.entries) {
        final goods = list[entry.key];
        final qty = entry.value;
        if (qty.nums.length == 1) {
          var packedAt = doc['packed_at'];
          if (packedAt == null) {
            // update document with packed_at
            final updatedDoc = await Api.feathers().patch(
              serviceName: 'memories',
              objectId: d.id,
              data: {'packed_at': DateTime.now().toIso8601StringWithTz()},
              params: {
                'oid': Api.instance.oid,
                'ctx': PalletPacking.ctx,
              },
            );

            packedAt = updatedDoc['packed_at'];
          }

          // print label
          final productName = goods['name'];
          final goodsUuid = goods['_uuid'];
          final recordId = doc['_id'];
          final batchId = doc['_uuid'];
          final batchDate = packedAt;
          final batchBarcode = '';

          final Map<String, String> labelData = {
            "продукция": productName,
            // "артикул": '', // partNumber,
            "дата": doc['date'],
            "количество": qty.toString(),
            // "line1": "",
            // "оператор": operatorName,
          };

          Labels.linesWithBarcode(printer, goodsUuid, recordId, batchBarcode,
              batchId, batchDate, labelData);

          // TODO context.read<UiBloc>().add(ChangeView(PalletPacking.ctx));
        }
      }
    } else {
      // TODO show error message
    }
  } catch (e, stacktrace) {
    print("ERROR _onFetched:");
    print(e);
    print(stacktrace);
  }

  return PrintResult.success;
}
