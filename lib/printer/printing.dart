import 'package:nae/api.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/utils/date.dart';

Future<MemoryItem> register(
    MemoryItem doc,
    Map<String, dynamic> data,
    int numberOfQuantities,
    bool isDispatch,
    List ctx,
    String? id,
    void Function(String) onStatusChange) async {
  onStatusChange("registering");

  if (data.isNotEmpty) {
    // print("data $data");

    // print("doc in fn register: ${doc}");

    final goods = data[cGoods] as MemoryItem;

    final baseUom = goods.json[cUom];
    final baseUomId = baseUom is Map ? baseUom[cId] : baseUom;

    final quantity = {}; // cNumber: number, cUom: uom.id
    var currentQty = quantity;
    for (var index = 0; index < numberOfQuantities; index++) {
      final uom = data['uom_$index'] as MemoryItem?;
      if (uom == null) {
        // TODO report error? or raised by saveAndValidate?
        return MemoryItem.create();
      }

      final qty = data['qty_$index'];

      if (isDispatch) {
        currentQty[cNumber] = qty;

        if (uom.json['in'] == null) {
          currentQty[cUom] = uom.json[cUuid] ?? uom.id;
        } else {
          currentQty[cUom] = uom.json;
          currentQty = currentQty[cUom];

          while (currentQty['in'] != null) {
            currentQty['in'] = currentQty['in'][cUuid];
            if (currentQty[cUom]['in'] == null) {
              currentQty[cUom] = currentQty[cUom][cUuid];
              break;
            } else {
              currentQty = currentQty[cUom];
            }
            // print("quantity1 $quantity");
            // print("currentQty1 $currentQty");
          }
        }
        print("quantity $quantity");
      } else {
        if (index > 0) {
          final newQty = {
            cNumber: qty,
            cUom: uom.json[cUuid] ?? uom.id,
            'in': currentQty[cUom]
          };
          currentQty[cUom] = newQty;
          currentQty = newQty;
        } else {
          currentQty[cNumber] = qty;
          currentQty[cUom] =
              uom.json['in']?[cUuid] ?? uom.json[cUuid] ?? uom.id;
        }

        if (baseUomId == data['uom_$index']?.id) {
          break;
        }
      }
    }

    Map<String, dynamic> request = {}; // Map.from(data);
    // request.removeWhere((k, v) => k.startsWith("qty_"));
    // request.removeWhere((k, v) => k.startsWith("uom_"));

    request[cDocument] = doc.id;
    if (ctx == const ['production', 'material', 'produced'] ||
        ctx == const ['production', 'material', 'used']) {
      request[cStorage] = data[cStorage].id;
    }
    request[cGoods] = data[cGoods].id;
    final batch = data[cBatch];
    if (batch != null) {
      request[cBatch] = {'id': batch.json['id'], 'date': batch.json['date']};
    }
    request[cQty] = quantity;
    print('save request $request');

    dynamic response;
    if (id == null) {
      response = await Api.feathers().create(
          serviceName: 'memories',
          data: request,
          params: {'oid': Api.instance.oid, 'ctx': ctx});
    } else {
      response = await Api.feathers().update(
          serviceName: 'memories',
          objectId: id,
          data: request,
          params: {'oid': Api.instance.oid, 'ctx': ctx});
    }

    final result = MemoryItem.from(response);
    // print("register result: $result");

    return result;
  } else {
    // TODO raise error instead
    return MemoryItem.create();
  }
}

Future<PrintResult> printing(NetworkPrinter printer, MemoryItem doc,
    MemoryItem record, void Function(String) onStatusChange) async {
  onStatusChange("printing");

  // print("printing doc $doc");
  // print("printing record $record");

  final goods = record.json[cGoods];
  final goodsName = goods is MemoryItem ? goods.name() : (goods[cName] ?? '');
  final goodsUuid =
      goods is MemoryItem ? (goods.json[cUuid] ?? '') : (goods[cUuid] ?? '');
  // final goodsId = goods is MemoryItem ? goods.id : (goods[cId] ?? '');
  final recordId = record.id;

  final date = doc.json[cDate]!;
  // final date = order.json[cDate] ?? record.json[cDate] ?? '';
  final dd = DT.format(date);

  String batchBarcode = '';
  String batchId = '';
  String batchDate = '';

  final batch = record.json[cBatch];
  if (batch != null) {
    batchBarcode = batch[cBarcode] ?? '';
    batchId = batch[cUuid] ?? '';
    batchDate = batch[cDate] ?? '';
  }

  if (batchDate != '') {
    batchDate = DT.format(batchDate);
  }

  final qtyUom = await qtyToText(record);

  // print('QTYUOM: $qtyUom');

  final Map<String, String> labelData = {
    "материал": goodsName,
    "дата": dd,
    "количество": qtyUom,
    "line1": "",
  };

  MemoryItem from = MemoryItem.empty();

  final counterparty = doc.json[cCounterparty];
  if (counterparty != null) {
    from = counterparty is MemoryItem
        ? counterparty
        : MemoryItem.from(counterparty);
    labelData['поставщик'] = from.name();
  }

  final f = doc.json[cFrom];
  if (f != null) {
    from = f is MemoryItem ? f : MemoryItem.from(f);
    labelData[''] = from.name();
  }

  final area = doc.json[cArea];
  if (area != null) {
    from = area is MemoryItem ? area : MemoryItem.from(area);
    labelData['участок'] = from.name();
  }

  if (batchDate != '') {
    labelData['приход'] = batchDate;
  }

  // TODO: place length check and line break from lines_with_barcode to this function
  Labels.linesWithBarcode(printer, goodsName, goodsUuid, recordId, batchBarcode,
      batchId, batchDate, labelData);

  return Future<PrintResult>.value(PrintResult.success);
}

Future<String> qtyToText(MemoryItem rec) async {
  if (rec.json[cQty] is Qty) {
    return rec.json[cQty].toString();
  }

  var text = '';
  // print("_rec_: ${rec.json}");
  Map? map = rec.json[cQty] ?? rec.json['op']?[cQty] ?? '';
  // print('_map $map');
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
          params: {
            "oid": Api.instance.oid,
            "ctx": []
          }).onError((error, stackTrace) => {});
      text = '$text ${obj['name'] ?? ''}';
    } else {
      // print('_uomType ${uom.runtimeType}');
      while (uom is Map) {
        // print('iteration $uom');
        if (uom['uom'] == null && uom['name'] != null) {
          text = '$text ${uom['name'] ?? ''}';
          break;
        }

        var inObj = uom['name'] != null
            ? uom
            : (uom['in']['name'] != null
                ? uom['in']
                : await Api.feathers().get(
                    serviceName: "memories",
                    objectId: uom['in'][cUuid] ?? uom['in'] ?? '',
                    params: {
                        "oid": Api.instance.oid,
                        "ctx": []
                      }).onError((error, stackTrace) =>
                    {print('inObj_error $error, $stackTrace')}));
        // print('inObj $inObj');

        text = '$text ${inObj['name'] ?? ''} по ${uom['number'] ?? ''}';
        // print('_uom $uom');
        if (uom['uom'] is String) {
          var obj = await Api.feathers().get(
              serviceName: "memories",
              objectId: uom['uom'] ?? '',
              params: {
                "oid": Api.instance.oid,
                "ctx": []
              }).onError((error, stackTrace) => {});

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
  if (text.startsWith(' ')) {
    text = text.substring(1);
  }
  return text;
}
