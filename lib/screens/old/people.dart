import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/core/my_settings.dart';
import 'package:provider/provider.dart';

import '../../api.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({Key? key}) : super(key: key);

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  bool _first = true;
  dynamic selectedRow;
  bool showEditForm = false;
  List<dynamic> rows = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController divisionController = TextEditingController();
  TextEditingController subdivisonController = TextEditingController();
  TextEditingController employeeNoStringController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);
    if (_first) {
      getFromServer(settings);
      Api.feathers().listen(
          serviceName: "people",
          fromJson: (e) {
            getFromServer(settings);
          });
      _first = false;
    }

    return Scaffold(
      floatingActionButton: showEditForm
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                selectedRow = null;
                setState(() {
                  showEditForm = true;
                  refreshControllers(settings);
                });
              },
            ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: showEditForm
              ? getBodyForEdit(settings)
              : DataTable2(
                  fixedColumnsColor: Colors.grey,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  border: TableBorder.all(color: Colors.grey.shade200, width: 1),
                  columnSpacing: 8,
                  dataRowHeight: 84,
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade100),
                  headingTextStyle: Theme.of(context).textTheme.bodyLarge,
                  empty: Text(AppLocalizations.of(context).translate("no-data")),
                  columns: [
                    DataColumn2(
                        label: Text(AppLocalizations.of(context).translate("photo"), textAlign: TextAlign.center),
                        fixedWidth: 64),
                    DataColumn2(
                        label: Text(AppLocalizations.of(context).translate("person-name"), textAlign: TextAlign.center),
                        size: ColumnSize.L),
                    DataColumn2(
                        label: Text(AppLocalizations.of(context).translate("gender"), textAlign: TextAlign.center),
                        fixedWidth: 42),
                    DataColumn2(
                        label: Text(AppLocalizations.of(context).translate("person-position"),
                            textAlign: TextAlign.center),
                        size: ColumnSize.M),
                    DataColumn2(
                        label: Text(AppLocalizations.of(context).translate("division"), textAlign: TextAlign.center),
                        size: ColumnSize.M),
                    DataColumn2(
                        label:
                            Text(AppLocalizations.of(context).translate("sub-division"), textAlign: TextAlign.center),
                        size: ColumnSize.M),
                  ],
                  rows: List<DataRow>.generate(rows.length, (index) {
                    return DataRow(color: MaterialStateColor.resolveWith((states) => Colors.white), cells: [
                      DataCell(
                          Image.network(
                            "${Api.server}/v1/picture?oid=${settings.companyId}&pid=" + rows[index]["_id"],
                            errorBuilder: (context, exp, st) {
                              return Text(
                                "No photo",
                                style: Theme.of(context).textTheme.caption,
                              );
                            },
                          ), onTap: () {
                        Dialog myDialog = Dialog(
                          child: Image.network(
                            "${Api.server}/v1/picture?oid=${settings.companyId}&pid=" + rows[index]["_id"],
                            errorBuilder: (context, exp, st) {
                              return Text(
                                "No photo",
                                style: Theme.of(context).textTheme.caption,
                              );
                            },
                          ),
                        );
                        showDialog(context: context, builder: (BuildContext context) => myDialog);
                      }),
                      DataCell(Text(
                        rows[index]["name"] ?? "",
                      )),
                      DataCell(Icon((rows[index]["gender"] ?? "") == "male" ? Icons.man : Icons.woman,
                          color: (rows[index]["gender"] ?? "") == "male" ? Colors.lightBlueAccent : Colors.redAccent)),
                      DataCell(Text(
                        rows[index]["position"] ?? "",
                      )),
                      DataCell(Text(
                        rows[index]["division"] ?? "",
                      )),
                      DataCell(
                          Text(
                            rows[index]["sub-division"] ?? "",
                          ),
                          showEditIcon: true, onTap: () {
                        setState(() {
                          selectedRow = rows[index];
                          showEditForm = true;
                          refreshControllers(settings);
                        });
                      }),
                    ]);
                  }),
                ),
        ),
      ),
    );
  }

  void getFromServer(MySettings settings) async {
    try {
      Api.feathers().find(serviceName: "people", query: {"oid": settings.companyId}).asStream().listen((event) {
            setState(() {
              rows = event["data"];
            });
          });
    } catch (e) {
      print(e);
    }
  }

  void deleteRow(row) {}

  getBodyForEdit(MySettings settings) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.network(
                    "${Api.server}/v1/picture?oid=${settings.companyId}&pid=${selectedRow["_id"]}",
                    errorBuilder: (context, exp, st) {
                      return Text(
                        "No photo",
                        style: Theme.of(context).textTheme.caption,
                      );
                    },
                    width: 120,
                    fit: BoxFit.fitWidth,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {}, child: Text(AppLocalizations.of(context).translate("capture-photo"))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        ElevatedButton(onPressed: () {}, child: Text(AppLocalizations.of(context).translate("upload"))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {}, child: Text(AppLocalizations.of(context).translate("download"))),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: nameController,
                          enabled: true,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            isDense: true,
                            prefixStyle: const TextStyle(color: Colors.red),
                            labelText: AppLocalizations.of(context).translate("person-name"),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: positionController,
                          enabled: true,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            isDense: true,
                            prefixStyle: const TextStyle(color: Colors.red),
                            labelText: AppLocalizations.of(context).translate("person-position"),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: divisionController,
                          enabled: true,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            isDense: true,
                            prefixStyle: const TextStyle(color: Colors.red),
                            labelText: AppLocalizations.of(context).translate("division"),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: subdivisonController,
                          enabled: true,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            isDense: true,
                            prefixStyle: const TextStyle(color: Colors.red),
                            labelText: AppLocalizations.of(context).translate("sub-division"),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: employeeNoStringController,
                          enabled: true,
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            isDense: true,
                            prefixStyle: TextStyle(color: Colors.red),
                            labelText: "employeeNoString",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Expanded(child: Text("")),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (selectedRow == null) {
                                  await Api.feathers().create(serviceName: "people", data: {
                                    "oid": settings.companyId,
                                    "name": nameController.text,
                                    "position": positionController.text,
                                    "division": divisionController.text,
                                    "sub_division": subdivisonController.text,
                                    "employeeNoString": employeeNoStringController.text,
                                  });
                                } else {
                                  await Api.feathers()
                                      .patch(serviceName: "people", objectId: selectedRow["_id"], data: {
                                    "oid": settings.companyId,
                                    "name": nameController.text,
                                    "position": positionController.text,
                                    "division": divisionController.text,
                                    "sub_division": subdivisonController.text,
                                    "employeeNoString": employeeNoStringController.text,
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: Text(AppLocalizations.of(context).translate("save")),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedRow = true;
                                  showEditForm = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: Text(AppLocalizations.of(context).translate("close")),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }

  void refreshControllers(MySettings settings) {
    nameController.text = "";
    positionController.text = "";
    divisionController.text = "";
    subdivisonController.text = "";
    employeeNoStringController.text = "";
    if (selectedRow != null) {
      nameController.text = selectedRow["name"];
      positionController.text = selectedRow["position"];
      divisionController.text = selectedRow["division"];
      subdivisonController.text = selectedRow["sub_division"];
      employeeNoStringController.text = selectedRow["employeeNoString"];
    }
  }
}
