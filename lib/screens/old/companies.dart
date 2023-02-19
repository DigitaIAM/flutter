import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/core/my_settings.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';

import '../../api.dart';

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
    final localization = AppLocalizations.of(context);
    final settings = Provider.of<MySettings>(context);
    if (_first) {
      getFromServer(settings);
      Api.feathers().listen(
          serviceName: "companies",
          fromJson: (e) {
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
          Api.feathers().create(serviceName: "companies", data: {"name": newName});
        },
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: rows.isEmpty
              ? Center(child: Text(AppLocalizations.of(context).translate("no-data")))
              : ListView.builder(
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
                                Expanded(
                                    child: Text(
                                  rows[index]["name"],
                                  style: Theme.of(context).textTheme.headline6,
                                )),
                                IconButton(
                                    onPressed: () async {
                                      String? newName = await prompt(context,
                                          title: Text(AppLocalizations.of(context).translate("name")),
                                          initialValue: rows[index]["name"]);
                                      if (newName == null) return;
                                      Api.feathers().update(
                                          serviceName: "companies",
                                          objectId: rows[index]["_id"],
                                          data: {"name": newName});
                                    },
                                    icon: const Icon(Icons.edit, color: Colors.green)),
                                IconButton(
                                    onPressed: () async {
                                      if (await confirm(
                                        context,
                                        title: Text(localization.translate("delete")),
                                        content: Text(localization.translate("delete-content")),
                                        textOK: Text(localization.translate("yes")),
                                        textCancel: Text(localization.translate("no")),
                                      )) {
                                        await Api.feathers()
                                            .remove(serviceName: "companies", objectId: rows[index]["_id"]);
                                      }
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.red))
                              ],
                            )),
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
      Api.feathers().find(serviceName: "companies", query: {}).asStream().listen((event) {
            setState(() {
              rows = event["data"];
            });
          });
    } catch (e) {
      print(e);
    }
  }

  void deleteRow(row) {}
}
