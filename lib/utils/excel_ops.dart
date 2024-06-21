import 'package:decimal/decimal.dart';
import 'package:excel/excel.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class ExcelOps {
  static void exportToExcel(
    List<PlutoColumn> columns,
    List<PlutoColumnGroup> groups,
    List<PlutoRow> rows,
  ) {
    Excel excel = Excel.createExcel();

    final s = excel.getDefaultSheet();
    if (s != null) {
      excel.rename(s, 'Sheet');
    }
    Sheet sheet = excel['Sheet'];

    List<CellValue> list = [];

    List<(int, int, String)> toMerge = [];
    int index = 0;
    (int, String) last = (-1, '');

    for (PlutoColumn col in columns) {
      for (PlutoColumnGroup group in groups) {
        if (group.fields?[0] == col.field) {
          if (last.$1 != -1 && last.$1 != index - 1) {
            toMerge.add((last.$1, index - 1, last.$2));
          }
          last = (index, group.title);
        }
      }
      index += 1;
    }
    if (last.$1 != -1 && last.$1 != index - 1) {
      toMerge.add((last.$1, index - 1, last.$2));
    }

    for (final item in toMerge) {
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: item.$1, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: item.$2, rowIndex: 0),
        customValue: TextCellValue(item.$3),
      );
    }

    list = [];
    for (PlutoColumn col in columns) {
      list.add(TextCellValue(col.title));
    }
    sheet.appendRow(list);

    for (PlutoRow row in rows) {
      list = [];
      for (PlutoColumn col in columns) {
        final v = row.cells[col.field]?.value;

        if (v is Decimal) {
          if (v.isInteger) {
            list.add(IntCellValue(v.toBigInt().toInt()));
          } else {
            list.add(DoubleCellValue(v.toDouble()));
          }
        } else {
          list.add(TextCellValue(v?.toString() ?? ''));
        }
      }
      sheet.appendRow(list);
    }

    excel.save(fileName: "export.xlsx");
  }
}
