import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/config/size_config.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pluto_grid/pluto_grid.dart';

import '../../api.dart';

class WHReceive {
  final Map<String,dynamic> data;

  WHReceive({required this.data});
}

class WHReceiveDoc extends StatefulWidget {
  final WHReceive doc;

  const WHReceiveDoc({
    Key? key,
    required this.doc,
  }) : super(key: key);

  @override
  State<WHReceiveDoc> createState() => _WHReceiveDocState();
}

class _WHReceiveDocState extends State<WHReceiveDoc> {

  TextEditingController numberController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController counterpartyController = TextEditingController();
  TextEditingController storageController = TextEditingController();

  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'goods',
      field: 'goods',
      type: PlutoColumnType.text(),
      width: 200,
      enableColumnDrag: false,
      enableSorting: false,
      enableContextMenu: false,
      enableDropToResize: true,
      enableFilterMenuItem: false,
      enableHideColumnMenuItem: false,
      enableSetColumnsMenuItem: false,
      enableAutoEditing: false,
      enableEditingMode: true,
    ),
    PlutoColumn(
      title: 'uom',
      field: 'uom',
      readOnly: true,
      type: PlutoColumnType.text(),
      width: 75,
      enableColumnDrag: false,
      enableSorting: false,
      enableContextMenu: false,
      enableDropToResize: true,
      enableFilterMenuItem: false,
      enableHideColumnMenuItem: false,
      enableSetColumnsMenuItem: false,
      enableAutoEditing: false,
      enableEditingMode: true,
    ),
    PlutoColumn(
      title: 'qty',
      field: 'qty',
      type: PlutoColumnType.number(negative: false, format: "#,###.###"),
      textAlign: PlutoColumnTextAlign.end,
      width: 100,
      enableColumnDrag: false,
      enableSorting: false,
      enableContextMenu: false,
      enableDropToResize: true,
      enableFilterMenuItem: false,
      enableHideColumnMenuItem: false,
      enableSetColumnsMenuItem: false,
      enableAutoEditing: false,
      enableEditingMode: true,
    ),
    PlutoColumn(
      title: 'price',
      field: 'price',
      type: PlutoColumnType.number(negative: false, format: "#,###.###"),
      textAlign: PlutoColumnTextAlign.end,
      width: 100,
      enableColumnDrag: false,
      enableSorting: false,
      enableContextMenu: false,
      enableDropToResize: true,
      enableFilterMenuItem: false,
      enableHideColumnMenuItem: false,
      enableSetColumnsMenuItem: false,
      enableAutoEditing: false,
      enableEditingMode: true,
    ),
    PlutoColumn(
      title: 'cost',
      field: 'cost',
      type: PlutoColumnType.number(negative: false, format: "#,###.##"),
      textAlign: PlutoColumnTextAlign.end,
      width: 100,
      enableColumnDrag: false,
      enableSorting: false,
      enableContextMenu: false,
      enableDropToResize: false,
      enableFilterMenuItem: false,
      enableHideColumnMenuItem: false,
      enableSetColumnsMenuItem: false,
      enableAutoEditing: false,
      enableEditingMode: true,
    ),
  ];

  final List<PlutoRow> rows = [
    PlutoRow(
      cells: {
        'goods': PlutoCell(value: '1 goods'),
        'uom': PlutoCell(value: 'uom'),
        'qty': PlutoCell(value: 20),
        'price': PlutoCell(value: 2),
        'cost': PlutoCell(value: 40),
      }
    ),
    PlutoRow(
      cells: {
        'goods': PlutoCell(value: '2 goods'),
        'uom': PlutoCell(value: 'uom'),
        'qty': PlutoCell(value: 20),
        'price': PlutoCell(value: 2),
        'cost': PlutoCell(value: 40),
      },
    ),
    PlutoRow(
      cells: {
        'goods': PlutoCell(value: '3 goods'),
        'uom': PlutoCell(value: 'uom'),
        'qty': PlutoCell(value: 20),
        'price': PlutoCell(value: 2),
        'cost': PlutoCell(value: 40),
      },
    ),
    PlutoRow(
      cells: {
        'goods': PlutoCell(value: '4 goods'),
        'uom': PlutoCell(value: 'uom'),
        'qty': PlutoCell(value: 20),
        'price': PlutoCell(value: 2),
        'cost': PlutoCell(value: 40),
      },
    ),
    PlutoRow(
      cells: {
        'goods': PlutoCell(value: '5 goods'),
        'uom': PlutoCell(value: 'uom'),
        'qty': PlutoCell(value: 20),
        'price': PlutoCell(value: 2),
        'cost': PlutoCell(value: 40),
      },
    ),
    PlutoRow(
      cells: {
        'goods': PlutoCell(value: '6 goods'),
        'uom': PlutoCell(value: 'uom'),
        'qty': PlutoCell(value: 20),
        'price': PlutoCell(value: 2),
        'cost': PlutoCell(value: 40),
      },
    ),
    PlutoRow(
      cells: {
        'goods': PlutoCell(value: '7 goods'),
        'uom': PlutoCell(value: 'uom'),
        'qty': PlutoCell(value: 20),
        'price': PlutoCell(value: 2),
        'cost': PlutoCell(value: 40),
      },
    ),
    PlutoRow(
      cells: {
        'goods': PlutoCell(value: '8 goods'),
        'uom': PlutoCell(value: 'uom'),
        'qty': PlutoCell(value: 20),
        'price': PlutoCell(value: 2),
        'cost': PlutoCell(value: 40),
      },
    ),
    PlutoRow(
      cells: {
        'goods': PlutoCell(value: '9 goods'),
        'uom': PlutoCell(value: 'uom'),
        'qty': PlutoCell(value: 20),
        'price': PlutoCell(value: 2),
        'cost': PlutoCell(value: 40),
      },
    ),
  ];

  // final List<PlutoColumnGroup> columnGroups = [
  //   PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: true),
  //   PlutoColumnGroup(title: 'User information', fields: ['name', 'age']),
  //   PlutoColumnGroup(title: 'Status', children: [
  //     PlutoColumnGroup(title: 'A', fields: ['role'], expandedColumn: true),
  //     PlutoColumnGroup(title: 'Etc.', fields: ['joined', 'working_time']),
  //   ]),
  // ];

  late final PlutoGridStateManager stateManager;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = Provider.of<MySettings>(context);

    final config = PlutoGridConfiguration.dark(
      enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
      style: PlutoGridStyleConfig.dark(
        gridBackgroundColor: theme.canvasColor,
        rowColor: theme.canvasColor,
      )
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Receive"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: TextFormField(
                    controller: dateController,
                    enabled: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixStyle: const TextStyle(color: Colors.red),
                      labelText: AppLocalizations.of(context).translate("number"),
                      border: const OutlineInputBorder(),
                    ),
                  ),),
                  const SizedBox(width: 4),
                  Expanded(child: TextFormField(
                    autofocus: true,
                    controller: dateController,
                    enabled: true,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixStyle: const TextStyle(color: Colors.red),
                      labelText: AppLocalizations.of(context).translate("date"),
                      border: const OutlineInputBorder(),
                    ),
                  ),),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: counterpartyController,
                enabled: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  isDense: true,
                  prefixStyle: const TextStyle(color: Colors.red),
                  labelText: AppLocalizations.of(context).translate("counterparty"),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: storageController,
                enabled: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  isDense: true,
                  prefixStyle: const TextStyle(color: Colors.red),
                  labelText: AppLocalizations.of(context).translate("storage"),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                // width: double.infinity,
                height: SizeConfig.blockSizeVertical! * 40,
                child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  // columnGroups: columnGroups,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                    stateManager.setShowColumnFooter(true);
                  },
                  onChanged: (PlutoGridOnChangedEvent event) {
                    print(event);
                  },
                  configuration: config,
                ),
              ),
            ),
          ]
        ),
      )
    );
  }

  // getDialogBody(MySettings settings, String _id, dynamic _row) {
  //   numberController.text = "";
  //   dateController.text = "";
  //   counterpartyController.text = "";
  //   storageController.text = "";
  //   if (_row != null) {
  //     print(_row);
  //     numberController.text = _row["number"];
  //     dateController.text = _row["date"];
  //     counterpartyController.text = _row["counterparty"];
  //     storageController.text = _row["storage"];
  //   }
  //
  //   return SingleChildScrollView(
  //     child: Container(
  //       width: 420,
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         children: [
  //           Row(
  //             children: [
  //               Expanded(child: Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Center(child: Text(
  //                   AppLocalizations.of(context).translate("receive"),
  //                   style: Theme.of(context).textTheme.headline6,
  //                 )),
  //               ),),
  //               IconButton(onPressed: () { Navigator.pop(context); }, icon: const Icon(Icons.close))
  //             ],
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Row(
  //               children: [
  //                 Expanded(child: TextFormField(
  //                   controller: numberController,
  //                   enabled: true,
  //                   decoration: InputDecoration(
  //                     isDense: true,
  //                     prefixStyle: const TextStyle(color: Colors.red),
  //                     labelText: AppLocalizations.of(context).translate("number"),
  //                     border: const OutlineInputBorder(),
  //                   ),
  //                 ),),
  //                 const SizedBox(width: 4),
  //                 Expanded(child: TextFormField(
  //                   controller: dateController,
  //                   enabled: true,
  //                   decoration: InputDecoration(
  //                     isDense: true,
  //                     prefixStyle: const TextStyle(color: Colors.red),
  //                     labelText: AppLocalizations.of(context).translate("date"),
  //                     border: const OutlineInputBorder(),
  //                   ),
  //
  //                 ),),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: TextFormField(
  //               controller: counterpartyController,
  //               enabled: true,
  //               decoration: InputDecoration(
  //                 isDense: true,
  //                 prefixStyle: const TextStyle(color: Colors.red),
  //                 labelText: AppLocalizations.of(context).translate("counterparty"),
  //                 border: const OutlineInputBorder(),
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: TextFormField(
  //               controller: storageController,
  //               enabled: true,
  //               decoration: InputDecoration(
  //                 isDense: true,
  //                 prefixStyle: const TextStyle(color: Colors.red),
  //                 labelText: AppLocalizations.of(context).translate("storage"),
  //                 border: const OutlineInputBorder(),
  //               ),
  //             ),
  //           ),
  //           Scaffold(
  //             body: PlutoGrid(
  //               columns: columns,
  //               rows: rows,
  //               columnGroups: columnGroups,
  //               onLoaded: (PlutoGridOnLoadedEvent event) {
  //                 stateManager = event.stateManager;
  //                 stateManager.setShowColumnFilter(true);
  //               },
  //               onChanged: (PlutoGridOnChangedEvent event) {
  //                 print(event);
  //               },
  //               configuration: const PlutoGridConfiguration(),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Row(
  //               children: [
  //                 const Expanded(child: Text("")),
  //                 ElevatedButton(onPressed: () async {
  //                   if (_id == "") {
  //                     await Api.feathers().create(serviceName: "docs", data: {
  //                       "oid": settings.companyId,
  //                       "number": numberController.text,
  //                       "date": dateController.text,
  //                       "counterparty": counterpartyController.text,
  //                       "storage": storageController.text,
  //                     });
  //                   } else {
  //                     await Api.feathers().patch(serviceName: "docs", objectId: _id, data: {
  //                       "oid": settings.companyId,
  //                       "number": numberController.text,
  //                       "date": dateController.text,
  //                       "counterparty": counterpartyController.text,
  //                       "storage": storageController.text,
  //                     });
  //                   }
  //                   Navigator.pop(context);
  //                 }, child: Text(AppLocalizations.of(context).translate("save"))),
  //               ],
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
