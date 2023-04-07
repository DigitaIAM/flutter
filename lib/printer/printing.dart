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

    final from = doc.json['from'].json;
    final into = doc.json['into'].json;

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
      'storage_from': from,
      'storage_into': into,
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

Future<PrintResult> printing(
    NetworkPrinter printer,
    MemoryItem doc,
    MemoryItem record,
    int numberOfQuantities,
    void Function(String) onStatusChange) async {
  onStatusChange("printing");

  print("printing $record");

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

  for (var index = 0; index < numberOfQuantities; index++) {
    final uom = record['uom_$index'] ?? '';
    final uomName = uom is MemoryItem ? uom.name() : uom;
    final qty = record['qty_$index'] ?? '';

    qtyUom = '$qtyUom$qty $uomName\n';
  }
  // TODO fix code above like this: (structure of qty is different now)
  // for (var index = 0; index < numberOfQuantities; index++) {
  //   final qty = record.json['qty']['number'];
  //   final uom = record.json['uom'];
  //   final uomName = uom is MemoryItem ? uom.json['in'] : uom;
  //
  //   qtyUom = '$qtyUom$qty $uomName\n';
  // }

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
