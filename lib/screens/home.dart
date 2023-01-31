import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:nae_hr/model/ui/ui_bloc.dart';
import 'package:nae_hr/model/ui/ui_state.dart';
import 'package:nae_hr/screens/common/uom/uom_view.dart';
import 'package:nae_hr/screens/common/uom/uoms_screen.dart';
import 'package:nae_hr/screens/production/orders/production_order_view.dart';
import 'package:nae_hr/screens/production/orders/production_orders_screen.dart';
import 'package:nae_hr/widgets/app_border.dart';
import 'package:nae_hr/widgets/blank_screen.dart';
import 'package:nae_hr/widgets/change_layout_banner.dart';
import 'package:nae_hr/widgets/menu_drawer_builder.dart';
import 'package:provider/provider.dart';

import '../api.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late UiBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = UiBloc();
  }

  @override
  void dispose(){
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);
    // SizeConfig().init(context);

    bool showFilterSidebar = false;

    return BlocProvider(
        create: (_) => bloc,
        child: SafeArea(
          child: Column(
              children: [
                Expanded(
                  child: ChangeLayoutBanner(
                    child: BlocBuilder<UiBloc, UiState>(
                      builder: (context, uiState) => Row(children: <Widget>[
                        if (uiState.showMenu) MenuDrawerBuilder(),
                        Expanded(
                            child: AppBorder(
                              isLeft: uiState.showMenu && (!settings.isFullScreen || showFilterSidebar),
                              child: entityScreen(uiState),
                            )),
                      ]),
                    )
                  )
                )
              ]
          )
        )
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         InkWell(
    //           onTap: () {
    //             selectCompany(settings);
    //           },
    //           child: Center(
    //             child: Text(
    //               selectedCompanyIndex == -1 ? "NO COMPANY" : companies[selectedCompanyIndex]["name"],
    //               style: Theme.of(context).textTheme.headline6!.copyWith(decoration: TextDecoration.underline,),
    //             ),
    //           )),
    //         // Text("  -  "),
    //         Expanded(
    //             child: Center(
    //                 child: Text(mainTitle)
    //             )
    //         ),
    //         InkWell(
    //           onTap: () {
    //             selectLanguage(settings);
    //           },
    //           child: Text(settings.getLanguage(context)))
    //       ],
    //     ),
    //     centerTitle: true,
    //     actions: [
    //       // IconButton(onPressed: () { connectToServer(settings); }, icon: const Icon(Icons.link)),
    //       IconButton(onPressed: () { connectToServer(settings); }, icon: const Icon(Icons.account_box)),
    //     ],
    //   ),
    //   body: SafeArea(
    //     child: Row(
    //       children: [
    //         SideNavigationBar(
    //           selectedIndex: selectedIndex,
    //           items: [
    //             SideNavigationBarItem(
    //               icon: Icons.dashboard,
    //               label: AppLocalizations.of(context).translate("Inventory"),
    //             ),
    //             SideNavigationBarItem(
    //               icon: Icons.login,
    //               label: AppLocalizations.of(context).translate("receives"),
    //             ),
    //             SideNavigationBarItem(
    //               icon: Icons.logout,
    //               label: AppLocalizations.of(context).translate("issues"),
    //             ),
    //             SideNavigationBarItem(
    //               icon: Icons.square_foot_outlined,
    //               label: AppLocalizations.of(context).translate("uom"),
    //             ),
    //           ],
    //           onTap: (index) {
    //             setState(() {
    //               selectedIndex = index;
    //               mainTitle = "";
    //             });
    //           },
    //         ),
    //
    //         /// Make it take the rest of the available width
    //         Expanded(
    //           child: views.elementAt(selectedIndex),
    //         )
    //         // Your app screen body
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget entityScreen(UiState uiState) {
    Widget screen = const BlankScreen();
    if (uiState.currentRoute == ProductionOrdersScreen.route) {
      screen = EntityScreens(
        list: const ProductionOrdersScreen(),
        view: ProductionOrderView(entity: uiState.entity, tabIndex: 0),
      );
    } else if (uiState.currentRoute == UomsScreen.route) {
      screen = EntityScreens(
        list: const UomsScreen(),
        view: UomView(entity: uiState.entity),
      );
    }
    return screen;
  }

  // void selectLanguage(MySettings settings) {
  //   AlertDialog alert = AlertDialog(
  //
  //       content: SizedBox(
  //         height: 240,
  //         child: Column(
  //           children: [
  //             ListTile(
  //               leading: Image.asset('icons/flags/png/uz.png', package: 'country_icons', height: 20, width: 28, fit: BoxFit.fill, ),
  //               title: const Text("O'zbekcha"),
  //               onTap: () async {
  //                 settings.locale = const Locale("uz", "UZ");
  //                 settings.saveAndNotify();
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             ListTile(
  //               leading: Image.asset('icons/flags/png/gb.png', package: 'country_icons', height: 20, width: 28, fit: BoxFit.fill, ),
  //               title: const Text("English"),
  //               onTap: () async {
  //                 settings.locale = const Locale("en", "US");
  //                 settings.saveAndNotify();
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             ListTile(
  //               leading: Image.asset('icons/flags/png/ru.png', package: 'country_icons', height: 20, width: 28, fit: BoxFit.fill, ),
  //               title: const Text("Русский"),
  //               onTap: () async {
  //                 settings.locale = const Locale("ru", "RU");
  //                 settings.saveAndNotify();
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             ListTile(
  //               leading: Image.asset('icons/flags/png/tj.png', package: 'country_icons', height: 20, width: 28, fit: BoxFit.fill, ),
  //               title: const Text("Tajiki"),
  //               onTap: () async {
  //                 settings.locale = const Locale("tr", "TR");
  //                 settings.saveAndNotify();
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         ),
  //       ));
  //   showDialog(context: context, builder: (context) { return alert; } );
  // }
}

class EntityScreens extends StatelessWidget {

  final Widget list;
  final Widget view;

  const EntityScreens({super.key, required this.list, required this.view});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);

    const previewFlex = 2;
    int listFlex = 3;

    Widget? topFilterChild;
    Widget? leftFilterChild;

    return Row(
      children: [
        Expanded(
          flex: listFlex,
          child: ClipRRect(
            child: AppBorder(
              isLeft: leftFilterChild != null,
              child: topFilterChild == null || settings.isFilterVisible
                ? list : Column(children: [
                  // if (prefState.isViewerFullScreen(state.uiState.filterEntityType))
                  //   SizedBox(
                  //     height: 360,
                  //     child: topFilterChild,
                  //   )
                  // else
                    topFilterChild,
                  Expanded(
                    child: AppBorder(
                      isTop: topFilterChild != null, // && uiState.filterEntityType != null,
                      child: list,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        if (settings.isPreviewShown)
          Expanded(
            flex: settings.isFullScreen ? (listFlex + previewFlex) : previewFlex,
            child: AppBorder(
              isLeft: true,
              child: view,
            ),
          ),
      ]
    );
  }

}
