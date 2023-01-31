import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:nae_hr/screens/wh/receive.dart';
import 'package:nae_hr/share/utils.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pluto_grid/pluto_grid.dart';

import '../../api.dart';

class WHReceiveJournal extends StatefulWidget {
  const WHReceiveJournal({Key? key}) : super(key: key);

  @override
  State<WHReceiveJournal> createState() => _WHReceiveJournalState();
}

class _WHReceiveJournalState extends State<WHReceiveJournal> {

  bool _first = true;
  List<dynamic> rows = [];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);
    if (_first) {
      getFromServer(settings);
      Api.feathers().listen(serviceName: "docs", fromJson: (e) {
        print("event "+e);
        getFromServer(settings);
      });
      _first = false;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => WHReceiveDoc(doc: WHReceive(data: {}))
          ));
        },
      ),
      body: SafeArea(
        child: Container(
          // color: Colors.grey.shade200,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: rows.isEmpty ? Center(child: Text(AppLocalizations.of(context).translate("no-data"))) : ListView.builder(
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
                        // color: themeData.scaffoldBackgroundColor,
                        //color: selectedCurId == currencies[index]["id"] ? Theme.of(context).colorScheme.background : Theme.of(context).highlightColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rows[index]["name"], style: Theme.of(context).textTheme.headline6,),
                              const SizedBox(height: 4),
                              Text(rows[index]["ip"] + ":" + rows[index]["port"] + "   " + rows[index]["protocol"], style: Theme.of(context).textTheme.bodyText2,),
                              const SizedBox(height: 2),
                              Text(rows[index]["devIndex"] + "    "  + rows[index]["username"], style: Theme.of(context).textTheme.bodyText2,)
                            ],
                          )),
                          Text(rows[index]["status"]["name"] + "  " + timeago.format(DateTime.fromMillisecondsSinceEpoch(rows[index]["status"]["ts"] * 1000)), style: Theme.of(context).textTheme.bodyText2,),
                          IconButton(onPressed: () async {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => WHReceiveDoc(doc: WHReceive(data: rows[index]))
                            ));
                            // Dialog myDialog = Dialog(
                            //   child: getDialogBody(settings, rows[index]["_id"], rows[index]),
                            // );
                            // showDialog(context: context, builder: (BuildContext context) => myDialog);
                          }, icon: const Icon(Icons.edit, color: Colors.green)),
                          IconButton(onPressed: () async {
                            if (await confirm(
                              context,
                              title: Text(AppLocalizations.of(context).translate("delete")),
                              content: Text(AppLocalizations.of(context).translate("delete-content")),
                              textOK: Text(AppLocalizations.of(context).translate("yes")),
                              textCancel: Text(AppLocalizations.of(context).translate("no")),
                            ))  {
                              await Api.feathers().remove(serviceName: "cameras", objectId: rows[index]["_id"]);
                            }
                          }, icon: const Icon(Icons.delete, color: Colors.red))
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
      var query = {
        "oid": settings.companyId,
        "ctx": ["warehouse", "receive"],
      };
      Api.feathers().find(serviceName: "docs", query: query).asStream().listen((event) {
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
