import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/screens/wh/inventory/screen.dart';
import 'package:nae/screens/wh/list_builder.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class WHInventoryShowStock extends StatefulWidget {
  final MemoryItem doc;

  const WHInventoryShowStock({super.key, required this.doc});

  @override
  State<StatefulWidget> createState() => _WHInventoryShowStockState();
}

class _WHInventoryShowStockState extends State<WHInventoryShowStock> {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_WHInventoryShowStockState');

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
    final List<Pair> filters = [];

    final storage = widget.doc.json[cStorage] is MemoryItem
        ? widget.doc.json[cStorage] as MemoryItem
        : MemoryItem(
            id: widget.doc.json[cStorage][cId],
            json: widget.doc.json[cStorage]);

    final storageUuid = storage.json[cUuid] ?? '';

    filters.add(Pair(cStorage, storage));

    //print("doc: ${widget.doc.json}");
    // print("storage: ${storage.json}");

    final docFilter = {cDocument: widget.doc.id};
    final storageFilter = {cStorage: storageUuid};

    return BlocProvider(
      create: (context) => MemoryBloc(),
      child:
          BlocBuilder<MemoryBloc, RequestState>(builder: (context, stockState) {
        context.read<MemoryBloc>().add(MemoryFetch(
            'memories', const ['warehouse', 'stock'],
            schema: WHInventory.schema, filter: storageFilter));
        return BlocProvider(
          create: (context) => MemoryBloc(),
          child: BlocBuilder<MemoryBloc, RequestState>(
            builder: (context, linesState) {
              context.read<MemoryBloc>().add(MemoryFetch(
                  'memories', const ['warehouse', 'inventory'],
                  schema: WHInventory.schema, filter: docFilter));

              final stock = stockState.items;
              final lines = linesState.items;

              // print("stock: $stock");
              // print("lines: $lines");

              List<MemoryItem> todo = stock.toList();

              for (final s in stock) {
                // print("s name: ${s.json[cName]}");
                for (final line in lines) {
                  // print("line name: ${line.json}");
                  if (s.json[cName] == line.json[cGoods][cName]) {
                    todo.remove(s);
                    break;
                  }
                }
              }

              // print("todo: $todo");

              List<Widget> todoList = [];

              for (final record in todo) {
                // print("record: ${record.json}");
                todoList.add(Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 5.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    // leading: const Icon(Icons.account_circle),
                    title: Text(record.json[cName] ?? ''),
                    subtitle: Text(
                        '${record.json['_cost'][cQty] ?? ''} ${record.json[cUom][cName] ?? ''}, '
                        '${record.json['_cost'][cCost] ?? ''} сум'),
                    // trailing: widget.onTap == null ? null : const Icon(Icons.arrow_forward),
                    onTap: () => popUpRegister(context, record),
                  ),
                ));
              }

              return ScrollableListView(children: todoList);
            },
          ),
        );
      }),
    );
  }

  Future popUpRegister(BuildContext context, MemoryItem record) {
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
        onPressed: () => registerDocument(context, record),
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

  void registerDocument(BuildContext context, MemoryItem record) {
    final data = _formKey.currentState?.value;
    if (data == null) {
      return;
    }

    // print("data type ${data.runtimeType}");
    // print("inventory_data $data");
    // print("inventory_doc ${widget.doc.json}");

    final qty = data[cQty] ?? '';

    if (isNumeric(qty) == true) {
      context.read<MemoryBloc>().add(MemoryCreate("memories", const [
            cWarehouse,
            'inventory'
          ], const [], {
            cDocument: widget.doc.id,
            cGoods: record.id,
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
