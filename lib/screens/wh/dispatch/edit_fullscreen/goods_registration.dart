import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/printer/printing.dart';
import 'package:nae/screens/wh/dispatch/screen.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class WHDispatchGoodsRegistration extends StatefulWidget {
  final MemoryItem doc;

  const WHDispatchGoodsRegistration({super.key, required this.doc});

  @override
  State<StatefulWidget> createState() => _WHDispatchGoodsRegistrationState();
}

class _WHDispatchGoodsRegistrationState
    extends State<WHDispatchGoodsRegistration> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(
      debugLabel: '_WHDispatchGoodsRegistrationEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  final MemoryItem details = MemoryItem(id: '', json: {'date': Utils.today()});

  static const ctx = ['warehouse', 'dispatch'];

  String status = "register";
  int numberOfQuantities = 1;
  String registered = '';

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final widgets = <Widget>[
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
            final value = state.value;
            debugPrint("onChanged: $value");

            final goods = value['goods'];
            if (goods is MemoryItem) {
              final baseUom = goods.json['uom'];

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
                if (!found && baseUom == value['uom_$index']?.id) {
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
          child: ScrollableListView(children: <Widget>[
            FormCard(isLast: true, children: <Widget>[
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
              ),
              const SizedBox(height: 10),
              DecoratedFormPickerField(
                ctx: const ['goods'],
                name: 'goods',
                label: localization.translate("goods"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: "выберите товар"),
                ]),
                onSave: (context) {},
              ),
              const SizedBox(height: 10),
              ...qtyUom(context),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FloatingActionButton(
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
                FloatingActionButton(
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
                ),
              ],
            ),
            if (status != 'register')
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(status),
                  ]),
          ]))
    ];
    return ScrollableListView(
      children: widgets,
    );
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
      final doc = await widget.doc.enrich(WHDispatch.schema);

      try {
        final result =
            await register(doc, data, numberOfQuantities, ctx, setStatus);

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
        final doc = await widget.doc.enrich(WHDispatch.schema);
        final record = item ??
            await register(doc, data, numberOfQuantities, ctx, setStatus);

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
