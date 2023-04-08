import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nae/api.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/printing.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/wh/transfer/screen.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/swipe_action.dart';

class WHTransferGoods extends StatelessWidget {
  final MemoryItem doc;

  const WHTransferGoods({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final ctx = const ['warehouse', 'transfer'];
    final filter = {
      'document': doc.id,
    };
    final schema = <Field>[
      fGoods.copyWith(width: 3.0),
      // fUomAtQty.copyWith(width: 0.5, editable: false),
      fQty.copyWith(width: 1.0),
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
        ctx: ctx,
        filter: filter,
        schema: schema,
        title: (MemoryItem item) {
          final text = fGoods.resolve(item.json)?.name() ?? '';

          TextStyle? style;

          if (item.json['_status'] == 'deleted') {
            style = const TextStyle(
              decoration: TextDecoration.lineThrough,
            );
          }
          return Text(text, style: style);
        },
        subtitle: (MemoryItem item) {
          print("item.json ${item.json}");

          var text = '';

          var qty = item.json['qty'] ?? '';

          while (qty is Map) {
            final uom = qty['uom'];
            if (uom is Map) {
              if (uom['in'] is Map) {
                text = '$text${qty['number']} ${uom['in']['name']} по ';
              } else {
                text = '$text${qty['number']} ${uom['name']} ';
              }
            }
            qty = qty['uom'];
          }

          TextStyle? style;

          if (item.json['_status'] == 'deleted') {
            style = const TextStyle(
              decoration: TextDecoration.lineThrough,
            );
          }
          return Text(text, style: style);
        },
        onTap: (MemoryItem item) => context
            .read<UiBloc>()
            .add(ChangeView(WHTransfer.ctx, entity: item)),
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
    const ctx = ['warehouse', 'transfer'];
    final status = item.json['_status'] == 'deleted' ? 'restored' : 'deleted';
    final Map<String, dynamic> data = {'_status': status};
    context.read<MemoryBloc>().add(MemoryPatch('memories', ctx, item.id, data));
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

    print("printers ${response.runtimeType} ${response}");

    final printers = response['data'];

    final children = <Widget>[];

    children.add(Text("Choose the printer"));

    if (printers is List) {
      for (var printer in printers) {
        final ip = (printer['ip'] ?? '').toString();
        final port = int.parse(printer['port'] ?? '0');
        children.add(ListTile(
            title: Text(printer['name'] ?? ''),
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
    print("printPreparation: ${item.json}");

    final _doc = await doc.enrich(WHTransfer.schema);

    final result = await Labels.connect(ip, port, (printer) async {
      return await printing(printer, _doc, item, (newStatus) => {});
    });

    print("printResult: $result");
  }
}
