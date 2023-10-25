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

  static Future<PrintResult> printing(
    NetworkPrinter printer,
    MemoryItem? orderDoc,
    MemoryItem doc,
    void Function(String) updateStatus,
  ) async {
    updateStatus("printing");

    final record = await doc.enrich([
      fControl,
      const Field(cDocument, ReferenceType(['production', 'order'])),
    ]);

    MemoryItem orderItem;
    if (orderDoc == null) {
      orderItem = doc.json[cDocument] ?? doc.json[cOrder];
    } else {
      orderItem = orderDoc;
    }

    final order = await orderItem.enrich([
      fArea,
      fProduct,
      fOperator,
    ]);

    final area = order.json[cArea];

    String type = '';
    if (area.json[cType] == 'roll') {
      type = 'roll';
    } else if (area.json[cType] == 'final') {
      type = 'final';
    } else {
      type = 'boxed';
    }

    // TODO think how to select date
    final date = order.json[cDate] ?? record.json[cDate] ?? '';
    final dd = DT.format(date);

    final product = order.json[cProduct].json;
    final productName = product[cName] ?? '';
    final partNumber = product['part_number'] ?? '';

    final operator = order.json[cOperator] as MemoryItem?;
    if (operator == null) {
      throw const FormatException('operator is not selected');
    }
    final operatorName = operator.name();

    final control = record.json[cControl] as MemoryItem?;
    if (control == null) {
      throw const FormatException('control is not selected');
    }
    final controlName = control.name();

    // final qty = record.json[cQty] ?? '';
    final qty = await qtyToText(record);

    final Map<String, String> labelData;
    if (type == 'roll') {
      final notes = record.json['notes'] ?? '';
      final material = record.json['material'] ?? order.json['material'] ?? '';
      var thickness = record.json['thickness'] ?? order.json['thickness'] ?? '';
      final length = record.json['length'] ?? '';

      thickness = "$thickness".replaceAll(".", "");

      labelData = {
        "продукция": productName,
        "артикул": "$partNumber$thickness",
        "сырьё": "$material $notes",
        "дата": dd,
        "line1": "",
        "вес": qty,
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
        "количество": qty,
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
        "количество": qty,
        "line1": "",
        "оператор": operatorName,
        "проверил": controlName,
        "line2": "",
        "этикетка": label,
        "заказчик": customer,
      };
    }

    Labels.lines(printer, record.id, labelData);

    return PrintResult.success;
  }

  static Future<String> qtyToText(MemoryItem rec) async {
    var text = '';
    // print("_rec_: ${record.json}");
    Map? map = rec.json[cQty] ?? rec.json['op']?[cQty] ?? '';
    // print('_list $map');
    if (map != null && map.isNotEmpty) {
      // print('_qty $map');
      if (text != '') {
        text = '$text, ';
      }
      text = '$text ${map['number'] ?? ''}';
      var uom = map['uom'];

      if (uom is String) {
        // print('uomIsString');
        var obj = await Api.feathers().get(
            serviceName: "memories",
            objectId: uom,
            params: {"oid": Api.instance.oid, "ctx": []}).onError((error, stackTrace) => {});
        text = '$text ${obj['name'] ?? ''}';
      } else {
        // print('_uomType ${uom.runtimeType}');
        while (uom is Map) {
          var inObj = await Api.feathers().get(
              serviceName: "memories",
              objectId: uom['in'] ?? '',
              params: {"oid": Api.instance.oid, "ctx": []}).onError((error, stackTrace) => {});

          text = '$text ${inObj['name'] ?? ''} по ${uom['number'] ?? ''}';
          // print('_uom $uom');
          if (uom['uom'] is String) {
            var obj = await Api.feathers().get(
                serviceName: "memories",
                objectId: uom['uom'] ?? '',
                params: {"oid": Api.instance.oid, "ctx": []}).onError((error, stackTrace) => {});

            text = '$text ${obj['name'] ?? ''}';
            break;
          } else {
            uom = uom['uom'];
          }
        }
      }
    } else {
      text = '0';
    }
    // print('_text $text');
    if (text.characters.first == ' ') {
      text = text.substring(1);
    }
    return text;
  }
}

class _POProducedEditState extends State<POProducedEdit> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_productionOrderProducedEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  final MemoryItem details = MemoryItem(id: '', json: {cDate: Utils.today()});

  String status = "register";

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    final area = widget.order.json[cArea] ?? MemoryItem.create();
    // final product = widget.order.json[cProduct] ?? MemoryItem.create();

    List<Widget> fields = [];
    if (area.json[cType] == 'roll') {
      fields = rollForm(localization);
    } else if (area.json[cType] == 'final') {
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
                creatable: false,
                ctx: const ['printer'],
                name: cPrinter,
                label: localization.translate(cPrinter),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              DecoratedFormField(
                name: cDate,
                label: localization.translate(cDate),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
                keyboardType: TextInputType.datetime,
                // readOnly: true,
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
      DecoratedFormField(
        name: 'notes',
        label: localization.translate("notes"),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
        keyboardType: TextInputType.number,
      ),
      DecoratedFormPickerField(
        creatable: false,
        ctx: const ['person'],
        name: cControl,
        label: localization.translate(cControl),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
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
        name: cQty,
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
        creatable: false,
        ctx: const ['person'],
        name: cControl,
        label: localization.translate(cControl),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
      ),
      DecoratedFormField(
        name: cQty,
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
        creatable: false,
        ctx: const ['person'],
        name: cControl,
        label: localization.translate(cControl),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (context) {},
      ),
      DecoratedFormField(
        name: cQty,
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
      // print("pressed:");

      final data = _formKey.currentState?.value;
      if (data == null) {
        return;
      }

      final printer = data[cPrinter];
      if (printer == null) {
        throw const FormatException('select printer');
      }
      final ip = printer.json['ip'];
      final port = int.parse(printer.json['port']);

      // print("printer $ip $port");

      final order = await widget.order.enrich([
        fProduct,
        fOperator,
      ]);

      // print("order ${order.json}");

      final orderId = order.id;

      final date = data[cDate] ?? '';

      // final operator = order.json[cOperator];
      // if (operator == null) {
      //   throw const FormatException('operator is not selected');
      // }

      final control = data[cControl];
      if (control == null) {
        throw const FormatException('select control');
      }
      // print("control $control");
      final controlId = control.id;

      var qty = data[cQty] ?? 0;

      final area = widget.order.json[cArea] ?? MemoryItem.create();

      Map<String, dynamic> uom = {};
      Map<String, dynamic> innerQty = {};

      final product = order.json['product'] as MemoryItem;

      final filter = area.json['type'] == 'roll' ? "Рул" : "Кор";

      final uomIn = await Api.feathers().find(serviceName: "memories", query: {
        "oid": Api.instance.oid,
        "ctx": [cUom],
        "filter": {cName: filter},
      });

      uom[cNumber] = qty;
      uom[cUom] = product.json[cUom]?[cUuid] ?? '';
      uom['in'] = uomIn['data']?[0]?[cUuid];

      innerQty[cNumber] = 1;
      innerQty[cUom] = uom;

      qty = innerQty;

      final recordData = {
        cDocument: orderId,
        cDate: date,
        // cOperator: operatorId,
        cControl: controlId,
        cQty: qty
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
        final response = await Api.feathers().create(serviceName: 'memories', data: recordData, params: {
          'oid': Api.instance.oid,
          'ctx': ['production', 'produce']
        });

        final record = MemoryItem.from(response);

        return await POProducedEdit.printing(
          printer,
          widget.order,
          record,
          (String newStatus) => setState(() => status = newStatus),
        );
      });

      if (result != PrintResult.success) {
        showToast(result.msg,
            // context: context,
            axis: Axis.horizontal,
            alignment: Alignment.center,
            position: StyledToastPosition.bottom);
      }
    } catch (e, stacktrace) {
      // print(stacktrace);
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
