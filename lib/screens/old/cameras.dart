import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:nae_hr/share/utils.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../api.dart';

class CamerasPage extends StatefulWidget {
  const CamerasPage({Key? key}) : super(key: key);

  @override
  State<CamerasPage> createState() => _CamerasPageState();
}

class _CamerasPageState extends State<CamerasPage> {

  bool _first = true;
  List<dynamic> rows = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController devIndexController = TextEditingController();
  TextEditingController protocolController = TextEditingController();
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);
    if (_first) {
      getFromServer(settings);
       Api.feathers().listen(serviceName: "cameras", fromJson: (e) {
        getFromServer(settings);
      });
      _first = false;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          Dialog myDialog = Dialog(
            child: getDialogBody(settings, "", null),
          );
          showDialog(context: context, builder: (BuildContext context) => myDialog);
        },
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade200,
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
                        color: Colors.white,
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
                            Dialog myDialog = Dialog(
                              child: getDialogBody(settings, rows[index]["_id"], rows[index]),
                            );
                            showDialog(context: context, builder: (BuildContext context) => myDialog);
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
      Api.feathers().find(serviceName: "cameras", query: {"oid": settings.companyId}).asStream().listen((event) {
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

  getDialogBody(MySettings settings, String _id, dynamic _row) {
    nameController.text = "";
    devIndexController.text = "";
    protocolController.text = "";
    ipController.text = "";
    portController.text = "";
    userNameController.text = "";
    passwordController.text = "";
    if (_row != null) {
      print(_row);
      nameController.text = _row["name"];
      devIndexController.text = _row["devIndex"];
      protocolController.text = _row["protocol"];
      ipController.text = _row["ip"];
      portController.text = _row["port"];
      userNameController.text = _row["username"];
      // passwordController.text = _row["password"];
    }

    return SingleChildScrollView(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text(_row == null ? "New camera" : _row["name"], style: Theme.of(context).textTheme.headline6,)),
                ),),
                IconButton(onPressed: () { Navigator.pop(context); }, icon: const Icon(Icons.close))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: nameController,
                enabled: true,
                decoration: InputDecoration(
                  isDense: true,
                  prefixStyle: const TextStyle(color: Colors.red),
                  labelText: AppLocalizations.of(context).translate("name"),
                  border: const OutlineInputBorder(),
                ),

              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: devIndexController,
                enabled: true,
                decoration: InputDecoration(
                  isDense: true,
                  prefixStyle: const TextStyle(color: Colors.red),
                  labelText: AppLocalizations.of(context).translate("dev-index"),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: TextFormField(
                      controller: protocolController,
                      enabled: true,
                      decoration: InputDecoration(
                        isDense: true,
                        prefixStyle: const TextStyle(color: Colors.red),
                        labelText: AppLocalizations.of(context).translate("protocol"),
                        border: const OutlineInputBorder(),
                      ),

                    ),),
                  const SizedBox(width: 4),
                  Expanded(child: TextFormField(
                      controller: ipController,
                      enabled: true,
                      decoration: InputDecoration(
                        isDense: true,
                        prefixStyle: const TextStyle(color: Colors.red),
                        labelText: AppLocalizations.of(context).translate("ip"),
                        border: const OutlineInputBorder(),
                      ),

                    ),),
                  const SizedBox(width: 4),
                  Expanded(child: TextFormField(
                      controller: portController,
                      enabled: true,
                      decoration: InputDecoration(
                        isDense: true,
                        prefixStyle: const TextStyle(color: Colors.red),
                        labelText: AppLocalizations.of(context).translate("port"),
                        border: const OutlineInputBorder(),
                      ),

                    ),)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: TextFormField(
                    controller: userNameController,
                    enabled: true,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixStyle: const TextStyle(color: Colors.red),
                      labelText: AppLocalizations.of(context).translate("username"),
                      border: const OutlineInputBorder(),
                    ),
                  ),),
                  const SizedBox(width: 4),
                  Expanded(child: TextFormField(
                    controller: passwordController,
                    enabled: true,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixStyle: const TextStyle(color: Colors.red),
                      labelText: AppLocalizations.of(context).translate("password"),
                      border: const OutlineInputBorder(),
                    ),

                  ),),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Expanded(child: Text("")),
                  ElevatedButton(onPressed: () async {
                    if (_id == "") {
                      await Api.feathers().create(serviceName: "cameras", data: {
                        "oid": settings.companyId,
                        "name": nameController.text,
                        "enabled": true,
                        "devIndex": devIndexController.text,
                        "protocol": protocolController.text,
                        "ip": ipController.text,
                        "port": portController.text,
                        "username": userNameController.text,
                        "password": passwordController.text,
                      });
                    } else {
                      await Api.feathers().patch(serviceName: "cameras", objectId: _id, data: {
                        "oid": settings.companyId,
                        "name": nameController.text,
                        "enabled": true,
                        "devIndex": devIndexController.text,
                        "protocol": protocolController.text,
                        "ip": ipController.text,
                        "port": portController.text,
                        "username": userNameController.text,
                        "password": passwordController.text,
                      });
                    }
                    Navigator.pop(context);
                  }, child: Text(AppLocalizations.of(context).translate("save"))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
