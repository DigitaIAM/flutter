import 'package:flutter/material.dart';
import 'package:nae/schema/schema.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class HomePage1 extends StatefulWidget {
  const HomePage1({super.key});

  @override
  State<HomePage1> createState() => _HomePage1State();
}

class Employee {
  Employee(this.description, this.qty, this.price, this.pDiscount, this.amount,
      this.aDiscount, this.eDate, this.series, this.sLocation);
  final String description;
  final int qty;
  final int price;
  final int pDiscount;
  final int amount;
  final int aDiscount;
  final String eDate;
  final String series;
  final String sLocation;
}

class _HomePage1State extends State<HomePage1> {
  late EmployeeDataSource _employeeDataSource;

  List<Employee> _employees = <Employee>[];

  @override
  void initState() {
    super.initState();
    _employees = getEmployeeData();
    _employeeDataSource = EmployeeDataSource(employees: _employees);
  }

  List<Employee> getEmployeeData() {
    return [
      Employee('description text', 100, 1000, 900, 10, 9, '2023, 3, 27',
          'Computer', 'www.www'),
      Employee('description text', 100, 1000, 900, 10, 9, '2023, 3, 27',
          'Computer', 'www.www'),
      Employee('description text', 100, 1000, 900, 10, 9, '2023, 3, 27',
          'Computer', 'www.www'),
      Employee('description text', 100, 1000, 900, 10, 9, '2023, 3, 27',
          'Computer', 'www.www'),
      Employee('description text', 100, 1000, 900, 10, 9, '2023, 3, 27',
          'Computer', 'www.www'),
      Employee('description text', 100, 1000, 900, 10, 9, '2023, 3, 27',
          'Computer', 'www.www'),
      Employee('description text', 100, 1000, 900, 10, 9, '2023, 3, 27',
          'Computer', 'www.www'),
      Employee('description text', 100, 1000, 900, 10, 9, '2023, 3, 27',
          'Computer', 'www.www'),
      Employee('description text', 100, 1000, 900, 10, 9, '2023, 3, 27',
          'Computer', 'www.www'),
      Employee('description text', 100, 1000, 900, 10, 9, '2023, 3, 27',
          'Computer', 'www.www')
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfDataGrid(
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          source: _employeeDataSource,
          onQueryRowHeight: (RowHeightDetails details) {
            if (details.rowIndex == 0) {
              return 70.0;
            }
            return details.rowHeight;
          },
          columns: <GridColumn>[
            GridColumn(
                columnName: 'description',
                width: 400,
                label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Description',
                      overflow: TextOverflow.ellipsis,
                    ))),
            GridColumn(
                columnName: 'qty',
                label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Quantity',
                      overflow: TextOverflow.ellipsis,
                    ))),
            GridColumn(
                columnName: 'price',
                label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Price',
                      overflow: TextOverflow.ellipsis,
                    ))),
            GridColumn(
                columnName: 'pDiscount',
                label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Discount',
                      overflow: TextOverflow.ellipsis,
                    ))),
            GridColumn(
                columnName: 'amount',
                label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Amount',
                      overflow: TextOverflow.ellipsis,
                    ))),
            GridColumn(
                columnName: 'aDiscount',
                label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Discount',
                      overflow: TextOverflow.ellipsis,
                    ))),
            GridColumn(
                columnName: 'eDate',
                label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Expiry Date',
                      overflow: TextOverflow.ellipsis,
                    ))),
            GridColumn(
                columnName: 'series',
                label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Series',
                      overflow: TextOverflow.ellipsis,
                    ))),
            GridColumn(
                columnName: 'sLocation',
                label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Storage Location',
                      overflow: TextOverflow.ellipsis,
                    ))),
          ],
          stackedHeaderRows: <StackedHeaderRow>[
            StackedHeaderRow(cells: [
              StackedHeaderCell(
                  // columnNames: ['id', 'name'],
                  columnNames: ['price', 'pDiscount'],
                  child: Container(
                      color: const Color(0xFFF1F1F1),
                      child: const Center(child: Text('Price')))),
              StackedHeaderCell(
                  // columnNames: ['designation', 'salary'],
                  columnNames: ['amount', 'aDiscount'],
                  child: Container(
                      color: const Color(0xFFF1F1F1),
                      child: const Center(child: Text('Amount'))))
            ])
          ]),
    );
  }
}

class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource({required List<Employee> employees}) {
    dataGridRows = employees
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'description', value: dataGridRow.description),
              DataGridCell<int>(columnName: 'qty', value: dataGridRow.qty),
              DataGridCell<int>(columnName: 'price', value: dataGridRow.price),
              DataGridCell<int>(
                  columnName: 'pDiscount', value: dataGridRow.pDiscount),
              DataGridCell<int>(
                  columnName: 'amount', value: dataGridRow.amount),
              DataGridCell<int>(
                  columnName: 'aDiscount', value: dataGridRow.aDiscount),
              DataGridCell<String>(
                  columnName: 'eDate', value: dataGridRow.eDate),
              DataGridCell<String>(
                  columnName: 'series', value: dataGridRow.series),
              DataGridCell<String>(
                  columnName: 'sLocation', value: dataGridRow.sLocation),
            ]))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment: (dataGridCell.columnName == 'description' ||
                  dataGridCell.columnName == 'sLocation')
              ? Alignment.center
              : Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }
}
