import 'package:nae/api.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/utils/date.dart';

Future<MemoryItem> register(
    MemoryItem doc,
    Map<String, dynamic> data,
    int numberOfQuantities,
    List ctx,
    void Function(String) onStatusChange) async {
  onStatusChange("registering");

  if (!data.isEmpty) {
    print("data $data");

    print("doc in fn register: ${doc}");

    final goods = data['goods'] as MemoryItem;

    final baseUom = goods.json['uom'];
    final baseUomId = baseUom is Map ? baseUom['_id'] : baseUom;

    MemoryItem from;
    MemoryItem? into;

    if (ctx == const ['warehouse', 'transfer']) {
      final f = doc.json['from'];
      final i = doc.json['into'];

      from = f is MemoryItem ? f : MemoryItem.from(f);
      into = i is MemoryItem ? i : MemoryItem.from(i);
    } else if (ctx == const ['warehouse', 'dispatch']) {
      final storage = doc.json['storage'];
      from = storage is MemoryItem ? storage : MemoryItem.from(storage);

      final counterparty = doc.json['counterparty'];
      into = counterparty is MemoryItem
          ? counterparty
          : MemoryItem.from(counterparty);
    } else if (ctx == const ['production', 'material', 'produced']) {
      final area = doc.json['area'];
      from = area is MemoryItem ? area : MemoryItem.from(area);

      final storage = data['storage'];
      into = storage is MemoryItem ? storage : MemoryItem.from(storage);
    } else if (ctx == const ['production', 'material', 'used']) {
      // print("used: ${doc.json}");
      final storage = data['storage'];
      from = storage is MemoryItem ? storage : MemoryItem.from(storage);
    } else {
      final counterparty = doc.json['counterparty'];
      from = counterparty is MemoryItem
          ? counterparty
          : MemoryItem.from(counterparty);

      final storage = doc.json['storage'];
      into = storage is MemoryItem ? storage : MemoryItem.from(storage);
    }

    final quantity = {}; // 'number': number, 'uom': uom.id
    var currentQty = quantity;
    for (var index = 0; index < numberOfQuantities; index++) {
      final uom = data['uom_$index'] as MemoryItem?;
      if (uom == null) {
        // TODO report error? or raised by saveAndValidate?
        return MemoryItem.create();
      }

      final qty = data['qty_$index'];

      if (index > 0) {
        final newQty = {'number': qty, 'uom': uom.id, 'in': currentQty['uom']};
        currentQty['uom'] = newQty;
        currentQty = newQty;
      } else {
        currentQty['number'] = qty;
        currentQty['uom'] = uom.id;
      }

      if (baseUomId == data['uom_$index']?.id) {
        break;
      }
    }

    final category = data['category'] is MemoryItem
        ? data['category']
        : goods.json['category'];

    final categoryId = category is MemoryItem ? category.id : category;

    final request = {
      'document': doc.id,
      'goods': goods.id,
      'storage_from': from.id,
      'qty': quantity,
    };
    if (into != null) {
      request['storage_into'] = into.id;
    }

    final response = await Api.feathers().create(
        serviceName: 'memories',
        data: request,
        params: {'oid': Api.instance.oid, 'ctx': ctx});

    final result = MemoryItem.from(response);
    print("register result: $result");

    return result;
  } else {
    // TODO raise error instead
    return MemoryItem.create();
  }
}

Future<PrintResult> printing(NetworkPrinter printer, MemoryItem doc,
    MemoryItem record, void Function(String) onStatusChange) async {
  onStatusChange("printing");

  print("printing doc $doc");
  print("printing record $record");

  final goods = record.json['goods'];
  final goodsName = goods is MemoryItem ? goods.name() : (goods['name'] ?? '');
  final goodsUuid = goods is MemoryItem
      ? (goods.json['_uuid'] ?? '')
      : (goods['_uuid'] ?? '');
  final goodsId = goods is MemoryItem ? goods.id : (goods['_id'] ?? '');

  final date = doc.json['date']!;
  // final date = order.json['date'] ?? record.json['date'] ?? '';
  final dd = DT.format(date);

  String batchBarcode = '';
  String batchId = '';
  String batchDate = '';

  final batch = record.json['batch'];
  if (batch != null) {
    batchBarcode = batch['barcode'] ?? '';
    batchId = batch['_uuid'] ?? '';
    batchDate = batch['date'] ?? '';
  }

  var qtyUom = '';

  var qty = record.json['qty'] ?? '';

  while (qty is Map) {
    final uom = qty['uom'];
    if (uom is Map) {
      if (uom['in'] != null) {
        qtyUom = '$qtyUom${qty['number']} ${uom['in']['name']}\nпо ';
      } else {
        qtyUom = '$qtyUom${qty['number']} ${uom['name']} ';
      }
    }
    qty = qty['uom'];
  }

  print('QTYUOM: $qtyUom');

  final Map<String, String> labelData = {
    "материал": goodsName,
    "дата": dd,
    "количество": qtyUom,
    "line1": "",
  };

  MemoryItem from = MemoryItem.empty();

  final counterparty = doc.json['counterparty'];
  if (counterparty != null) {
    from = counterparty is MemoryItem
        ? counterparty
        : MemoryItem.from(counterparty);
    labelData['поставщик'] = from.name();
  }

  final f = doc.json['from'];
  if (f != null) {
    from = f is MemoryItem ? f : MemoryItem.from(f);
    labelData[''] = from.name();
  }

  final area = doc.json['area'];
  if (area != null) {
    from = area is MemoryItem ? area : MemoryItem.from(area);
    labelData['участок'] = from.name();
  }

  // TODO: place length check and line break from lines_with_barcode to this function
  Labels.lines_with_barcode(printer, goodsName, goodsUuid, goodsId,
      batchBarcode, batchId, batchDate, labelData);

  return Future<PrintResult>.value(PrintResult.success);
}
