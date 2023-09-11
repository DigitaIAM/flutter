import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/models/ui/state.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/utils/number.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_view.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class WHBalanceView extends EntityHolder {
  final int tabIndex;

  const WHBalanceView({super.key, required super.entity, required this.tabIndex});

  @override
  State<WHBalanceView> createState() => _WHBalanceViewState();
}

class _WHBalanceViewState extends State<WHBalanceView> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final store = fStorage.resolve(widget.entity.json);
    final goods = fGoods.resolve(widget.entity.json);

    return ScaffoldView(
      title: '${store.name().toLowerCase()}\n${goods.name().toLowerCase()}',
      body: Builder(builder: (context) {
        return Column(children: <Widget>[
          Expanded(
            child: WHTransactionsBuilder(widget.entity),
          ),
        ]);
      }),
    );
  }
}

Field fType = Field(cType, CalculatedType((MemoryItem rec) async {
  return rec.json[cType] ?? rec.json['op']?[cType] ?? '';
}));

Field fQty = Field(cQty, CalculatedType((MemoryItem rec) async {
  // print("rec.json ${rec.json}");
  // print("rec.json[cQty] ${rec.json[cQty]}");
  // print("rec.json['op'] ${rec.json['op']}");
  // print("rec.json['op']?[cQty] ${rec.json['op']?[cQty]}");
  return rec.json[cQty] ?? rec.json['op']?[cQty] ?? '';
}));

Field fCost = Field(cCost, CalculatedType((MemoryItem rec) async {
  return rec.json[cCost] ?? rec.json['op']?[cCost] ?? '';
}));

Field fDesc = Field('description', CalculatedType((MemoryItem rec) async {
  // print("_rec_: ${rec.json}");
  // print("WHTransactionsBuilder entity: $entity");
  final t = rec.json[cType];
  if (t == 'open_balance' || t == 'close_balance') {
    return 'balance|${rec.json[cDate]}';
  } else {
    final response = await Api.feathers().get(
        serviceName: "memories",
        objectId: rec.id,
        params: {"oid": Api.instance.oid, "ctx": []}).onError((error, stackTrace) => {});

    final Map map = response == {} ? response : Map.from(response);

    final id = map[cDocument] ?? map[cOrder] ?? "";

    final split = id.toString().split('/');

    final ctx = split.length >= 3 ? split.sublist(0, 3) : [];

    final document = await Api.feathers().get(
        serviceName: "memories",
        objectId: id,
        params: {"oid": Api.instance.oid, "ctx": ctx}).onError((error, stackTrace) => {});
    final Map<String, dynamic> mapDoc = document == {} ? document : Map.from(document);

    final date = mapDoc[cDate] ?? "?";

    String store = '';
    String counterparty = '';

    final mapId = map[cId] ?? '';
    final mapSplit = mapId.toString().split('/');

    var type = mapSplit.length >= 2 ? mapSplit[1] : ctx[1];

    if (type == 'produce') {
      type = 'produced';
      store = "";
      counterparty = "";
    } else if (type == 'transfer') {
      store = mapDoc[cFrom]?[cName] ?? "?";
      counterparty = mapDoc[cInto]?[cName] ?? "?";
    } else if (type == 'receive') {
      counterparty = mapDoc[cCounterparty]?[cName] ?? "?";
      store = mapDoc[cStorage]?[cName] ?? "?";
    } else if (type == 'dispatch') {
      counterparty = mapDoc[cCounterparty]?[cName] ?? "?";
      store = mapDoc[cStorage]?[cName] ?? "?";
    } else if (type == 'material') {
      type = '${mapSplit[2]} $type';
    }

    return '$type|$date|$store|$counterparty';
  }
}));

class WHTransactionsBuilder extends StatelessWidget {
  final MemoryItem entity;

  const WHTransactionsBuilder(this.entity, {super.key});

  @override
  Widget build(BuildContext context) {
    final schema = [
      fDesc,
      fType,
      fQty,
      fCost,
    ];

    final store = fStorage.resolve(entity.json);
    final goods = fGoods.resolve(entity.json);

    final filter = {
      'dates': {cFrom: '2022-01-01', 'till': Utils.today()},
      cStorage: store.uuid,
      cGoods: goods.uuid,
      'batch_id': entity.json[cBatch]['id'],
      'batch_date': entity.json[cBatch][cDate],
    };

    // print("FILTER: $filter");

    return BlocBuilder<UiBloc, UiState>(
      builder: (context, uiState) => MemoryBlocHolder(
        init: (bloc) => bloc.add(MemoryFetch('inventory', const [], schema: schema, filter: filter)),
        child: screen(context, uiState, schema, filter, store),
      ),
    );
  }

  Widget screen(
      BuildContext context, UiState uiState, List<Field> schema, Map<String, dynamic> filter, MemoryItem store) {
    final localization = AppLocalizations.of(context);

    return MemoryList(
      mode: Mode.mobile,
      service: 'inventory',
      ctx: const [],
      schema: schema,
      filter: filter,
      title: (MemoryItem item) {
        return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("${fQty.resolve(item.json)}"),
          Text(Number.format(fCost.resolve(item.json))),
        ]);
      },
      subtitle: (MemoryItem item) {
        final description = fDesc.resolve(item.json);
        final parts = description.split('|');
        final type = parts[0] ?? '';
        if (parts.length == 2) {
          return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("$type"),
            Text(DT.format(parts[1])),
          ]);
        } else if (parts.length == 4) {
          var details = parts[2];
          if (store.name() == details) {
            details = type == 'transfer' ? '>> ${parts[3]}' : parts[3];
          } else {
            details = type == 'transfer' ? '${parts[2]} >>' : parts[2];
          }
          return Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(localization.translate(type)),
              const Text(''),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('$details'),
              Text(DT.format(parts[1])),
            ])
          ]);
        } else {
          return Text(description);
        }
      },
      onTap: (context, item) async {
        // print("click ${item.json}");
        final record =
            await Api.feathers().get(serviceName: "memories", objectId: item.id, params: {'oid': Api.instance.oid});

        // print("record $record");
        final docId = record[cDocument];
        if (docId != null) {
          final document =
              await Api.feathers().get(serviceName: "memories", objectId: docId, params: {'oid': Api.instance.oid});

          // print("document $document");

          final id = document[cId] ?? '';
          List<String> parts = id.toString().split('/');

          List<String> ctx = parts.length >= 2 ? parts.sublist(0, parts.length - 1) : [];
          if (ctx.isNotEmpty) {
            final entity = MemoryItem.from(document);
            // print("ctx $ctx");
            context.read<UiBloc>().add(ChangeView(ctx, entity: entity));
          }
        }
      },
      // Text(
      // '${fType.resolve(item.json)} ${fQtySingle.resolve(item.json)} ${fUomAtGoods.resolve(entity.json)?.name() ?? ''}'),
      // onTap: (MemoryItem item) =>
      //     context.read<UiBloc>().add(ChangeView(WHBalance.ctx, entity: item)),
    );
  }
}

class WHBalanceProduced extends StatefulWidget {
  final MemoryItem order;

  const WHBalanceProduced({super.key, required this.order});

  @override
  State<StatefulWidget> createState() => _WHBalanceProducedState();
}

class _WHBalanceProducedState extends State<WHBalanceProduced> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_WHBalanceEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  final MemoryItem details = MemoryItem(id: '', json: {cDate: Utils.today()});

  String status = "register";

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
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
                readOnly: true,
              ),
              ElevatedButton(
                onPressed: status == 'register' ? _print : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(localization.translate('print')),
              )
            ])
          ]))
    ];
    return ScrollableListView(
      children: widgets,
    );
  }

  void _print() async {
    setState(() => status = "connecting");
    try {
      // print("pressed:");

      final data = _formKey.currentState?.value;
      if (data == null) {
        return;
      }

      // print("data $data");

      final printer = data[cPrinter];

      final ip = printer.json['ip'];
      final port = int.parse(printer.json['port']);

      // print("printer $ip $port");

      final order = await widget.order.enrich([
        fProduct,
      ]);

      // print("order ${order.json}");

      final operationId = order.json[cBatch]['id'] ?? '';

      final operation = await Api.feathers().get(serviceName: "memories", objectId: operationId, params: {
            "oid": Api.instance.oid,
            "ctx": [],
          }) ??
          '';

      // print("operation $operation");

      final documentId = operation[cDocument] ?? '';

      final split = documentId.toString().split('/');

      final ctx = split.length >= 3 ? split.sublist(0, 3) : [];

      final document = await Api.feathers().get(serviceName: "memories", objectId: documentId, params: {
            "oid": Api.instance.oid,
            "ctx": ctx,
          }) ??
          '';

      // print("document $document");

      final counterpartyId = document[cCounterparty] ?? '';
      final counterparty = await Api.feathers().get(serviceName: "memories", objectId: counterpartyId, params: {
            "oid": Api.instance.oid,
            "ctx": ["counterparty"],
          }) ??
          '';

      // print("counterparty $counterparty");

      final goods = order.json[cGoods].json;
      final goodsName = goods[cName] ?? '';
      final goodsUuid = goods[cUuid] ?? '';
      final goodsId = goods[cId] ?? '';

      final batch = order.json[cBatch];

      final batchDate = batch[cDate] ?? '';
      final batchBarcode = batch[cBarcode] ?? '';

      final supplier = counterparty[cName] ?? '';

      final qty = operation[cQty][cNumber] ?? 0;

      final uom = goods[cUom] ?? '';
      final uomName = uom is MemoryItem ? (uom.json[cName] ?? '') : '';

      final result = await Labels.connect(ip, port, (printer) async {
        setState(() => status = "printing");

        final dd = DateFormat.yMMMMd().format(DateTime.parse(batchDate));

        final Map<String, String> labelData = {
          "количество": "$qty $uomName",
          "товар": "$goodsName",
          "line1": "",
          "поставщик": supplier,
          "приход от": dd,
        };

        Labels.lines_with_barcode(
            printer, goodsName, goodsUuid, goodsId, batchBarcode, operationId, batchDate, labelData);

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
