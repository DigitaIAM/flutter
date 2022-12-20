import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({Key? key}) : super(key: key);

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {

  bool _first = true;
  List<dynamic> rows = [];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);
    if (_first) {
      getFromServer(settings);
      settings.flutterFeathersjs.scketio.listen(serviceName: "people", fromJson: (e) {
        getFromServer(settings);
      });
      _first = false;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          String? newName = await prompt(context, title: Text("New person name"));
          if (newName == null) return;
          settings.flutterFeathersjs.scketio.create(serviceName: "people", data: {
            "name": newName
          });
        },
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: DataTable2(
            decoration: BoxDecoration(
              color: Colors.white
            ),
            columns: const [
              DataColumn2(
                label: Text('Photo'),
                size: ColumnSize.S,
              ),
              DataColumn(
                label: Text('Name'),
                numeric: true,
              ),
              DataColumn(
                label: Text('Gender'),
                numeric: true,
              ),
              DataColumn(
                label: Text('Position'),
                numeric: true,
              ),
              DataColumn(
                label: Text('Division'),
                numeric: true,
              ),
              DataColumn(
                label: Text('Sub-division'),
                numeric: true,
              ),
            ],
            rows: List<DataRow>.generate(rows.length,
                    (index) {

                  return DataRow(cells: [
                    DataCell(Text(rows[index]["name"]??"", )),
                    DataCell(Text(rows[index]["name"]??"", )),
                    DataCell(Text(rows[index]["gender"]??"", )),
                    DataCell(Text(rows[index]["position"]??"", )),
                    DataCell(Text(rows[index]["division"]??"", )),
                    DataCell(Text(rows[index]["sub-division"]??"", )),
                  ]);
                }),

          ),
        ),
      ),
    );
  }

  void getFromServer(MySettings settings) async {
    try {
      settings.flutterFeathersjs.find(serviceName: "people", query: {"oid": settings.selectedCompanyId}).asStream().listen((event) {
        setState(() {
          rows = event["data"];
        });
        print(rows);
      });
    } catch (e) {
      print(e);
    }
  }

  void deleteRow(row) {

  }
}
