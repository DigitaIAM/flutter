import 'package:nae/api.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/utils/date.dart';

Future<MemoryItem> register(MemoryItem doc, Map<String, dynamic> data, int numberOfQuantities, bool isDispatch,
    List ctx, void Function(String) onStatusChange) async {
  onStatusChange("registering");

  if (data.isNotEmpty) {
    // print("data $data");

    // print("doc in fn register: ${doc}");

    final goods = data[cGoods] as MemoryItem;

    final baseUom = goods.json[cUom];
    final baseUomId = baseUom is Map ? baseUom[cId] : baseUom;

    MemoryItem? from;
    MemoryItem? into;
    MemoryItem? storage;

    if (ctx == const ['warehouse', 'transfer']) {
      final f = doc.json[cFrom];
      final i = doc.json[cInto];

      from = f is MemoryItem ? f : MemoryItem.from(f);
      into = i is MemoryItem ? i : MemoryItem.from(i);
    } else if (ctx == const ['warehouse', 'dispatch']) {
      final storage = doc.json[cStorage];
      from = storage is MemoryItem ? storage : MemoryItem.from(storage);

      final counterparty = doc.json[cCounterparty];
      into = counterparty is MemoryItem ? counterparty : MemoryItem.from(counterparty);
    } else if (ctx == const ['production', 'material', 'produced']) {
      final area = doc.json[cArea];
      from = area is MemoryItem ? area : MemoryItem.from(area);

      final storage = data[cStorage];
      into = storage is MemoryItem ? storage : MemoryItem.from(storage);
    } else if (ctx == const ['production', 'material', 'used']) {
      // print("used: ${doc.json}");
      final storage = data[cStorage];
      from = storage is MemoryItem ? storage : MemoryItem.from(storage);
    } else if (ctx == const ['warehouse', 'inventory']) {
      storage = doc.json[cStorage] is MemoryItem ? doc.json[cStorage] : MemoryItem.from(doc.json[cStorage]);
    } else {
      final counterparty = doc.json[cCounterparty];
      from = counterparty is MemoryItem ? counterparty : MemoryItem.from(counterparty);

      final storage = doc.json[cStorage];
      into = storage is MemoryItem ? storage : MemoryItem.from(storage);
    }

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
          final newQty = {cNumber: qty, cUom: uom.json[cUuid] ?? uom.id, 'in': currentQty[cUom]};
          currentQty[cUom] = newQty;
          currentQty = newQty;
        } else {
          currentQty[cNumber] = qty;
          currentQty[cUom] = uom.json['in']?[cUuid] ?? uom.json[cUuid] ?? uom.id;
        }

        if (baseUomId == data['uom_$index']?.id) {
          break;
        }
      }
    }

    // final category = data[cCategory] is MemoryItem
    //     ? data[cCategory]
    //     : goods.json[cCategory];
    //
    // final categoryId = category is MemoryItem ? category.id : category;

    MemoryItem? batch = data[cBatch];

    final request = {
      cDocument: doc.id,
      cGoods: goods.id,
      cQty: quantity,
    };

    if (batch != null) {
      request[cBatch] = batch.json;
    }
    if (from != null) {
      request['storage_from'] = from.id;
    }
    if (into != null) {
      request['storage_into'] = into.id;
    }
    if (storage != null) {
      request[cStorage] = storage.id;
    }

    final response = await Api.feathers()
        .create(serviceName: 'memories', data: request, params: {'oid': Api.instance.oid, 'ctx': ctx});

    final result = MemoryItem.from(response);
    // print("register result: $result");

    return result;
  } else {
    // TODO raise error instead
    return MemoryItem.create();
  }
}

Future<PrintResult> printing(
    NetworkPrinter printer, MemoryItem doc, MemoryItem record, void Function(String) onStatusChange) async {
  onStatusChange("printing");

  // print("printing doc $doc");
  // print("printing record $record");

  final goods = record.json[cGoods];
  final goodsName = goods is MemoryItem ? goods.name() : (goods[cName] ?? '');
  final goodsUuid = goods is MemoryItem ? (goods.json[cUuid] ?? '') : (goods[cUuid] ?? '');
  final goodsId = goods is MemoryItem ? goods.id : (goods[cId] ?? '');

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
    from = counterparty is MemoryItem ? counterparty : MemoryItem.from(counterparty);
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

  // TODO: place length check and line break from lines_with_barcode to this function
  Labels.linesWithBarcode(printer, goodsName, goodsUuid, goodsId, batchBarcode, batchId, batchDate, labelData);

  return Future<PrintResult>.value(PrintResult.success);
}

Future<String> qtyToText(MemoryItem rec) async {
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
  if (text.startsWith(' ')) {
    text = text.substring(1);
  }
  return text;
}
