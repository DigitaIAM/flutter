import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nae/api.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/printing.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/wh/dispatch/screen.dart';
import 'package:nae/screens/wh/return/screen.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/swipe_action.dart';

class WHReturnGoods extends StatefulWidget {
  final MemoryItem doc;
  final Mode mode;

  const WHReturnGoods({super.key, required this.doc, this.mode = Mode.auto});

  @override
  State<StatefulWidget> createState() => _WHReturnGoods();
}

class _WHReturnGoods extends State<WHReturnGoods> {
  static const ctx = WHReturn.ctx;

  @override
  Widget build(BuildContext context) {
    final filter = {
      cDocument: widget.doc.id,
    };
    final schema = <Field>[
      fGoods.copyWith(width: 3.0),
      fCategoryAtGoods,
      // fUomAtQty.copyWith(width: 0.5, editable: false),
      fQtyNew.copyWith(width: 1.0),
      fBatchDocument,
    ];

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
      child: MemoryList(
        mode: widget.mode,
        ctx: ctx,
        filter: filter,
        schema: schema,
        title: (MemoryItem item) {
          print('item ${item.json}');

          var text = fGoods.resolve(item.json)?.name() ?? '';

          final batchDetails = item.json[cBatchDetails];
          final customer = batchDetails['customer'];
          final label = batchDetails['label'];

          var additionalBatchDetails = '';
          if (customer != null) {
            additionalBatchDetails += customer;
            if (label != null) {
              additionalBatchDetails += ', $label';
            }
          } else if (label != null) {
            additionalBatchDetails += label;
          }

          if (additionalBatchDetails.isNotEmpty) {
            text = text + '\n' + additionalBatchDetails;
          }

          TextStyle? style;

          if (item.json[cStatus] == 'deleted') {
            style = const TextStyle(
              decoration: TextDecoration.lineThrough,
            );
          }
          return Text(text, style: style);
        },
        subtitle: (MemoryItem item) {
          print("subtitle ${item.json}");

          String dateBatch = item.json['batch']?['date'] ?? '';
          final qty = item.json['qty'].toString();

          var text = '$qty ';
          if (dateBatch.isNotEmpty) {
            text += ', $dateBatch';
          }

          TextStyle? style;

          if (item.json[cStatus] == 'deleted') {
            style = const TextStyle(
              decoration: TextDecoration.lineThrough,
            );
          }
          return Text(text, style: style);
        },
        // onTap: (MemoryItem item) => context
        //     .read<UiBloc>()
        //     .add(ChangeView(WHTransfer.ctx, entity: item)),
        actions: [
          ItemAction(
            label: 'delete',
            icon: Icons.delete_outline,
            onPressed: (context, item) => deleteItem(context, item),
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
          ),
          ItemAction(
            label: 'print',
            icon: Icons.print_outlined,
            onPressed: (context, item) => drawPrinterList(context, item),
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  void deleteItem(BuildContext context, MemoryItem item) async {
    final status = item.json[cStatus] == 'deleted' ? 'restored' : 'deleted';
    final Map<String, dynamic> data = {cStatus: status};
    // TODO fix schema
    context
        .read<MemoryBloc>()
        .add(MemoryPatch('memories', ctx, const [], item.id, data));
  }

  Future drawPrinterList(BuildContext context, MemoryItem item) async {
    final list = await getPrinters(item);

    return showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: list,
      ),
    );
  }

  Future<Widget> getPrinters(MemoryItem item) async {
    final response = await Api.feathers().find(serviceName: "memories", query: {
      "oid": Api.instance.oid,
      "ctx": const ['printer'],
    });

    // print("printers ${response.runtimeType} ${response}");

    final printers = response['data'];

    final children = <Widget>[];

    children.add(const Text("Choose the printer"));

    if (printers is List) {
      for (var printer in printers) {
        final ip = (printer['ip'] ?? '').toString();
        final port = int.parse(printer['port'] ?? '0');
        children.add(ListTile(
            title: Text(printer[cName] ?? ''),
            onTap: () => printPreparation(ip, port, item)));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  void printPreparation(String ip, int port, MemoryItem item) async {
    // print("printPreparation: ${item.json}");

    final _doc = await widget.doc.enrich(WHDispatch.schema);

    final result = await Labels.connect(ip, port, (printer) async {
      return await printing(printer, _doc, item, (newStatus) => {});
    });

    // print("printResult: $result");
  }
}
