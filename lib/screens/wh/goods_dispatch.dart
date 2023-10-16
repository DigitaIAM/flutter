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
  final List<Field> schema;
  final bool enablePrinting;
  final bool allowGoodsCreation;

  const GoodsDispatch({
    super.key,
    required this.ctx,
    required this.doc,
    required this.schema,
    this.enablePrinting = true,
    this.allowGoodsCreation = true,
  });

  @override
  State<StatefulWidget> createState() => _GoodsDispatchState();
}

class _GoodsDispatchState extends State<GoodsDispatch> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_goodsDispatchEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  final MemoryItem details = MemoryItem(id: '', json: {cDate: Utils.today()});

  String status = "register";
  String registered = '';

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // print("Widget build(BuildContext context)");

    final widgets = <Widget>[
      if (status != 'register')
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
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

          final storage = value[cStorage];

          if (storage is MemoryItem) {
            setState(() {});
          }
        },
        child: FormCard(isLast: true, children: <Widget>[
          ...(widget.enablePrinting
              ? [
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
                  )
                ]
              : []),
          const SizedBox(height: 10),
          DecoratedFormPickerField(
            ctx: const ['warehouse', 'storage'],
            name: cStorage,
            label: localization.translate(cStorage),
            creatable: false,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: "выберите место хранения"),
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
          ),
          const SizedBox(height: 10),
          DecoratedFormPickerField(
            ctx: const [cGoods],
            name: cGoods,
            label: localization.translate(cGoods),
            creatable: widget.allowGoodsCreation,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: "выберите товар"),
            ]),
            onSave: (context) {},
          ),
          DecoratedFormPickerField(
            ctx: const ['goods', 'stock'],
            name: cBatch,
            label: localization.translate(cBatch),
            creatable: widget.allowGoodsCreation,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: "выберите партию"),
            ]),
            onSave: (context) {},
          ),
          const SizedBox(height: 10),
          ...qtyUom(context),
          ...goodsList(widget.schema),
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
                  onPressed: status == 'register' ? registerAndPrintPreparation : null,
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
                  : Icon(
                      Icons.add,
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

  List<Widget> goodsList(List<Field> schema) {
    final state = _formKey.currentState;
    if (state == null) {
      return <Widget>[];
    }

    state.save();

    final storage = state.value[cStorage];
    final category = state.value[cCategory];
    final goods = state.value[cGoods];
    final batch = state.value[cBatch];

    if (storage != null || (storage != null && goods != null)) {
      return <Widget>[
        // Expanded(child: WHDispatchListBuilder(storage: storage))
        SizedBox(
            height: 230,
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

    final batch = item.json[cBatch];
    if (batch != null) {
      batch[cName] = DT.pretty(batch[cDate] ?? '');
      state.patchValue({cBatch: MemoryItem.from(batch)});
      List? qtyList = item.json['_balance']?[cQty];
      if (qtyList != null) {
        for (Map qty in qtyList) {
          state.patchValue({"qty_0": qty["number"] ?? ''});
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
      }
    } else {
      final category = item.json['_category'];

      if (category.toString() == cCategory) {
        state.patchValue({cCategory: item});
      } else {
        state.patchValue({cGoods: item});
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

    return children;
  }

  void resetDone() {
    setState(() => registered = '');
  }

  void done(String type) {
    setState(() => registered = type);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => registered = '');
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
      final data = state.value;

      // TODO understand is it required
      final doc = await widget.doc.enrich(widget.schema);

      try {
        final result = await register(doc, data, 1, widget.ctx, setStatus);

        if (!(result.isNew || result.isEmpty)) {
          done('register');
        }
      } finally {
        setStatus("register");
      }
    }
  }

  Future<void> registerAndPrint(String ip, int port, Map<String, dynamic> data, {MemoryItem? item}) async {
    resetDone();

    setStatus("connecting");

    try {
      final result = await Labels.connect(ip, port, (printer) async {
        // TODO understand is it required
        final doc = await widget.doc.enrich(widget.schema);
        final record = item ?? await register(doc, data, 1, widget.ctx, setStatus);

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
  const BalanceListBuilder({super.key, this.storage, this.category, this.goods, this.batch, required this.changeState});

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
      filter[cBatch] = batch!.json[cUuid] ?? '';
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
          // return Text(item.json['_balance']?[cQty] ?? '');
          return Text(qtyToText(item.json['_balance']?[cQty]));
        },
        onTap: (context, item) => changeState(item),
        mode: Mode.mobile,
        sortByName: true,
      ),
    );
  }

  String qtyToText(List<dynamic>? qtyList) {
    var text = '';
    if (qtyList != null && qtyList.isNotEmpty) {
      for (Map qty in qtyList) {
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
              break;
            }
            text = '$text ${uom['in']?['name'] ?? ''} по ${uom['number'] ?? ''}';
            if (uom['uom']?['name'] != null) {
              text = '$text ${uom['uom']?['name'] ?? ''}';
              break;
            } else {
              uom = uom['uom'];
            }
          }
        }
      }
    } else {
      text = '';
    }
    // print('_text $text');
    return text;
  }
}
