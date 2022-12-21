import 'package:flutter_feathersjs/flutter_feathersjs.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:nae_hr/share/utils.dart';
import 'package:nae_hr/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MySettings>(create: (_) => MySettings(prefs))
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);

    return MaterialApp(
      title: "nae hr",
      // theme: getThemeByName(settings.themeName),
      supportedLocales: const [
        Locale("en", "US"),
        Locale("ru", "RU"),
        Locale("uz", "UZ"),
        Locale("tr", "TR")
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      themeMode: settings.theme == 0 ? ThemeMode.system : (settings.theme == 2 ? ThemeMode.light : ThemeMode.dark),
      theme: ThemeData.light(),
      darkTheme: ThemeData.light(),
      home: const Wrapper(),
    );
  }
}
