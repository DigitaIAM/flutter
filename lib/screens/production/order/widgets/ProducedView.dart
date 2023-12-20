import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nae/api.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/swipe_action.dart';

import 'ProducedEdit.dart';

class POProducedView extends StatefulWidget {
  final MemoryItem order;

  const POProducedView({super.key, required this.order});

  @override
  State<StatefulWidget> createState() => _POProducedViewState();
}

class _POProducedViewState extends State<POProducedView> {
  MemoryItem? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ctx = ['production', 'produce'];
    final schema = [
      const Field(cQty, NumberType()),
      Field('code', CalculatedType((MemoryItem bag) async {
        return bag.id.split('T').last;
      }))
    ];
    final filter = {cDocument: widget.order.id};

    final date = DateTime.parse(widget.order.json[cDate]).toLocal();
    final formatter = NumberFormat("00");

    return BlocProvider(
      create: (context) =>
          MemoryBloc(schema: schema)..add(MemoryFetch('memories', ctx, schema: schema, filter: filter, loadAll: true)),
      child: BlocBuilder<MemoryBloc, RequestState>(builder: (context, state) {
        if (state.status == RequestStatus.initiate) {
          return const Center(child: Text('loading...'));
        } else if (state.status == RequestStatus.failure) {
          return const Center(child: Text('error!'));
        } else {
          final groups = <MemoryItem>{};
          Map<MemoryItem, List<MemoryItem>> items = {};
          for (final item in state.items) {
            var id = item.id;
            id = id.substring(id.length - 24, id.length);

            final current = DateTime.parse(id).toLocal();
            id = '${current.year}-${current.month}-${current.day}T${current.hour}';

            var name = '${formatter.format(current.hour)}-${formatter.format(current.hour + 1)} час';
            if (current.hour + 1 > 24) {
              name = '${formatter.format(current.hour)}-01 час';
            }

            if (current.year != date.year) {
              name = '${DateFormat.yMMMMd().format(current)} $name';
            } else if (current.month != date.month) {
              name = '${DateFormat.MMMMd().format(current)} $name';
            } else if (current.day != date.day) {
              name = '${DateFormat.MMMMd().format(current)} $name';
            }

            final group = MemoryItem(id: id, json: {cId: id, cName: name});
            groups.add(group);

            final list = items[group] ?? [];
            list.add(item);
            items[group] = list;
          }

          return SingleChildScrollView(
            child: Column(children: <Widget>[
              ...groups.map((g) {
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                  child: Column(children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      // leading: const Icon(Icons.account_circle),
                      tileColor: theme.secondaryHeaderColor,
                      title: Text(g.name()),
                      trailing: selected == g ? const Icon(Icons.arrow_drop_down) : const Icon(Icons.arrow_right),
                      onTap: () {
                        setState(() {
                          if (selected == g) {
                            selected = null;
                          } else {
                            selected = g;
                          }
                        });
                      },
                    ),
                    if (selected == g && items[selected] != null)
                      SizedBox(
                        height: 300,
                        child: ListView(
                          children:
                              (items[selected] as List<MemoryItem>).map((item) => buildItem(item, theme)).toList(),
                        ),
                      )
                  ]),
                );
              })
            ]),
          );
        }
      }),
    );
  }

  Widget buildItem(MemoryItem item, ThemeData theme) {
    final tile = ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      leading: const Icon(Icons.catching_pokemon_outlined),
      // title: Text(item.json[cQty].toString()),
      title: Text('${item.json[cQty]?[cUom]?[cNumber].toString() ?? ''} ${item.json['customer'] ?? ''} ${item.json['label'] ?? ''}'),
      subtitle: Text(item.id.split('T').last),
      // trailing: const Icon(Icons.arrow_right),
      // openUsed ? const Icon(Icons.arrow_drop_down) : const Icon(Icons.arrow_right),
      onTap: () {
        // setState(() {
        //   openUsed = !openUsed;
        //   openProduced = false;
        // });
      },
    );

    final actions = [
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
    ];

    return SwipeActionWidget(
      item: item,
      actions: actions,
      // key: key,
      child: tile,
    );
  }

  void deleteItem(BuildContext context, MemoryItem item) async {
    const ctx = ['production', 'produce'];
    final status = item.json[cStatus] == 'deleted' ? 'restored' : 'deleted';
    final Map<String, dynamic> data = {cStatus: status};
    // TODO fix schema
    context.read<MemoryBloc>().add(MemoryPatch('memories', ctx, const [], item.id, data));
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
      "ctx": const [cPrinter],
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

            final result = await Labels.connect(ip, port,
                (printer) async => POProducedEdit.printingProduce(printer, widget.order, doc, (newStatus) {}));

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
