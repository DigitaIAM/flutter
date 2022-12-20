import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:nae_hr/share/utils.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

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
      settings.flutterFeathersjs.scketio.listen(serviceName: "cameras", fromJson: (e) {
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
                          Expanded(child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rows[index]["name"], style: Theme.of(context).textTheme.headline6,),
                              SizedBox(height: 4),
                              Text("IP, port:  " + rows[index]["ip"] + ":" + rows[index]["port"] + "   " + rows[index]["protocol"], style: Theme.of(context).textTheme.bodyText2,),
                              SizedBox(height: 2),
                              Text("User name:  " + rows[index]["username"], style: Theme.of(context).textTheme.bodyText2,)
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
                              title: const Text('Delete'),
                              content: const Text('Would you like to remove?'),
                              textOK: const Text('Yes'),
                              textCancel: const Text('No'),
                            ))  {
                              await settings.flutterFeathersjs.scketio.remove(serviceName: "cameras", objectId: rows[index]["_id"]);
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
      settings.flutterFeathersjs.find(serviceName: "cameras", query: {"oid": settings.selectedCompanyId}).asStream().listen((event) {
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
                IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.close))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: nameController,
                enabled: true,
                decoration: const InputDecoration(
                  isDense: true,
                  prefixStyle: TextStyle(color: Colors.red),
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),

              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: devIndexController,
                enabled: true,
                decoration: const InputDecoration(
                  isDense: true,
                  prefixStyle: TextStyle(color: Colors.red),
                  labelText: "Dev Index",
                  border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixStyle: TextStyle(color: Colors.red),
                        labelText: "Protocol",
                        border: OutlineInputBorder(),
                      ),

                    ),),
                  SizedBox(width: 4),
                  Expanded(child: TextFormField(
                      controller: ipController,
                      enabled: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixStyle: TextStyle(color: Colors.red),
                        labelText: "IP address",
                        border: OutlineInputBorder(),
                      ),

                    ),),
                  SizedBox(width: 4),
                  Expanded(child: TextFormField(
                      controller: portController,
                      enabled: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixStyle: TextStyle(color: Colors.red),
                        labelText: "Port",
                        border: OutlineInputBorder(),
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
                    decoration: const InputDecoration(
                      isDense: true,
                      prefixStyle: TextStyle(color: Colors.red),
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                  ),),
                  SizedBox(width: 4),
                  Expanded(child: TextFormField(
                    controller: passwordController,
                    enabled: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      prefixStyle: TextStyle(color: Colors.red),
                      labelText: "Password",
                      border: OutlineInputBorder(),
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
                      await settings.flutterFeathersjs.scketio.create(serviceName: "cameras", data: {
                        "oid": settings.selectedCompanyId,
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
                      await settings.flutterFeathersjs.scketio.patch(serviceName: "cameras", objectId: _id, data: {
                        "oid": settings.selectedCompanyId,
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
                  }, child: const Text("Save")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
