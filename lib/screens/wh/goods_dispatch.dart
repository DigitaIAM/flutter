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

  final MemoryItem details = MemoryItem(id: '', json: {'date': Utils.today()});

  String status = "register";
  int numberOfQuantities = 1;
  String registered = '';

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    print("Widget build(BuildContext context)");

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

          final storage = value['storage'];
          final goods = value['goods'];

          if (storage is MemoryItem) {
            setState(() {});
          }

          if (goods is MemoryItem) {
            final baseUom = goods.json['uom'];
            final baseUomId = baseUom is Map ? baseUom['_id'] : baseUom;

            var firstEmpty = -1;
            var found = false;
            var newNumber = numberOfQuantities;
            for (var index = 0; index < numberOfQuantities; index++) {
              // TODO fix removal
              // if (found) {
              //   state.fields['uom_$index']
              //       ?.setValue(null, populateForm: false);
              //   state.fields['qty_$index']
              //       ?.setValue(null, populateForm: false);
              // }
              if (!found && baseUomId == value['uom_$index']?.id) {
                newNumber = index + 1;
                found = true;
              }
              if (firstEmpty == -1 && value['uom_$index'] == null) {
                firstEmpty = index;
              }
            }
            if (!found) {
              if (firstEmpty == -1) {
                newNumber += 1;
              } else {
                newNumber = firstEmpty + 1;
              }
            }

            // print("number_of_qties $number_of_qties $newNumber $firstEmpty");

            setState(() {
              numberOfQuantities = newNumber;
            });
          }
        },
        child: FormCard(isLast: true, children: <Widget>[
          ...(widget.enablePrinting
              ? [
                  DecoratedFormPickerField(
                    creatable: false,
                    ctx: const ['printer'],
                    name: 'printer',
                    label: localization.translate("printer"),
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
            name: 'storage',
            label: localization.translate("storage"),
            creatable: false,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: "выберите место хранения"),
            ]),
            onSave: (context) {},
          ),
          const SizedBox(height: 10),
          DecoratedFormPickerField(
            ctx: const ['goods'],
            name: 'goods',
            label: localization.translate("goods"),
            creatable: widget.allowGoodsCreation,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: "выберите товар"),
            ]),
            onSave: (context) {},
          ),
          // DecoratedFormPickerField(
          //   ctx: const ['goods', 'stock'],
          //   name: 'batch',
          //   label: localization.translate("batch"),
          //   creatable: widget.allowGoodsCreation,
          //   validator: FormBuilderValidators.compose([
          //     FormBuilderValidators.required(errorText: "выберите партию"),
          //   ]),
          //   onSave: (context) {},
          // ),
          const SizedBox(height: 10),
          ...qtyUom(context),
          // ...goodsList(widget.schema),
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

    final goods = state.value['goods'];
    final storage = state.value['storage'];

    if (storage != null || (storage != null && goods != null)) {
      return <Widget>[
        // Expanded(child: WHDispatchListBuilder(storage: storage))
        SizedBox(
            height: 230,
            child: BalanceListBuilder(
              storage: storage,
              goods: goods,
              changeState: (item) {
                // print("setState ${_formKey.currentState?.fields["goods"]}");
                // print("changeState: (item) ${item.json}");

                final state = _formKey.currentState;
                if (state == null) {
                  return;
                }

                final batch = item.json['batch'];
                if (batch != null) {
                  batch['name'] = batch['barcode'] ?? '?';
                  // print("batch $batch");
                  state.patchValue({"batch": MemoryItem.from(batch)});
                } else {
                  final baseUom = item.json['uom'];
                  state.patchValue({"goods": item});
                  state.patchValue({"uom_0": MemoryItem.from(baseUom)});
                }
              },
            ))
      ];
    }

    return <Widget>[];
  }

  List<Widget> qtyUom(BuildContext context) {
    final localization = AppLocalizations.of(context);
    var children = <Widget>[];

    for (var index = 0; index < numberOfQuantities; index++) {
      final uom = Expanded(
        flex: 1,
        child: DecoratedFormPickerField(
          creatable: false,
          ctx: const ['uom'],
          name: 'uom_$index',
          label: localization.translate("uom"),
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
          name: 'qty_$index',
          label: localization.translate("qty"),
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
    }
    // ;

    return children;
  }

  void resetDone() {
    setState(() => {registered = ''});
  }

  void done(String type) {
    setState(() => {registered = type});
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => {registered = ''});
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

      final printer = data['printer'];
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
        final result = await register(doc, data, numberOfQuantities, widget.ctx, setStatus);

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
        final record = item ?? await register(doc, data, numberOfQuantities, widget.ctx, setStatus);

        if (item == null) {
          if (!(record.isEmpty || record.isNew)) {
            done('registerAndPrint');
          }
        }

        print("registerAndPrint record: $record");

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
  const BalanceListBuilder({super.key, this.storage, this.goods, required this.changeState});

  final Function(MemoryItem item) changeState;

  final MemoryItem? storage;
  final MemoryItem? goods;

  @override
  Widget build(BuildContext context) {
    final schema = <Field>[
      fName.copyWith(width: 3.0),
      // fUomAtQty.copyWith(width: 0.5, editable: false),
      fQty.copyWith(width: 1.0),
    ];

    Map<String, dynamic> filter = {};

    if (storage != null) {
      filter['storage'] = storage!.json['_uuid'] ?? '';
    }

    if (goods != null) {
      filter['goods'] = goods!.json['_uuid'] ?? '';
    }

    print("build filter $filter");

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
            final batch = item.json['batch'];
            if (batch != null) {
              var barcode = batch['barcode'] ?? '';
              if (barcode.length == 12) {
                final fst = barcode.substring(0, 1);
                final snd = barcode.substring(1, 7);
                final trd = barcode.substring(7, 12);
                barcode = '$fst $snd $trd';
              }
              return Text(barcode);
            }
            return Text(fName.resolve(item.json) ?? '');
          },
          subtitle: (MemoryItem item) {
            return Text(item.json['_cost']?['qty'] ?? '');
          },
          onTap: (context, item) => changeState(item)),
    );
  }
}
