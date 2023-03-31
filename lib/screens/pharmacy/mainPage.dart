import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'sideBar.dart';
import 'checkBar.dart';

class PharmanyMain extends StatefulWidget {
  const PharmanyMain({super.key});

  @override
  State<PharmanyMain> createState() => _PharmanyMainState();
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

class _PharmanyMainState extends State<PharmanyMain> {
  late EmployeeDataSource _employeeDataSource;
  List<Employee> _employees = <Employee>[];
  bool isSwitched = false;

  ThemeMode _themeMode = ThemeMode.system;
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        changeTheme(ThemeMode.dark);
      });
    } else {
      setState(() {
        isSwitched = false;
        changeTheme(ThemeMode.light);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _employees = getEmployeeData();
    _employeeDataSource = EmployeeDataSource(employees: _employees);
  }

  List<Employee> getEmployeeData() {
    return [
      Employee('description text', 100, 100000, 90000, 10, 9, '3/27/23',
          'Computer', 'www.www'),
      Employee('description text', 100, 100000, 90000, 10, 9, '3/27/23',
          'Computer', 'www.www'),
      Employee('description text', 100, 100000, 90000, 10, 9, '3/27/23',
          'Computer', 'www.www'),
      Employee('description text', 100, 100000, 90000, 10, 9, '3/27/23',
          'Computer', 'www.www'),
      Employee('description text', 100, 100000, 90000, 10, 9, '3/27/23',
          'Computer', 'www.www'),
      Employee('description text', 100, 100000, 90000, 10, 9, '3/27/23',
          'Computer', 'www.www')
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.green),
        darkTheme: ThemeData.dark(),
        themeMode: _themeMode,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: const Padding(
                padding: EdgeInsets.only(left: 100.0),
                child: Text(
                  'Pharmacy',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              actions: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(right: 100.0),
                    child: Switch(
                      onChanged: toggleSwitch,
                      value: isSwitched,
                      activeColor: Colors.blue,
                      activeTrackColor: Colors.blue,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.white,
                    )),
              ],
            ),
            body: Container(
                padding: const EdgeInsets.all(15),
                child: Column(children: <Widget>[
                  IntrinsicHeight(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          IntrinsicHeight(
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  height:
                                      MediaQuery.of(context).size.height * 0.43,
                                  child: SfDataGridTheme(
                                    data: SfDataGridThemeData(
                                        // filterIconColor: Colors.pink,
                                        // filterIconHoverColor: Colors.purple,
                                        ),
                                    child: SfDataGrid(
                                      gridLinesVisibility:
                                          GridLinesVisibility.both,
                                      headerGridLinesVisibility:
                                          GridLinesVisibility.both,
                                      source: _employeeDataSource,
                                      columnWidthMode: ColumnWidthMode.fill,
                                      tableSummaryRows: [
                                        GridTableSummaryRow(
                                            showSummaryInRow: true,
                                            title: 'Total Price: {Sum}',
                                            columns: [
                                              const GridSummaryColumn(
                                                  name: 'Sum',
                                                  columnName: 'price',
                                                  summaryType:
                                                      GridSummaryType.sum)
                                            ],
                                            position:
                                                GridTableSummaryRowPosition
                                                    .bottom)
                                      ],
                                      columns: <GridColumn>[
                                        GridColumn(
                                            columnName: 'description',
                                            width: 200,
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Description',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'qty',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Quantity',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'price',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Price',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'pDiscount',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Discount',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'amount',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Amount',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'aDiscount',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Discount',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'eDate',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Expiry Date',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'series',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Series',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'sLocation',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Storage Location',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                      ],
                                      stackedHeaderRows: <StackedHeaderRow>[
                                        StackedHeaderRow(cells: [
                                          StackedHeaderCell(
                                              columnNames: [
                                                'price',
                                                'pDiscount'
                                              ],
                                              child: const Center(
                                                  child: Text('Price'))),
                                          StackedHeaderCell(
                                              columnNames: [
                                                'amount',
                                                'aDiscount'
                                              ],
                                              child: const Center(
                                                  child: Text('Amount')))
                                        ])
                                      ],
                                    ),
                                  ),
                                ),
                                const VerticalDivider(
                                  width: 18,
                                  thickness: 2,
                                  indent: 0,
                                  endIndent: 0,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    child: checkBar(context))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 18.0,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Center(
                              child: Container(
                                height: 2.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          // ]),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height:
                                      MediaQuery.of(context).size.height * 0.43,
                                  child: SfDataGridTheme(
                                    data: SfDataGridThemeData(
                                        // filterIconColor: Colors.pink,
                                        // filterIconHoverColor: Colors.purple,
                                        ),
                                    child: SfDataGrid(
                                      gridLinesVisibility:
                                          GridLinesVisibility.both,
                                      headerGridLinesVisibility:
                                          GridLinesVisibility.both,
                                      source: _employeeDataSource,
                                      columnWidthMode: ColumnWidthMode.fill,
                                      columns: <GridColumn>[
                                        GridColumn(
                                            columnName: 'description',
                                            width: 200,
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Description',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'qty',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Quantity',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'price',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Price',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'pDiscount',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Discount',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'amount',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Amount',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'aDiscount',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Discount',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'eDate',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Expiry Date',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'series',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Series',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'sLocation',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Storage Location',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                      ],
                                    ),
                                  ))
                            ],
                          )
                        ],
                      ),
                      const VerticalDivider(
                        width: 18,
                        thickness: 2,
                        indent: 0,
                        endIndent: 0,
                        color: Colors.grey,
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.12,
                          child: sideBar(context))
                    ],
                  ))
                ]))));
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
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Text(summaryValue),
    );
  }

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
