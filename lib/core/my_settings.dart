import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySettings with ChangeNotifier {

  late SharedPreferences prefs;

  String token = "";
  String userName = "";

  // TODO delete userLogin & userPsw
  String userLogin = "";
  String userPsw = "";

  int role = 0;
  String selectedCompanyId = "";

  late Locale locale = const Locale("ru", "RU");
  int theme = 0;  //0 - auto, 1 - night, 2 - blue (default)

  int timeOut = 0;

  MySettings(this.prefs) {
    load();
  }

  void load() {
    theme = prefs.getInt("theme")??0;
    locale = Locale(prefs.getString("locale_en")??"ru", prefs.getString("locale_US")??"RU");

    selectedCompanyId = prefs.getString("selectedCompanyId")??"";

    token = prefs.getString("token")??"";
    userLogin = prefs.getString("userLogin")??"";
    userName = prefs.getString("userName")??"";
    userPsw = prefs.getString("userPsw")??"";
  }

  void saveAndNotify() async {
    await save();
    notifyListeners();
  }

  Future<void> save() async {
    await prefs.setInt("theme", theme);
    await prefs.setString("locale_en", locale.languageCode);
    await prefs.setString("locale_US", locale.countryCode??"RU");

    await prefs.setString("selectedCompanyId", selectedCompanyId);

    await prefs.setString("token", token);

    await prefs.setString("userLogin", userLogin);
    await prefs.setString("userName", userName);
    await prefs.setString("userPsw", userPsw);
  }


  String getLanguage(BuildContext context) {
    if (locale.languageCode == "uz") return "Uzbek";
    if (locale.languageCode == "en") return "English";
    if (locale.languageCode == "ru") return "Russian";
    if (locale.languageCode == "tr") return "Tajik";
    return "English";
  }

}