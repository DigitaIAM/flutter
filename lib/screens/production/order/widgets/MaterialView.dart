import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/printer/printing.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/production/order/screen.dart';
import 'package:nae/screens/wh/goods_dispatch.dart';
import 'package:nae/screens/wh/goods_registration.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/swipe_action.dart';

class MaterialView extends StatefulWidget {
  final MemoryItem order;

  const MaterialView({super.key, required this.order});

  @override
  State<StatefulWidget> createState() => _MaterialViewState();
}

class _MaterialViewState extends State<MaterialView> {
  bool openUsed = false;
  bool openProduced = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context);

    final filter = {cDocument: widget.order.id};

    return Column(
      children: <Widget>[
        const SizedBox(height: 10),
        Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            // leading: const Icon(Icons.account_circle),
            tileColor: theme.secondaryHeaderColor,
            title: Text(localization.translate("used raw material")),
            trailing: openUsed
                ? const Icon(Icons.arrow_drop_down)
                : const Icon(Icons.arrow_right),
            onTap: () {
              setState(() {
                openUsed = !openUsed;
                openProduced = false;
              });
            },
          ),
        ),
        if (openUsed) buildList(['production', 'material', 'used'], filter),
        Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            // leading: const Icon(Icons.account_circle),
            tileColor: theme.secondaryHeaderColor,
            title: Text(
              localization.translate("produced raw material"),
              style: theme.textTheme.bodyLarge,
            ),
            trailing: openProduced
                ? const Icon(Icons.arrow_drop_down)
                : const Icon(Icons.arrow_right),
            onTap: () {
              setState(() {
                openProduced = !openProduced;
                openUsed = false;
              });
            },
          ),
        ),
        if (openProduced)
          buildList(['production', 'material', 'produced'], filter),
      ],
    );
  }

  Widget buildList(List<String> ctx, Map<String, dynamic> filter) {
    List<Field> schema = [
      const Field('storage_from', ReferenceType([cWarehouse, cStorage])),
      const Field('storage_into', ReferenceType([cWarehouse, cStorage])),
      fStorage,
      fCategoryAtGoods,
      fGoods,
      fQtyNew
    ];
    return Expanded(
      child: BlocProvider(
        create: (context) => MemoryBloc(schema: schema)
          ..add(MemoryFetch('memories', ctx, schema: schema, filter: filter)),
        child: MemoryList(
          mode: Mode.mobile,
          ctx: ctx,
          schema: schema,
          filter: filter,
          title: (MemoryItem item) {
            final text = fGoods.resolve(item.json)?.name() ?? '';

            TextStyle? style;

            if (item.json[cStatus] == 'deleted') {
              style = const TextStyle(
                decoration: TextDecoration.lineThrough,
              );
            }

            return Text(text, style: style);
          },
          subtitle: (MemoryItem item) {
            TextStyle? style;

            if (item.json[cStatus] == 'deleted') {
              style = const TextStyle(
                decoration: TextDecoration.lineThrough,
              );
            }

            var storage = item.json[cStorage]?.name();
            if (item[cStorage]?.isEmpty) {
              storage = item['storage_from']?.name() ?? '';
              if (listEquals(ctx, ['production', 'material', 'produced'])) {
                storage = item['storage_into']?.name() ?? '';
              }

              if ((item['storage_from']?.isNotEmpty ?? false) ||
                  (item['storage_into']?.isNotEmpty ?? false)) {
                storage += ' ⚠ ';
              }
            }

            String dateBatch = item.json['batch']?['date'] ?? '';
            final qty = item.json['qty'].toString();
            var text = '$qty, $storage';
            if (dateBatch.isNotEmpty) {
              text += ', $dateBatch';
            }

            return Text(text, style: style);
          },
          onDoubleTap: (context, item) {
            editItem(context, ctx, widget.order, item);
          },
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
            ItemAction(
              label: 'edit',
              icon: Icons.edit,
              onPressed: (context, item) =>
                  editItem(context, ctx, widget.order, item),
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  void deleteItem(BuildContext context, MemoryItem item) async {
    List<String> ctx = [];
    if (openUsed) {
      ctx = ['production', 'material', 'used'];
    } else if (openProduced) {
      ctx = ['production', 'material', 'produced'];
    }
    final status = item.json[cStatus] == 'deleted' ? 'restored' : 'deleted';
    final Map<String, dynamic> data = {cStatus: status};
    // TODO fix schema
    context
        .read<MemoryBloc>()
        .add(MemoryPatch('memories', ctx, const [], item.id, data));
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
                (printer) async =>
                    printing(printer, widget.order, doc, (newStatus) {}));

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

  void editItem(BuildContext context, List<String> ctx, MemoryItem doc,
      MemoryItem item) async {
    // print("editItem ${item.json}");

    Map<String, dynamic> data = Map.from(item.json);

    if (item[cStorage]?.isEmpty) {
      if (listEquals(ctx, ['production', 'material', 'produced'])) {
        data[cStorage] = item['storage_into'];
      } else if (listEquals(ctx, ['production', 'material', 'used'])) {
        data[cStorage] = item['storage_from'];
      }
    }

    bool receive = true;
    if (listEquals(ctx, ['production', 'material', 'produced'])) {
      receive = true;
    } else if (listEquals(ctx, ['production', 'material', 'used'])) {
      data[cCategory] = data[cGoods].json[cCategory];
      data[cBatch] = item[cBatch];
      receive = false;
    }

    (item.json['qty'] as Qty).toData(data);

    final uiBloc = context.read<UiBloc>();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => BlocProvider(
        create: (ctx) => UiBloc(uiBloc.state),
        child: Dialog(
          child: SizedBox(
            width: 500,
            height: 500,
            child: Column(children: [
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: SizedBox(
                    width: 500,
                    height: 400,
                    child: Column(children: [
                      Expanded(
                        child: receive
                            ? GoodsRegistration(
                                ctx: const [
                                  'production',
                                  'material',
                                  'produced'
                                ],
                                doc: doc,
                                rec: MemoryItem.from(data),
                                schema: const [fStorage, fGoods, fQty],
                                enablePrinting: false,
                                allowGoodsCreation: false,
                                afterSave: () {
                                  setState(() {
                                    openProduced = false;
                                    openUsed = false;
                                  });
                                  Navigator.pop(context);
                                },
                              )
                            : GoodsDispatch(
                                ctx: const ['production', 'material', 'used'],
                                doc: doc,
                                rec: MemoryItem.from(data),
                                schema: ProductionOrder.schema,
                                enablePrinting: false,
                                afterSave: () {
                                  setState(() {
                                    openProduced = false;
                                    openUsed = false;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                      )
                    ])),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
