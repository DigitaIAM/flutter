import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/printer/printing.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class GoodsDispatch extends StatefulWidget {
  final List<String> ctx;
  final MemoryItem doc;
  final MemoryItem? rec;
  final List<Field> schema;
  final bool enablePrinting;
  final MemoryItem? storage;
  final bool storageEditable;

  final Function()? afterSave;

  const GoodsDispatch({
    super.key,
    required this.ctx,
    required this.doc,
    this.rec,
    required this.schema,
    this.enablePrinting = true,
    this.afterSave,
    this.storage,
    this.storageEditable = true,
  });

  @override
  State<StatefulWidget> createState() => _GoodsDispatchState();
}

class _GoodsDispatchState extends State<GoodsDispatch> {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_goodsDispatchEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  late MemoryItem details;

  String status = "register";
  String registered = '';

  List<dynamic> items = [];

  bool showCategory = false;
  bool showGoods = false;
  bool showBatch = false;
  bool showQtyUom = false;
  // bool showStorage = false;

  @override
  void initState() {
    super.initState();

    if (widget.rec == null) {
      if (widget.storage == null) {
        details = MemoryItem(id: '', json: {
          cDate: Utils.today(),
        });
      } else {
        details = MemoryItem(id: '', json: {
          cDate: Utils.today(),
          cStorage: widget.storage,
        });
      }
    } else {
      details = widget.rec!;

      showCategory = details.json[cCategory] != null;
      showGoods = details.json[cGoods] != null;
      showBatch = details.json[cBatch] != null;
      showQtyUom = details.json['uom_0'] != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final widgets = <Widget>[
      if (status != 'register')
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(status),
            ]),
      AppForm(
        entity: details,
        formKey: _formKey,
        focusNode: _focusNode,
        onChanged: () {
          final state = _formKey.currentState;
          if (state == null) {
            return;
          }
          state.save();
          var value = state.value;
          debugPrint("onChanged: $value");

          if (value[cStorage] == null) {
            state.removeInternalFieldValue(cCategory);
            state.removeInternalFieldValue(cGoods);
            state.removeInternalFieldValue(cBatch);
            state.removeInternalFieldValue('uom_0');
            state.removeInternalFieldValue('qty_0');
          }

          if (value[cCategory] == null) {
            state.removeInternalFieldValue(cGoods);
            state.removeInternalFieldValue(cBatch);
            state.removeInternalFieldValue('uom_0');
            state.removeInternalFieldValue('qty_0');
          }

          if (value[cGoods] == null) {
            state.removeInternalFieldValue(cBatch);
            state.removeInternalFieldValue('uom_0');
            state.removeInternalFieldValue('qty_0');
          }

          if (value[cBatch] == null) {
            state.removeInternalFieldValue('uom_0');
            state.removeInternalFieldValue('qty_0');
          }
          state.save();

          setState(() {
            showCategory = value[cCategory] != null;
            showGoods = value[cGoods] != null;
            showBatch = value[cBatch] != null;
            showQtyUom = value['uom_0'] != null;
          });

          // final storage = value[cStorage];
          // if (storage is MemoryItem) {
          //   setState(() {});
          // }
        },
        child: FormCard(isLast: true, children: <Widget>[
          if (widget.enablePrinting)
            DecoratedFormPickerField(
              creatable: false,
              ctx: const ['printer'],
              name: cPrinter,
              label: localization.translate(cPrinter),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                // FormBuilderValidators.required(),
              ]),
              onSave: (context) {},
            ),
          const SizedBox(height: 10),
          DecoratedFormPickerField(
            ctx: const ['warehouse', 'storage'],
            name: cStorage,
            label: localization.translate(cStorage),
            creatable: false,
            editable: widget.storageEditable,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                  errorText: "выберите место хранения"),
            ]),
            onSave: (context) {},
          ),
          const SizedBox(height: 10),
          DecoratedFormPickerField(
            ctx: const ['goods', 'category'],
            name: cCategory,
            label: localization.translate(cCategory),
            creatable: false,
            validator: FormBuilderValidators.compose([
              // FormBuilderValidators.required(errorText: "выберите категорию"),
            ]),
            onSave: (context) {},
            //editable: false,
            visible: showCategory,
          ),
          const SizedBox(height: 10),
          DecoratedFormPickerField(
            ctx: const [cGoods],
            name: cGoods,
            label: localization.translate(cGoods),
            creatable: false,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: "выберите товар"),
            ]),
            onSave: (context) {},
            //editable: false,
            visible: showGoods,
          ),
          DecoratedFormPickerField(
            ctx: const ['goods', 'stock'],
            name: cBatch,
            label: localization.translate(cBatch),
            creatable: false,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: "выберите партию"),
            ]),
            onSave: (context) {},
            //editable: false,
            visible: showBatch,
          ),
          const SizedBox(height: 10),
          ...qtyUom(context),
          ...goodsList(),
        ]),
      ),
    ];

    return Scaffold(
      floatingActionButton: Stack(
        children: <Widget>[
          if (widget.enablePrinting) ...[
            Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  heroTag: 'product_register_and_print',
                  backgroundColor: theme.primaryColorDark,
                  onPressed:
                      status == 'register' ? registerAndPrintPreparation : null,
                  tooltip: localization.translate('and print'.toString()),
                  child: registered == 'registerAndPrint'
                      ? const Icon(Icons.done)
                      : Icon(
                          Icons.print,
                          color: theme.primaryColorLight,
                        ),
                )),
          ] else
            ...[],
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: 'product_register',
              backgroundColor: theme.primaryColorDark,
              onPressed: status == 'register' ? registerPreparation : null,
              tooltip: localization.translate('register'.toString()),
              child: registered == 'register'
                  ? const Icon(Icons.done)
                  : widget.rec == null
                      ? Icon(
                          Icons.add,
                          color: theme.primaryColorLight,
                        )
                      : Icon(
                          Icons.edit,
                          color: theme.primaryColorLight,
                        ),
            ),
          ),
        ],
      ),
      body: ScrollableListView(
        children: widgets,
      ),
    );
  }

  List<Widget> goodsList() {
    dynamic storage;

    final state = _formKey.currentState;
    if (state == null) {
      storage = details.json[cStorage];
      if (storage == null) {
        return <Widget>[];
      }
    } else {
      storage = state.value[cStorage];
    }

    final category = state?.value[cCategory];
    final goods = state?.value[cGoods];
    final batch = state?.value[cBatch];

    if (items.isNotEmpty) {
      return <Widget>[
        SizedBox(
            height: 350,
            child: ItemsListBuilder(
              items: items,
              title: (MemoryItem item) {
                return Text(qtyToText(item.json));
              },
              subtitle: (MemoryItem item) {
                // return Text(qtyToText(item.json['_balance']?[cQty]));
                return const Text('');
              },
              onTap: (item) => changeState(item),
            ))
      ];
    } else if (storage != null || (storage != null && goods != null)) {
      return <Widget>[
        // Expanded(child: WHDispatchListBuilder(storage: storage))
        SizedBox(
            height: 350,
            child: BalanceListBuilder(
              storage: storage,
              category: category,
              goods: goods,
              batch: batch,
              changeState: (item) => changeState(item),
            ))
      ];
    }

    return <Widget>[];
  }

  void changeState(MemoryItem item) {
    // print("setState ${_formKey.currentState?.fields[cGoods]}");
    // print("changeState: (item) ${item.json}");

    final state = _formKey.currentState;
    if (state == null) {
      return;
    }

    final category = item.json['_category'];

    if (category.toString() == cStorage) {
      state.patchValue({cStorage: item});
    } else if (category.toString() == cCategory) {
      state.patchValue({cCategory: item});
    } else if (category.toString() == cGoods) {
      state.patchValue({cGoods: item});
    }

    // TODO refactoring
    void fillQty(Map qty) {
      // print('fn_fillQty $qty');
      state.patchValue({"qty_0": qty["number"].toString()});
      final uom = qty["uom"];
      if (uom != null) {
        final uomItem = MemoryItem(
          id: uom['in']?[cId] ?? uom['in']?['id'] ?? uom[cId] ?? uom['id'],
          json: uom,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        // workaround for displaying uom name
        final name = uomItem.json['in']?['name'];
        if (name != null) {
          uomItem.json['name'] = name;
        }

        state.patchValue({"uom_0": uomItem});
      }
    }

    if (items.isNotEmpty) {
      // print('items.isNotEmpty ${item.json}');
      Map? qty = item.json['_balance']?[cQty] ?? item.json[cQty] ?? item.json;
      if (qty != null) {
        fillQty(qty);
      }
    }

    final batch = item.json[cBatch];
    if (batch != null) {
      batch[cName] = DT.pretty(batch[cDate] ?? '');
      state.patchValue({cBatch: MemoryItem.from(batch)});
      List? qtyList = item.json['_balance']?[cQty] ?? item.json;
      print("_qtyList $qtyList");
      if (qtyList != null) {
        if (qtyList.length == 1) {
          Map qty = qtyList.first;
          fillQty(qty);
        } else {
          setState(() {
            items = qtyList;
          });
        }
      }
    }
  }

  List<Widget> qtyUom(BuildContext context) {
    final localization = AppLocalizations.of(context);
    var children = <Widget>[];

    final uom = Expanded(
      flex: 1,
      child: DecoratedFormPickerField(
        creatable: false,
        ctx: const [cUom],
        name: 'uom_0',
        label: localization.translate(cUom),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(errorText: "выберите значение"),
        ]),
        onSave: (context) {},
        editable: false,
      ),
    );

    final qty = Expanded(
      flex: 1,
      child: DecoratedFormField(
        name: 'qty_0',
        label: localization.translate(cQty),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.numeric(),
        ]),
        onSave: (context) {},
        keyboardType: TextInputType.number,
      ),
    );

    children.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [uom, const SizedBox(width: 5), qty],
      ),
    );
    children.add(const SizedBox(height: 10));

    if (showQtyUom) {
      return children;
    } else {
      return [SizedBox(height: 0, child: Column(children: children))];
    }
  }

  void resetDone() {
    setState(() => registered = '');
  }

  void done(String type) {
    if (type == 'register') {
      if (widget.afterSave != null) {
        widget.afterSave?.call();
        return;
      }
    }
    setState(() {
      registered = type;

      // workaround as unknown where item resetting to initial
      showCategory = false;
      showGoods = false;
      showBatch = false;
      showQtyUom = false;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        registered = '';

        // workaround as unknown where item resetting to initial
        final storageData = details.json[cStorage];
        if (storageData is MemoryItem) {
          final storage = MemoryItem.clone(details.json[cStorage]);
          storage.json['_category'] = cStorage;
          changeState(storage);
        }
      });
    });
  }

  void setStatus(String newStatus) {
    setState(() => status = newStatus);
  }

  void registerAndPrintPreparation() async {
    resetDone();

    final state = _formKey.currentState;
    if (state == null) {
      // TODO raise error instead
      return;
    }
    if (state.saveAndValidate()) {
      final data = state.value;

      // print("registerAndPrintPreparation $data");

      final printer = data[cPrinter];
      if (printer == null) {
        throw const FormatException('select printer');
      }

      final ip = printer.json['ip'];
      final port = int.parse(printer.json['port']);

      await registerAndPrint(ip, port, data);
    }
  }

  void registerPreparation() async {
    resetDone();

    final state = _formKey.currentState;
    if (state == null) {
      // TODO raise error instead
      return;
    }
    if (state.saveAndValidate()) {
      var data = state.value;

      // TODO understand is it required
      final doc = await widget.doc.enrich(widget.schema);

      try {
        final result = await register(
            doc, data, 1, true, widget.ctx, widget.rec?.id, setStatus);
        if (!(result.isNew || result.isEmpty)) {
          done('register');
        }
      } finally {
        setStatus("register");
      }
    }
  }

  Future<void> registerAndPrint(String ip, int port, Map<String, dynamic> data,
      {MemoryItem? item}) async {
    resetDone();

    setStatus("connecting");

    try {
      final result = await Labels.connect(ip, port, (printer) async {
        // TODO understand is it required
        final doc = await widget.doc.enrich(widget.schema);
        final record = item ??
            await register(doc, data, 1, true, widget.ctx, null, setStatus);

        if (item == null) {
          if (!(record.isEmpty || record.isNew)) {
            done('registerAndPrint');
          }
        }

        // print("registerAndPrint record: $record");

        if (record.isEmpty || record.isNew) {
          return PrintResult.registrationFailed;
        }

        return await printing(printer, doc, record, setStatus);
      });

      if (result != PrintResult.success) {
        showToast(result.msg,
            // context: context,
            axis: Axis.horizontal,
            alignment: Alignment.center,
            position: StyledToastPosition.bottom);
      }
    } catch (e) {
      // , stacktrace
      // print(stacktrace);
      showToast(e.toString(),
          // context: context,
          axis: Axis.horizontal,
          alignment: Alignment.center,
          position: StyledToastPosition.bottom);
    } finally {
      setStatus("register");
    }
  }
}

class BalanceListBuilder extends StatelessWidget {
  const BalanceListBuilder(
      {super.key,
      this.storage,
      this.category,
      this.goods,
      this.batch,
      required this.changeState});

  final Function(MemoryItem item) changeState;

  final MemoryItem? storage;
  final MemoryItem? category;
  final MemoryItem? goods;
  final MemoryItem? batch;

  @override
  Widget build(BuildContext context) {
    final schema = <Field>[
      fName.copyWith(width: 3.0),
      const Field(cQty, NumberType(), path: ['_balance', cQty]),
    ];

    Map<String, dynamic> filter = {};

    if (storage != null) {
      filter[cStorage] = storage!.json[cUuid] ?? '';
    }

    if (category != null) {
      filter[cCategory] = category!.json[cUuid] ?? '';
    }

    if (goods != null) {
      filter[cGoods] = goods!.json[cUuid] ?? '';
    }

    if (batch != null) {
      filter[cBatch] = batch!.json['id'] ?? '';
    }

    const ctx = ['warehouse', 'stock'];

    return BlocProvider(
      key: ValueKey(filter),
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
        schema: schema,
        filter: filter,
        title: (MemoryItem item) {
          final batch = item.json[cBatch];

          if (batch != null) {
            return Text(DT.pretty(batch[cDate] ?? ''));
          }
          return Text(fName.resolve(item.json) ?? '');
        },
        subtitle: (MemoryItem item) {
          final qty = item.json['_balance']?[cQty] ?? item.json[cQty];
          if (qty != null) {
            return Text(qtyToText(qty));
          }
          return const Text('');
        },
        onTap: (context, item) => changeState(item),
        mode: Mode.mobile,
        sortByName: true,
      ),
    );
  }
}

class ItemsListBuilder extends StatelessWidget {
  const ItemsListBuilder({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    required this.items,
  });

  final Widget Function(MemoryItem) title;
  final Widget Function(MemoryItem) subtitle;
  final Function(MemoryItem)? onTap;
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      // controller: _scrollController,
      itemBuilder: (context, index) {
        final item = MemoryItem(id: index.toString(), json: items[index]);
        // if (widget.actions.isEmpty) {
        return card(context, item);
        // }
        // return SwipeActionWidget(
        //   item: item,
        //   actions: widget.actions,
        //   // key: key,
        //   child: card(context, item),
        // );
      },
    );
  }

  Widget card(BuildContext context, MemoryItem item) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        // leading: const Icon(Icons.account_circle),
        title: title(item),
        subtitle: subtitle(item),
        trailing: onTap == null ? null : const Icon(Icons.arrow_forward),
        onTap: () {
          onTap?.call(item);
        },
      ),
    );
  }
}

String qtyToText(dynamic listOrMap) {
  // print("qtyToText $listOrMap");
  String text = '';
  if (listOrMap != null) {
    if (listOrMap is List && listOrMap.isNotEmpty) {
      // print("list case");
      for (Map qty in listOrMap) {
        text = qtyToTextInner(text, qty);
      }
    } else if (listOrMap is Map) {
      // print("map case");
      text = qtyToTextInner(text, listOrMap);
    }
  }
  return text;
}

String qtyToTextInner(String text, Map qty) {
  // print("qtyToTextInner $text $qty");
  if (text != '') {
    text = '$text, ';
  }
  text = '$text ${qty['number'] ?? ''}';
  var uom = qty['uom'];

  if (uom is String) {
    text = '$text $uom';
  } else {
    while (uom is Map) {
      if (uom['uom'] == null) {
        text = '$text ${uom['name'] ?? ''}';
        break;
      }
      text = '$text ${uom['in']?['name'] ?? ''} по ${uom['number'] ?? ''}';

      final label = uom['uom']?['name'];
      if (label != null) {
        text = '$text $label';
        break;
      } else {
        uom = uom['uom'];
      }
    }
  }
  // workaround for algorithm above
  text = text.trimLeft();
  return text;
}
