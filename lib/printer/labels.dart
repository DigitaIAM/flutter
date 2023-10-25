import 'package:nae/printer/network_printer.dart';

class Labels {
  static Future<PrintResult> connect(String ip, int port, Future<PrintResult> Function(NetworkPrinter) onReady) async {
    // print("connecting");
    // const PaperSize paper = PaperSize.mm80;
    // final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(); // paper, profile);
    final PrintResult res = await printer.connect(ip, port: port);

    if (res == PrintResult.success) {
      try {
        final res2 = await onReady(printer);
        // print('Printed with result: ${res.msg}');

        // // print("flushing");
        // final f = await printer.flush();
        // // print("flush $f");
        //
        // // print("closeing");
        // final c = await printer.close();
        // // print("close $c");

        return res2;
      } catch (e, stacktrace) {
        // print("error: $e");
        // print(stacktrace);
      } finally {
        printer.disconnect();
      }
    }

    // print('Print result: ${res.msg}');

    return res;
  }

  static void lines(NetworkPrinter printer, String id, Map<String, String> data) {
    printer.clear();
    printer.codepage(name: "1251");
    printer.direction();

    // - printer.text(20, 50, "OOO", font: "5", mx: 1, my: 1);
    // - printer.text(20, 120, "Midas", font: "5", mx: 1, my: 1);
    // - printer.text(20, 190, "Plastics", font: "5", mx: 1, my: 1);

    printer.dmatrix(50, 100, 144, 144, id);

    printer.qrcode(450, 50, id, cellWidth: 7);
    printer.text(780, 50, id, font: "2", mx: 1, my: 1, rotation: 90); // alignment: 3,
    printer.bar(750, 10, 2, 780);

    // - printer.qrcode(
    // -     450, 10, "https://product.midasplastics.uz/2023-01-26T08:19:33.981Z",
    // -     cellWidth: 8);

    var y = 370;
    printer.bar(5, y - 1, 740, 3);
    y += 10;

    for (final entry in data.entries) {
      final name = entry.key;
      final value = entry.value;

      if (name.startsWith("line")) {
        printer.bar(5, y - 1, 740, 3);
        y += 10;
      } else {
        printer.text(195, y, "$name:", font: "3", mx: 1, my: 1, alignment: 3);
        printer.text(180, y, " $value", font: "4", mx: 1, my: 1);
        y += 50;
      }
    }

    // - printer.feed(1);
    // - printer.cut();
    printer.print_();
  }

  static void linesWithBarcode(NetworkPrinter printer, String goodsName, String goodsUuid, String goodsId,
      String batchBarcode, String batchId, String batchDate, Map<String, String> data) {
    printer.clear();
    printer.codepage(name: "1251");
    printer.direction();

    printer.qrcode(60, 50, batchId, cellWidth: 7);

    printer.qrcode(450, 50, goodsUuid, cellWidth: 7);

    printer.text(35, 50, ('$batchId $batchDate'), font: "2", mx: 1, my: 1, rotation: 90);
    printer.bar(50, 10, 2, 780);

    printer.text(780, 50, goodsId, font: "2", mx: 1, my: 1, rotation: 90); // alignment: 3,
    printer.bar(750, 10, 2, 780);

    var y = 350;

    for (final entry in data.entries) {
      final name = entry.key;
      final val = entry.value;

      if (name.startsWith("line")) {
        printer.bar(50, y - 1, 710, 3);
        y += 10;
      } else {
        printer.text(245, y, "$name:", font: "3", mx: 1, my: 1, alignment: 3);

        if (val.length > 20) {
          final len = val.length;
          final count = (len / 20).ceil();
          var start = 0;
          for (var i = 0; i < count; i += 1) {
            var end = (start + 20) > len ? len : start + 20;
            var value = val.substring(start, end);
            if (value.startsWith(' ')) {
              value = value.substring(1);
            }
            printer.text(230, y, " $value", font: "4", mx: 1, my: 1);
            // print("${val.substring(start, end)}");
            start += 20;
            y += 35;
          }
        } else {
          printer.text(230, y, " $val", font: "4", mx: 1, my: 1);
          // print("$val");
        }

        y += 40;
      }
    }

    y += 25;

    printer.barcode_EAN13(225, y, batchBarcode);

    printer.print_();
  }
}
