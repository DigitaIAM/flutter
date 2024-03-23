import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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
import 'package:nae/printer/printing.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/wh/goods_dispatch.dart';
import 'package:nae/screens/wh/inventory/screen.dart';
import 'package:nae/screens/wh/receive/screen.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/swipe_action.dart';

class WHInventoryGoods extends StatefulWidget {
  final MemoryItem doc;
  final Mode mode;

  const WHInventoryGoods({super.key, required this.doc, this.mode = Mode.auto});

  @override
  State<StatefulWidget> createState() => _WHInventoryGoodsState();
}

class _WHInventoryGoodsState extends State<WHInventoryGoods> {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_WHInventoryGoodsState');

  final FocusScopeNode _focusNode = FocusScopeNode();

  void _onSave(BuildContext context) {
    final state = _formKey.currentState;
    if (state != null && state.saveAndValidate()) {
      debugPrint('new data');
      debugPrint(_formKey.currentState?.value.toString());

      final Map<String, dynamic> data = Map.from(state.value);
      // workaround
      data[cId] = widget.doc.id;

      context.read<MemoryBloc>().add(MemorySave("memories", WHInventory.ctx,
          WHInventory.schema, MemoryItem(id: widget.doc.id, json: data)));
    } else {
      debugPrint(_formKey.currentState?.value.toString());
      debugPrint('validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    const ctx = ['warehouse', 'inventory'];
    final filter = {
      cDocument: widget.doc.id,
    };
    final schema = <Field>[
      fCategoryAtGoods,
      fGoods.copyWith(width: 3.0),
      // fUomAtQty.copyWith(width: 0.5, editable: false),
      fQtyNew.copyWith(width: 1.0),
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
        onDoubleTap: (context, item) {
          editItem(context, ctx, widget.doc, item);
        },
        //onTap: (context, MemoryItem item) => popUpPatch(context, item),
        // context.read<UiBloc>().add(ChangeView(WHReceive.ctx, entity: item)),
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
          ItemAction(
            label: 'edit',
            icon: Icons.edit,
            onPressed: (context, item) =>
                editItem(context, ctx, widget.doc, item),
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }

  void deleteItem(BuildContext context, MemoryItem item) async {
    const ctx = ['warehouse', 'inventory'];
    final status = item.json[cStatus] == 'deleted' ? 'restored' : 'deleted';
    final Map<String, dynamic> data = {cStatus: status};
    // TODO fix schema
    context
        .read<MemoryBloc>()
        .add(MemoryPatch('memories', ctx, const [], item.id, data));
  }

  void editItem(BuildContext context, List<String> ctx, MemoryItem doc,
      MemoryItem item) async {
    //print("docu ${doc.json}");
    // print("item ${item.json}");

    Map<String, dynamic> data = {};

    data[cId] = item.id;
    data[cUuid] = item.uuid;
    data[cStorage] = doc.json[cStorage];
    data[cGoods] = item.json[cGoods];
    data[cCategory] = data[cGoods].json[cCategory];
    data[cBatch] =
    item.json[cBatch] == null ? null : MemoryItem.from(item.json[cBatch]);
    (item.json['qty'] as Qty).toData(data);

   // print("data $data");

    final uiBloc = context.read<UiBloc>();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          BlocProvider(
            create: (ctx) => UiBloc(uiBloc.state),
            child: Dialog(
              child: SizedBox(
                width: 500,
                height: 500,
                child: Column(
                  children: [
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
                        child: Column(
                          children: [
                            Expanded(
                              child: GoodsDispatch(
                                ctx: const ['warehouse', 'inventory'],
                                doc: widget.doc,
                                rec: MemoryItem.from(data),
                                schema: WHInventory.schema,
                                enablePrinting: false,
                                allowGoodsCreation: false,
                                afterSave: () {
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
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

    final d = await widget.doc.enrich(WHReceive.schema);

    await Labels.connect(ip, port, (printer) async {
      return await printing(printer, d, item, (newStatus) => {});
    });

    // print("printResult: $result");
  }

  Future popUpPatch(BuildContext context, MemoryItem record) {
    return showMaterialModalBottomSheet(
      context: context,
      builder: (ctx) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: enteringAmount(context, record),
      ),
    );
  }

  Widget enteringAmount(BuildContext context, MemoryItem record) {
    final localization = AppLocalizations.of(context);

    List<Widget> widgets = [];

    final MemoryItem details = MemoryItem(
        id: '', json: {cDate: Utils.today()}); // TODO input doc date?

    widgets.add(const Text('Enter the amount of goods:'));

    widgets.add(DecoratedFormField(
      name: cQty,
      label: localization.translate(cQty),
      autofocus: true,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
      ]),
      onSave: (context) => _onSave,
      keyboardType: TextInputType.number,
    ));

    widgets.add(Container(height: 10));

    widgets.add(
      ElevatedButton(
        onPressed: () => patchDocument(context, record),
        // onPressed: () => {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(localization.translate('register')),
      ),
    );

    return AppForm(
        entity: details,
        formKey: _formKey,
        focusNode: _focusNode,
        onChanged: () {
          _formKey.currentState!.save();
          debugPrint("onChanged: ${_formKey.currentState!.value}");
        },
        child: Column(children: widgets));
  }

  void patchDocument(BuildContext context, MemoryItem record) {
    final data = _formKey.currentState?.value;
    if (data == null) {
      return;
    }

    // print("data type ${data.runtimeType}");
    // print("inventory_data $data");
    // print("inventory_doc ${widget.doc.json}");

    final qty = data[cQty] ?? '';

    if (isNumeric(qty) == true) {
      // context.read<MemoryBloc>().add(MemoryCreate("memories", const [
      //       'warehouse',
      //       'inventory'
      //     ], const [], {
      //       cDocument: widget.doc.id,
      //       cGoods: record.id,
      //       cQty: {cNumber: qty}
      //     }));

      context.read<MemoryBloc>().add(MemoryPatch(
          "memories",
          const ['warehouse', 'inventory'],
          const [],
          record.id,
          {
            cQty: {cNumber: qty}
          }));
    } else {
      // print("Wrong value was entered");
    }
  }

  bool isNumeric(String str) {
    try {
      var value = double.parse(str);
    } on FormatException {
      return false;
    }

    return true;
  }
}
