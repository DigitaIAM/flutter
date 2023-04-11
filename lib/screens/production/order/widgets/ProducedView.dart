import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nae/api.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/swipe_action.dart';

import 'ProducedEdit.dart';

class POProducedView extends StatelessWidget {
  final MemoryItem order;

  const POProducedView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final ctx = ['production', 'produce'];
    final schema = [
      const Field('qty', NumberType()),
      Field('code', CalculatedType((MemoryItem bag) async {
        return bag.id.split('T').last;
      }))
    ];
    final filter = {'order': order.id};
    return BlocProvider(
      create: (context) => MemoryBloc()..add(MemoryFetch('memories', ctx, schema: schema, filter: filter)),
      child: MemoryList(
        ctx: ctx,
        schema: schema,
        filter: filter,
        title: (MemoryItem item) => Text(item.json['qty']),
        subtitle: (MemoryItem item) => Text(item.id.split('T').last),
        // onTap: (MemoryItem item) => {},
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
            onPressed: (context, item) => chooseAndPrint(context, item),
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
          title: Text(printer['name'] ?? ''),
          onTap: () => POProducedEdit.printing(printer, order, doc, (newStatus) {}),
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
