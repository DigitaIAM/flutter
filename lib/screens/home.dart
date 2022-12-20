import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
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
            Text(mainTitle)
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
                title: 'Dashboard',
                onTap: () {
                  page.jumpToPage(0);
                  setState(() {
                    mainTitle = "Dashboard";
                  });
                },
                icon: const Icon(Icons.dashboard),
              ),
              SideMenuItem(
                priority: 1,
                title: 'People',
                onTap: () {
                  page.jumpToPage(1);
                  setState(() {
                    mainTitle = "People";
                  });
                },
                icon: const Icon(Icons.people),
              ),
              SideMenuItem(
                priority: 2,
                title: 'Shifts',
                onTap: () {
                  page.jumpToPage(2);
                  setState(() {
                    mainTitle = "Shifts";
                  });
                },
                icon: const Icon(Icons.calendar_month),
              ),
              SideMenuItem(
                priority: 3,
                title: 'Events',
                onTap: () {
                  page.jumpToPage(3);
                  setState(() {
                    mainTitle = "Events";
                  });
                },
                icon: const Icon(Icons.event),
              ),
              SideMenuItem(
                priority: 4,
                title: 'Attendance',
                onTap: () {
                  page.jumpToPage(4);
                  setState(() {
                    mainTitle = "Attendance";
                  });
                },
                icon: const Icon(Icons.event_available),
              ),
              SideMenuItem(
                priority: 5,
                title: 'Users',
                onTap: () {
                  page.jumpToPage(5);
                  setState(() {
                    mainTitle = "Users";
                  });
                },
                icon: const Icon(Icons.person),
                tooltipContent: "This is a tooltip for Dashboard item",
              ),
              SideMenuItem(
                priority: 6,
                title: 'Companies',
                onTap: () {
                  page.jumpToPage(6);
                  setState(() {
                    mainTitle = "Companies";
                  });
                },
                icon: const Icon(Icons.location_city),
              ),
              SideMenuItem(
                priority: 7,
                title: 'Cameras',
                onTap: () {
                  page.jumpToPage(7);
                  setState(() {
                    mainTitle = "Cameras";
                  });
                },
                icon: const Icon(Icons.camera_alt),
              ),
              SideMenuItem(
                priority: 8,
                title: 'Settings',
                onTap: () {
                  page.jumpToPage(8);
                  setState(() {
                    mainTitle = "Settings";
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
      label: "Simple Example",
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
        mainTitle = "Dashboard";
      },
    );
  }
}
