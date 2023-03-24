import 'dart:async';
import 'dart:io';

import 'package:windows1251/windows1251.dart';

class NetworkPrinter {
  late Socket _socket;

  Future<PrintResult> connect(String host, {int port = 9100, Duration timeout = const Duration(seconds: 15)}) async {
    try {
      _socket = await Socket.connect(host, port, timeout: timeout);
      // _socket.add(_generator.reset());
      return Future<PrintResult>.value(PrintResult.success);
    } catch (e) {
      print(e);
      return Future<PrintResult>.value(PrintResult.timeout);
    }
  }

  void disconnect({int? delayMs}) async {
    _socket.destroy();
    if (delayMs != null) {
      await Future.delayed(Duration(milliseconds: delayMs), () => null);
    }
  }

  Future sendCommand(String command) async {
    // final List<int> com = utf8.encode(command);
    final com = windows1251.encode(command);
    _socket.add(com);
  }

  void selftest() {
    sendCommand('SELFTEST \r\n');

    // omitted: Print a self-test page with whole printer information.
    // PATTERN: Print a pattern to check the status of print head heat line.
    // ETHERNET: Print a self-test page with Ethernet settings.
    // WLAN: Print a self-test page with Wi-Fi settings.
    // RS232: Print a self-test page with RS-232 settings.
    // SYSTEM: Print a self-test page with printer settings.
    // Z: Print a self-test page with emulated language settings.
    // BT: Print a self-test page with Bluetooth settings.
  }

  void clear() {
    sendCommand('CLS \r\n');
  }

  void codepage({String name = "UTF-8"}) {
    sendCommand('CODEPAGE $name \r\n');
  }

  void direction({int n = 1, int m = 0}) {
    sendCommand('DIRECTION $n,$m \r\n');
  }

  // Label Formatting Commands
  void bar(int x, int y, int width, int height) {
    sendCommand('BAR $x,$y,$width,$height \r\n');
  }

  void dmatrix(int x, int y, int width, int height, String content) {
    sendCommand('DMATRIX $x,$y,$width,$height, "$content" \r\n');
  }

  // QRCODE x,y,ECC Level,cell width,mode,rotation,[justification,]model,]mask,]area],]length]"content"
  void qrcode(
    int x,
    int y,
    String content, {
    String eccLevel = 'H',
    int cellWidth = 4,
    String mode = 'A',
    int rotation = 0,
  }) {
    sendCommand('QRCODE $x,$y,$eccLevel,$cellWidth,$mode,$rotation,M2,"$content"\r\n');
  }

  void text(int x, int y, String content,
      {String font = "1", int rotation = 0, int mx = 1, int my = 1, int alignment = 0
      // 0 : Default (Left)
      // 1 : Left
      // 2 : Center
      // 3 : Right
      }) {
    sendCommand('TEXT $x,$y,"$font",$rotation,$mx,$my,$alignment,"$content"\r\n');
  }

  void barcode(int x, int y, String barcode,
      {String font = "1", int rotation = 0, int mx = 1, int my = 1, int alignment = 0
      }) {
    sendCommand('BARCODE $x,$y,"$font",$rotation,$mx,$my,$alignment,"$barcode"\r\n');
  }

  void feed(int i) {
    sendCommand('FEED $i \r\n');
  }

  void cut() {
    sendCommand('CUT \r\n');
  }

  void print_({int copies = 1}) {
    sendCommand('PRINT $copies \r\n');
  }
}

class PrintResult {
  const PrintResult._internal(this.value);

  final int value;
  static const success = PrintResult._internal(1);
  static const timeout = PrintResult._internal(2);
  static const printerNotSelected = PrintResult._internal(3);
  static const ticketEmpty = PrintResult._internal(4);
  static const printInProgress = PrintResult._internal(5);
  static const scanInProgress = PrintResult._internal(6);

  String get msg {
    if (value == PrintResult.success.value) {
      return 'Success';
    } else if (value == PrintResult.timeout.value) {
      return 'Error. Printer connection timeout';
    } else if (value == PrintResult.printerNotSelected.value) {
      return 'Error. Printer not selected';
    } else if (value == PrintResult.ticketEmpty.value) {
      return 'Error. Ticket is empty';
    } else if (value == PrintResult.printInProgress.value) {
      return 'Error. Another print in progress';
    } else if (value == PrintResult.scanInProgress.value) {
      return 'Error. Printer scanning in progress';
    } else {
      return 'Unknown error';
    }
  }
}
