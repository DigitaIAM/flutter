import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({Key? key}) : super(key: key);

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {

  bool _first = true;
  List<dynamic> rows = [];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);
    if (_first) {
      getFromServer(settings);
      settings.flutterFeathersjs.scketio.listen(serviceName: "companies", fromJson: (e) {
        getFromServer(settings);
      });
      _first = false;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          String? newName = await prompt(context, title: Text("New company name"));
          if (newName == null) return;
          settings.flutterFeathersjs.scketio.create(serviceName: "companies", data: {
            "name": newName
          });
        },
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () async {
                  //
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.8),
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        //color: selectedCurId == currencies[index]["id"] ? Theme.of(context).colorScheme.background : Theme.of(context).highlightColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text(rows[index]["name"], style: Theme.of(context).textTheme.headline6,)),
                          IconButton(onPressed: () async {
                            String? newName = await prompt(context, title: Text("Company name"), initialValue: rows[index]["name"]);
                            if (newName == null) return;
                            settings.flutterFeathersjs.scketio.update(serviceName: "companies", objectId: rows[index]["_id"], data: {
                              "name": newName
                            });
                          }, icon: Icon(Icons.edit, color: Colors.green)),
                          IconButton(onPressed: () async {
                            if (await confirm(
                              context,
                              title: const Text('Delete'),
                              content: const Text('Would you like to remove?'),
                              textOK: const Text('Yes'),
                              textCancel: const Text('No'),
                            ))  {
                              await settings.flutterFeathersjs.scketio.remove(serviceName: "companies", objectId: rows[index]["_id"]);
                            }
                          }, icon: Icon(Icons.delete, color: Colors.red))
                        ],
                      )
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void getFromServer(MySettings settings) async {
    try {
      settings.flutterFeathersjs.find(serviceName: "companies", query: {}).asStream().listen((event) {
        setState(() {
          rows = event["data"];
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void deleteRow(row) {

  }
}
