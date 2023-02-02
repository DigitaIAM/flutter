import 'package:flutter/material.dart';
import 'package:nae_hr/api.dart';
import 'package:nae_hr/memory.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySettings with ChangeNotifier {

  late SharedPreferences prefs;
  late Memory memory;

  String login = "";
  String token = "";

  String userName = "";
  String companyId = "";

  int role = 0;

  late Locale locale = const Locale("ru", "RU");
  int theme = 0;  //0 - auto, 1 - night, 2 - blue (default)

  int timeOut = 0;

  bool isUpdateAvailable = false;

  bool isDesktop = true;
  bool isFullScreen = false;

  bool isFilterVisible = false;

  // pref
  bool enableTooltips = true;
  bool prefList = true;
  int prefRowsPerPage = 10;

  // ui state
  List<String> viewCtx = [];

  MySettings(this.prefs, this.memory) {
    load();
  }

  void load() {
    theme = prefs.getInt("theme") ?? 0;
    locale = Locale(prefs.getString("locale_en")??"ru", prefs.getString("locale_US")??"RU");

    token = prefs.getString("token")??"";
    login = prefs.getString("login")??"";

    userName = prefs.getString("userName")??"";
    companyId = prefs.getString("companyId")??"";

    Api.instance.oid = companyId;
  }

  void saveAndNotify() async {
    await save();
    notifyListeners();
  }

  Future<void> save() async {
    await prefs.setInt("theme", theme);
    await prefs.setString("locale_en", locale.languageCode);
    await prefs.setString("locale_US", locale.countryCode??"RU");

    await prefs.setString("companyId", companyId);

    await prefs.setString("token", token);
    await prefs.setString("login", login);

    await prefs.setString("userName", userName);
  }


  String getLanguage(BuildContext context) {
    if (locale.languageCode == "uz") return "Uzbek";
    if (locale.languageCode == "en") return "English";
    if (locale.languageCode == "ru") return "Russian";
    if (locale.languageCode == "tr") return "Tajik";
    return "English";
  }

  void setCompanyId(oid) {
    companyId = oid;
    Api.instance.oid = companyId;
    saveAndNotify();
  }

}