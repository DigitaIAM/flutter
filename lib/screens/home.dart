import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:nae_hr/screens/cameras.dart';
import 'package:nae_hr/screens/companies.dart';
import 'package:nae_hr/screens/people.dart';
import 'package:provider/provider.dart';
import 'package:select_dialog/select_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _first = true;
  String mainTitle = "Dashboard";
  PageController page = PageController();

  int selectedCompanyIndex = -1;
  List<dynamic> companies = [];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);
    if (_first) {
      getFromServer(settings);
      _first = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                selectCompany(settings);
              },
              child: Center(child: Text(selectedCompanyIndex == -1 ? "NO COMPANY" : companies[selectedCompanyIndex]["name"], style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white, decoration: TextDecoration.underline,),), )),
            Text("  -  "),
            Expanded(child: Text(mainTitle)),
            InkWell(
              onTap: () {
                selectLanguage(settings);
              },
              child: Text(settings.getLanguage(context)))
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () { connectToServer(settings); }, icon: const Icon(Icons.link)),
          IconButton(onPressed: () { connectToServer(settings); }, icon: const Icon(Icons.account_box)),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            controller: page,
            style: SideMenuStyle(
              // showTooltip: false,
              displayMode: SideMenuDisplayMode.auto,
              hoverColor: Colors.blue[100],
              selectedColor: Colors.lightBlue,
              selectedTitleTextStyle: const TextStyle(color: Colors.white),
              selectedIconColor: Colors.white,
              openSideMenuWidth: 200
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.all(Radius.circular(10)),
              // ),
              // backgroundColor: Colors.blueGrey[700]
            ),
            title: Column(
              children: const [
                // ConstrainedBox(
                //   constraints: const BoxConstraints(
                //     maxHeight: 150,
                //     maxWidth: 150,
                //   ),
                //   child: Image.asset(
                //     'assets/images/easy_sidemenu.png',
                //   ),
                // ),
                Divider(
                  indent: 2.0,
                  endIndent: 2.0,
                ),
              ],
            ),
            footer: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('nae HR, 2022', style: Theme.of(context).textTheme.caption!),
            ),
            items: [
              SideMenuItem(
                priority: 0,
                title: AppLocalizations.of(context).translate("dashboard"),
                onTap: () {
                  page.jumpToPage(0);
                  setState(() {
                    mainTitle = AppLocalizations.of(context).translate("dashboard");
                  });
                },
                icon: const Icon(Icons.dashboard),
              ),
              SideMenuItem(
                priority: 1,
                title: AppLocalizations.of(context).translate("people"),
                onTap: () {
                  page.jumpToPage(1);
                  setState(() {
                    mainTitle = AppLocalizations.of(context).translate("people");
                  });
                },
                icon: const Icon(Icons.people),
              ),
              SideMenuItem(
                priority: 2,
                title: AppLocalizations.of(context).translate("shifts"),
                onTap: () {
                  page.jumpToPage(2);
                  setState(() {
                    mainTitle = AppLocalizations.of(context).translate("shifts");
                  });
                },
                icon: const Icon(Icons.calendar_month),
              ),
              SideMenuItem(
                priority: 3,
                title: AppLocalizations.of(context).translate("events"),
                onTap: () {
                  page.jumpToPage(3);
                  setState(() {
                    mainTitle = AppLocalizations.of(context).translate("events");
                  });
                },
                icon: const Icon(Icons.event),
              ),
              SideMenuItem(
                priority: 4,
                title: AppLocalizations.of(context).translate("attendance"),
                onTap: () {
                  page.jumpToPage(4);
                  setState(() {
                    mainTitle = AppLocalizations.of(context).translate("attendance");
                  });
                },
                icon: const Icon(Icons.event_available),
              ),
              SideMenuItem(
                priority: 5,
                title: AppLocalizations.of(context).translate("users"),
                onTap: () {
                  page.jumpToPage(5);
                  setState(() {
                    mainTitle = AppLocalizations.of(context).translate("users");
                  });
                },
                icon: const Icon(Icons.person),
              ),
              SideMenuItem(
                priority: 6,
                title: AppLocalizations.of(context).translate("companies"),
                onTap: () {
                  page.jumpToPage(6);
                  setState(() {
                    mainTitle = AppLocalizations.of(context).translate("companies");
                  });
                },
                icon: const Icon(Icons.location_city),
              ),
              SideMenuItem(
                priority: 7,
                title: AppLocalizations.of(context).translate("cameras"),
                onTap: () {
                  page.jumpToPage(7);
                  setState(() {
                    mainTitle = AppLocalizations.of(context).translate("cameras");
                  });
                },
                icon: const Icon(Icons.camera_alt),
              ),
              SideMenuItem(
                priority: 8,
                title: AppLocalizations.of(context).translate("settings"),
                onTap: () {
                  page.jumpToPage(8);
                  setState(() {
                    mainTitle = AppLocalizations.of(context).translate("settings");
                  });
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: page,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Container(
                  color: Colors.white,
                  child: const Center(child: Text('Dashboard', style: TextStyle(fontSize: 35))),
                ),
                PeoplePage(),
                Container(
                  color: Colors.white,
                  child: const Center(child: Text('Download', style: TextStyle(fontSize: 35))),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text('Settings', style: TextStyle(fontSize: 35)),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text('Only Title', style: TextStyle(fontSize: 35)),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text('Only Icon', style: TextStyle(fontSize: 35)),
                  ),
                ),
                CompaniesPage(),
                CamerasPage(),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text('Only Icon', style: TextStyle(fontSize: 35)),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  void connectToServer(MySettings settings) async {
    try {
      var ff = await settings.flutterFeathersjs.scketio.find(serviceName: "companies", query: {});
    } catch (e) {
    }
  }

  void getFromServer(MySettings settings) {
    settings.flutterFeathersjs.find(serviceName: "companies", query: {}).asStream().listen((event) {
      setState(() {
        companies = event["data"];
        if (companies.isNotEmpty&&selectedCompanyIndex == -1) {
          for (int i = 0; i < companies.length; i++) {
            if (companies[i]["_id"] == settings.selectedCompanyId) {
              selectedCompanyIndex = i;
            }
          }
        }
      });
    });
  }

  void selectCompany(MySettings settings) {
    SelectDialog.showModal<dynamic>(
      context,
      label: AppLocalizations.of(context).translate("companies"),
      showSearchBox: false,
      items: companies,
      itemBuilder: (contex, item, isSelected) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(item["name"]),
        );
      },
      onChange: (dynamic selected) {
        setState(() {
          selectedCompanyIndex = companies.indexOf(selected);
        });
        settings.selectedCompanyId = selected["_id"];
        settings.saveAndNotify();
        page.jumpTo(0);
        mainTitle = AppLocalizations.of(context).translate("dashboard");
      },
    );
  }

  void selectLanguage(MySettings settings) {
    AlertDialog alert = AlertDialog(

        content: SizedBox(
          height: 240,
          child: Column(
            children: [
              ListTile(
                leading: Image.asset('icons/flags/png/uz.png', package: 'country_icons', height: 20, width: 28, fit: BoxFit.fill, ),
                title: const Text("O'zbekcha"),
                onTap: () async {
                  settings.locale = const Locale("uz", "UZ");
                  settings.saveAndNotify();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Image.asset('icons/flags/png/gb.png', package: 'country_icons', height: 20, width: 28, fit: BoxFit.fill, ),
                title: const Text("English"),
                onTap: () async {
                  settings.locale = const Locale("en", "US");
                  settings.saveAndNotify();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Image.asset('icons/flags/png/ru.png', package: 'country_icons', height: 20, width: 28, fit: BoxFit.fill, ),
                title: const Text("Русский"),
                onTap: () async {
                  settings.locale = const Locale("ru", "RU");
                  settings.saveAndNotify();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Image.asset('icons/flags/png/tj.png', package: 'country_icons', height: 20, width: 28, fit: BoxFit.fill, ),
                title: const Text("Tajiki"),
                onTap: () async {
                  settings.locale = const Locale("tr", "TR");
                  settings.saveAndNotify();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ));
    showDialog(context: context, builder: (context) { return alert; } );
  }
}
