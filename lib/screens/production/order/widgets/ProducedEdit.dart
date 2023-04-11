import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class POProducedEdit extends StatefulWidget {
  final MemoryItem order;

  const POProducedEdit({super.key, required this.order});

  @override
  State<StatefulWidget> createState() => _POProducedEditState();

  static void printing(
    NetworkPrinter printer,
    MemoryItem? orderDoc,
    MemoryItem doc,
    void Function(String) updateStatus,
  ) async {
    updateStatus("printing");

    final record = await doc.enrich([
      fControl,
      const Field('order', ReferenceType(['production', 'order'])),
    ]);

    MemoryItem orderItem;
    if (orderDoc == null) {
      orderItem = doc.json['order'];
    } else {
      orderItem = orderDoc;
    }

    final order = await orderItem.enrich([
      fArea,
      fProduct,
      fOperator,
    ]);

    final area = order.json['area'];

    String type = '';
    if (area.json['type'] == 'roll') {
      type = 'roll';
    } else if (area.json['type'] == 'final') {
      type = 'final';
    } else {
      type = 'boxed';
    }

    final date = record.json['date'];
    final dd = DT.format(date);

    final product = order.json['product'].json;
    final productName = product['name'] ?? '';
    final partNumber = product['part_number'] ?? '';

    final operator = order.json['operator'];
    if (operator == null) {
      throw const FormatException('operator is not selected');
    }
    final operatorName = operator.label();

    final control = record.json['control'];
    if (control == null) {
      throw const FormatException('control is not selected');
    }
    final controlName = control.label();

    final qty = record.json['qty'] ?? '';

    final Map<String, String> labelData;
    if (type == 'roll') {
      final material = record.json['material'] ?? '';
      final thickness = record.json['thickness'] ?? '';
      final length = record.json['length'] ?? '';

      labelData = {
        "продукция": productName,
        "артикул": "$partNumber$thickness",
        "сырьё": "$material",
        "дата": dd,
        "line1": "",
        "вес": "$qty кг",
        "длина": "$length м",
        "line2": "",
        "оператор": operatorName,
        "проверил": controlName,
      };
    } else if (type == 'boxed') {
      labelData = {
        "продукция": productName,
        "артикул": partNumber,
        "дата": dd,
        "количество": "$qty шт",
        "line1": "",
        "оператор": operatorName,
        "проверил": controlName,
      };
    } else {
      final customer = record.json['customer'] ?? order.json['customer'] ?? '';
      final label = record.json['label'] ?? order.json['label'] ?? '';

      labelData = {
        "продукция": productName,
        "артикул": partNumber,
        "дата": dd,
        "количество": "$qty шт",
        "line1": "",
        "оператор": operatorName,
        "проверил": controlName,
        "line2": "",
        "этикетка": label,
        "заказчик": customer,
      };
    }

    Labels.lines(printer, record.id, labelData);
  }
}

class _POProducedEditState extends State<POProducedEdit> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_productionOrderProducedEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  final MemoryItem details = MemoryItem(id: '', json: {'date': Utils.today()});

  String status = "register";

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    final area = widget.order.json['area'] ?? MemoryItem.create();
    // final product = widget.order.json['product'] ?? MemoryItem.create();

    List<Widget> fields = [];
    if (area.json['type'] == 'roll') {
      fields = rollForm(localization);
    } else if (area.json['type'] == 'final') {
      fields = finalForm(localization);
    } else {
      fields = boxedForm(localization);
    }

    final widgets = <Widget>[
      AppForm(
          entity: details,
          formKey: _formKey,
          focusNode: _focusNode,
          onChanged: () {
            _formKey.currentState!.save();
            debugPrint("onChanged: ${_formKey.currentState!.value}");
          },
          child: ScrollableListView(children: <Widget>[
            FormCard(isLast: true, children: <Widget>[
              DecoratedFormPickerField(
                ctx: const ['printer'],
                name: 'printer',
                label: localization.translate("printer"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              DecoratedFormField(
                name: 'date',
                label: localization.translate("date"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
                keyboardType: TextInputType.datetime,
                readOnly: true,
              ),
              ...fields,
              ElevatedButton(
                onPressed: status == 'register' ? registerAndPrint : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(localization.translate(status)),
              )
            ])
          ]))
    ];
    return ScrollableListView(
      children: widgets,
    );
  }

  List<Widget> rollForm(AppLocalizations localization) {
    return [
      DecoratedFormPickerField(
        ctx: const ['person'],
        name: 'control',
        label: localization.translate("control"),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
      ),
      DecoratedFormField(
        name: 'material',
        label: localization.translate("material"),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
        keyboardType: TextInputType.text,
      ),
      DecoratedFormField(
        name: 'thickness',
        label: localization.translate("thickness"),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
        keyboardType: TextInputType.text,
      ),
      DecoratedFormField(
        name: 'length',
        label: localization.translate("length"),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
        keyboardType: TextInputType.number,
      ),
      DecoratedFormField(
        name: 'qty',
        label: localization.translate("weight"),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
        keyboardType: TextInputType.number,
      ),
    ];
  }

  List<Widget> boxedForm(AppLocalizations localization) {
    return [
      DecoratedFormPickerField(
        ctx: const ['person'],
        name: 'control',
        label: localization.translate("control"),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
      ),
      DecoratedFormField(
        name: 'qty',
        label: localization.translate("qty in box"),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
        keyboardType: TextInputType.number,
      ),
    ];
  }

  List<Widget> finalForm(AppLocalizations localization) {
    return [
      DecoratedFormField(
        name: 'customer',
        label: localization.translate("customer"),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
        keyboardType: TextInputType.text,
      ),
      DecoratedFormField(
        name: 'label',
        label: localization.translate("label"),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
        keyboardType: TextInputType.text,
      ),
      DecoratedFormPickerField(
        ctx: const ['person'],
        name: 'control',
        label: localization.translate("control"),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
      ),
      DecoratedFormField(
        name: 'qty',
        label: localization.translate("qty in box"),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
        keyboardType: TextInputType.number,
      ),
    ];
  }

  void registerAndPrint() async {
    setState(() => status = "connecting");
    try {
      print("pressed:");

      final data = _formKey.currentState?.value;
      if (data == null) {
        return;
      }

      final printer = data['printer'];
      if (printer == null) {
        throw const FormatException('select printer');
      }
      final ip = printer.json['ip'];
      final port = int.parse(printer.json['port']);

      print("printer $ip $port");

      final order = await widget.order.enrich([
        fProduct,
        fOperator,
      ]);

      print("order ${order.json}");

      final orderId = order.id;

      final date = data['date'] ?? '';

      final operator = order.json['operator'];
      if (operator == null) {
        throw const FormatException('operator is not selected');
      }

      final control = data['control'];
      if (control == null) {
        throw const FormatException('select control');
      }
      final controlId = control.id();

      final qty = data['qty'] ?? 0;

      final recordData = {
        'order': orderId,
        'date': date,
        // 'operator': operatorId,
        'control': controlId,
        'qty': qty
      };

      final material = data['material'];
      if (material != null) {
        recordData['material'] = material;
      }

      final thickness = data['thickness'];
      if (thickness != null) {
        recordData['thickness'] = thickness;
      }

      final length = data['length'];
      if (length != null) {
        recordData['length'] = length;
      }

      final customer = data['customer'];
      if (customer != null) {
        recordData['customer'] = customer;
      }

      final label = data['label'];
      if (label != null) {
        recordData['label'] = label;
      }

      final result = await Labels.connect(ip, port, (printer) async {
        setState(() => status = "registering");
        final record = await Api.feathers().create(serviceName: 'memories', data: recordData, params: {
          'oid': Api.instance.oid,
          'ctx': ['production', 'produce']
        });

        POProducedEdit.printing(
          printer,
          widget.order,
          record,
          (String newStatus) => setState(() => status = newStatus),
        );

        return Future<PrintResult>.value(PrintResult.success);
      });

      if (result != PrintResult.success) {
        showToast(result.msg,
            // context: context,
            axis: Axis.horizontal,
            alignment: Alignment.center,
            position: StyledToastPosition.bottom);
      }
    } catch (e, stacktrace) {
      print(stacktrace);
      showToast(e.toString(),
          // context: context,
          axis: Axis.horizontal,
          alignment: Alignment.center,
          position: StyledToastPosition.bottom);
    } finally {
      setState(() {
        status = "register";
      });
    }
  }
}
