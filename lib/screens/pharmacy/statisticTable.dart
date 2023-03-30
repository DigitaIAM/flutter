import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class StatisticTable extends StatefulWidget {
  const StatisticTable({super.key});

  @override
  State<StatisticTable> createState() => _StatisticTableState();
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

class _StatisticTableState extends State<StatisticTable> {
  late EmployeeDataSource _employeeDataSource;

  List<Employee> _employees = <Employee>[];

  ThemeMode _themeMode = ThemeMode.system;
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
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
              title: const Text('Pharmacy'),
              actions: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(),
                          onPressed: () {
                            changeTheme(ThemeMode.light);
                          },
                          child: const Icon(Icons.light_mode_rounded)),
                    )),
                Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(),
                          onPressed: () {
                            changeTheme(ThemeMode.dark);
                          },
                          child: const Icon(
                            Icons.dark_mode_rounded,
                            color: Color.fromARGB(255, 0, 0, 0),
                          )),
                    )),
              ],
            ),
            body: Column(children: <Widget>[
              Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
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
                                          position: GridTableSummaryRowPosition
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
                                              ))),
                                    ],
                                    stackedHeaderRows: <StackedHeaderRow>[
                                      StackedHeaderRow(cells: [
                                        StackedHeaderCell(
                                            columnNames: ['price', 'pDiscount'],
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
                                    ]),
                              )),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 16),
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            border: UnderlineInputBorder(),
                                            labelText: 'Enter a search item',
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 16),
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            border: UnderlineInputBorder(),
                                            labelText: 'Enter a search item',
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 16),
                                          child: Text.rich(
                                            TextSpan(
                                              text: 'Amount: ',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight
                                                      .bold), // default text style
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: '0.00',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 206))),
                                              ],
                                            ),
                                          )),
                                      const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 16),
                                          child: Text.rich(
                                            TextSpan(
                                              text: 'Discount: ',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight
                                                      .bold), // default text style
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: '0.00',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 206))),
                                              ],
                                            ),
                                          )),
                                      const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 16),
                                          child: Text.rich(
                                            TextSpan(
                                              text: 'Payable: ',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight
                                                      .bold), // default text style
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: '0.00',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 206))),
                                              ],
                                            ),
                                          )),
                                    ],
                                  ),
                                ],
                              )),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
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
                                          position: GridTableSummaryRowPosition
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
                                              ))),
                                    ],
                                    stackedHeaderRows: <StackedHeaderRow>[
                                      StackedHeaderRow(cells: [
                                        StackedHeaderCell(
                                            columnNames: ['price', 'pDiscount'],
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
                                    ]),
                              ))
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Column(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size.fromHeight(50), // NEW
                                      ),
                                      onPressed: () {
                                        /* do something here */
                                      },
                                      icon: const Icon(Icons.money),
                                      label: const Text(
                                        "Cash",
                                        style: TextStyle(color: Colors.white),
                                      ))),
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size.fromHeight(50), // NEW
                                      ),
                                      onPressed: () {
                                        /* do something here */
                                      },
                                      icon: const Icon(Icons.card_giftcard),
                                      label: const Text(
                                        "Humo",
                                        style: TextStyle(color: Colors.white),
                                      ))),
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size.fromHeight(50), // NEW
                                      ),
                                      onPressed: () {
                                        /* do something here */
                                      },
                                      icon: const Icon(Icons.card_membership),
                                      label: const Text(
                                        "UzCard",
                                        style: TextStyle(color: Colors.white),
                                      ))),
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        // backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                                        minimumSize:
                                            const Size.fromHeight(50), // NEW
                                      ),
                                      onPressed: () {
                                        /* do something here */
                                      },
                                      icon: const Icon(Icons.other_houses),
                                      label: const Text(
                                        "Others",
                                        style: TextStyle(color: Colors.white),
                                      ))),
                            ],
                          ))
                    ],
                  )
                ],
              )
            ])));
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
