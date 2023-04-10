import 'package:intl/intl.dart';
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
    final baseUomId = goods.json['uom'] as String;

    MemoryItem from;
    MemoryItem into;

    if (ctx == const ['warehouse', 'transfer']) {
      from = doc.json['from'];
      into = doc.json['into'];
    } else if (ctx == const ['warehouse', 'dispatch']) {
      from = doc.json['storage'];
      into = doc.json['counterparty'];
    } else {
      from = doc.json['counterparty'];
      into = doc.json['storage'];
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

    final response =
        await Api.feathers().create(serviceName: 'memories', data: {
      'document': doc.id,
      'goods': goods.id,
      'storage_from': from.id,
      'storage_into': into.id,
      'qty': quantity,
    }, params: {
      'oid': Api.instance.oid,
      'ctx': ctx
    });

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
  final from = doc.json['from'] == null
      ? doc.json['counterparty'] as MemoryItem
      : doc.json['from'] as MemoryItem;

  final dd = DT.format(date);

  final batchBarcode = record.json['batch']['barcode'] ?? '';
  final batchId = record.json['batch']['_uuid'] ?? '';
  final batchDate = record.json['batch']['date'] ?? '';

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
    "поставщик": from.name(),
  };

  // TODO: place length check and line break from lines_with_barcode to this function
  Labels.lines_with_barcode(printer, goodsName, goodsUuid, goodsId,
      batchBarcode, batchId, batchDate, labelData);

  return Future<PrintResult>.value(PrintResult.success);
}
