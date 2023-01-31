
import 'package:flutter/material.dart';
import 'package:nae_hr/printer/network_printer.dart';

class Labels {
  void testPrint(BuildContext ctx) async {
    print("connecting");
    // const PaperSize paper = PaperSize.mm80;
    // final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(); // paper, profile);
    final PrintResult res = await printer.connect('192.168.3.239', port: 9100);

    if (res == PrintResult.success) {
      testReceipt(printer);
      printer.disconnect();
    }

    print('Print result: ${res.msg}');

  }

  void testReceipt(NetworkPrinter printer) {
    printer.clear();
    printer.codepage(name: "1251");
    printer.direction();

    printer.qrcode(450, 10, "https://product.midasplastics.uz/2023-01-26T08:19:33.981Z", cellWidth: 8);

    final data = {
      "продукция": "стакан полипропиленовый",
      "артикуль": "110 Д95 КЭ 420",
      "дата": "24 Января 2023",
      "количество": "640 шт",
      "line1": "",
      "заказчик": "PureMilky",
      "этикетка": "каймак 330",
      "line2": "",
      "оператор": "Кулмурадов",
      "проверил": "Орипов",
    };

    // printer.text(10, 10, "Test Test");
    var y = 370;
    for (final entry in data.entries) {
      final name = entry.key;
      final value = entry.value;

      if (name.startsWith("line")) {
        printer.bar(0,y-2,800,4);
        y += 12;
      } else {
        printer.text(
            195, y, "$name:", font: "3", mx: 1, my: 1, alignment: 3
        );
        printer.text(
            195, y, " $value", font: "4", mx: 1, my: 1
        );
        y += 50;
      }
    }

    // printer.feed(1);
    // printer.cut();
    printer.print_();
  }
}