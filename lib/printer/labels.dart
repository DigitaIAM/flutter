import 'package:nae/printer/network_printer.dart';

class Labels {
  static Future<PrintResult> connect(String ip, int port,
      Future<PrintResult> Function(NetworkPrinter) onReady) async {
    print("connecting");
    // const PaperSize paper = PaperSize.mm80;
    // final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(); // paper, profile);
    final PrintResult res = await printer.connect(ip, port: port);

    if (res == PrintResult.success) {
      try {
        final res2 = await onReady(printer);
        print('Printed with result: ${res.msg}');

        return res2;
      } finally {
        printer.disconnect();
      }
    }

    print('Print result: ${res.msg}');

    return res;
  }

  static void lines(
      NetworkPrinter printer, String id, Map<String, String> data) {
    printer.clear();
    printer.codepage(name: "1251");
    printer.direction();

    // printer.text(20, 50, "OOO", font: "5", mx: 1, my: 1);
    // printer.text(20, 120, "Midas", font: "5", mx: 1, my: 1);
    // printer.text(20, 190, "Plastics", font: "5", mx: 1, my: 1);

    printer.dmatrix(50, 100, 144, 144, id);

    printer.qrcode(450, 50, id, cellWidth: 7);
    printer.text(780, 50, id,
        font: "2", mx: 1, my: 1, rotation: 90); // alignment: 3,
    printer.bar(750, 10, 2, 780);

    // printer.qrcode(
    //     450, 10, "https://product.midasplastics.uz/2023-01-26T08:19:33.981Z",
    //     cellWidth: 8);

    // printer.text(10, 10, "Test Test");
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

    // printer.feed(1);
    // printer.cut();
    printer.print_();
  }

  static void lines_with_barcode(
      NetworkPrinter printer,
      String goodsName,
      String goodsUuid,
      String goodsId,
      String batchBarcode,
      String batchId,
      String batchDate,
      Map<String, String> data) {
    printer.clear();
    printer.codepage(name: "1251");
    printer.direction();

    printer.qrcode(60, 50, batchId, cellWidth: 7);

    printer.qrcode(450, 50, goodsUuid, cellWidth: 7);

    printer.text(35, 50, ('$batchId $batchDate'),
        font: "2", mx: 1, my: 1, rotation: 90);
    printer.bar(50, 10, 2, 780);

    printer.text(780, 50, goodsId,
        font: "2", mx: 1, my: 1, rotation: 90); // alignment: 3,
    printer.bar(750, 10, 2, 780);

    var y = 350;

    for (final entry in data.entries) {
      final name = entry.key;
      // workaround for cut the string off
      final value = (entry.value.length > 22)
          ? entry.value.substring(0, 22)
          : entry.value;

      if (name.startsWith("line")) {
        printer.bar(50, y - 1, 710, 3);
        y += 10;
      } else {
        printer.text(245, y, "$name:", font: "3", mx: 1, my: 1, alignment: 3);

        // if (value.length > 20) {
        //   final split = value.toString().split(' ');
        //   var line = '';
        //   line = '$line${split[0]}';
        //   var count = 0;
        //   for (String str in split.getRange(1, split.length)) {
        //     if (line.length + str.length <= 19) {
        //       line += ' $str';
        //       printer.text(230, y, " $line", font: "4", mx: 1, my: 1);
        //       count++;
        //       y += 30;
        //     } else {
        //       if (str == split.last) {
        //         printer.text(230, y, " $str", font: "4", mx: 1, my: 1);
        //         count++;
        //       } else {
        //         printer.text(230, y, " $line", font: "4", mx: 1, my: 1);
        //         count++;
        //         y += 30;
        //         line = str;
        //       }
        //     }
        //     if (count == 2) {
        //       break;
        //     }
        //   }
        // } else {
        printer.text(230, y, " $value", font: "4", mx: 1, my: 1);
        // }

        y += 40;
      }
    }

    y += 25;

    printer.barcode_EAN13(225, y, batchBarcode);

    printer.print_();
  }
}
