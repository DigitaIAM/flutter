import 'package:intl/intl.dart';
import 'package:nae/api.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';

Future<MemoryItem> register(MemoryItem doc, Map<String, dynamic> data,
    int numberOfQuantities, void Function(String) onStatusChange) async {
  onStatusChange("registering");

  if (!data.isEmpty) {
    print("data $data");

    print("doc in transfer documents: ${doc.json}");

    final goods = data['goods'] as MemoryItem;
    final baseUomId = goods.json['uom'] as String;

    final from = doc.json['from'] as MemoryItem;
    final into = doc.json['into'] as MemoryItem;

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
      'ctx': ['warehouse', 'transfer']
    });

    final result = MemoryItem.from(response);
    print("result: $result");

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

  final goods = record.json['goods'] as MemoryItem;
  final goodsName = goods.name();
  final goodsUuid = goods.json['_uuid'] ?? '';
  final goodsId = goods.id;

  final date = doc.json['date']!;
  final from = doc.json['from'].json;

  final dd = DateFormat.yMMMMd().format(DateTime.parse(date));

  final batchBarcode = record.json['batch']['barcode'] ?? '';
  final batchId = record.json['batch']['_uuid'] ?? '';
  final batchDate = record.json['batch']['date'] ?? '';

  var qtyUom = '';

  // TODO fix code above like this: (structure of qty is different now)
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
    "поставщик": from['name'],
  };

  // TODO: place length check and line break from lines_with_barcode to this function
  Labels.lines_with_barcode(printer, goodsName, goodsUuid, goodsId,
      batchBarcode, batchId, batchDate, labelData);

  return Future<PrintResult>.value(PrintResult.success);
}
