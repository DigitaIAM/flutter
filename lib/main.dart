import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/core/my_settings.dart';
import 'package:nae/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // await Upgrader.clearSavedSettings();

  runApp(MultiProvider(
    providers: [ChangeNotifierProvider<MySettings>(create: (_) => MySettings(prefs))],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);

    return ScreenUtilInit(
        designSize: const Size(1280, 720),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return StyledToast(
              locale: settings.locale,
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.white,
              // state.prefState.enableDarkMode ? Colors.white : Colors.black,
              textStyle: const TextStyle(
                color: Colors.black87, // state.prefState.enableDarkMode ? Colors.black87 : Colors.white,
              ),
              child: MaterialApp(
                title: "Nae",
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
                  GlobalWidgetsLocalizations.delegate,
                  FormBuilderLocalizations.delegate,
                ],
                debugShowCheckedModeBanner: false,
                locale: settings.locale,
                themeMode: ThemeMode.system,
                // settings.theme == 0 ? ThemeMode.system : (settings.theme == 2 ? ThemeMode.light : ThemeMode.dark),
                // theme: light(),
                theme: FlexThemeData.light(scheme: FlexScheme.blueWhale),
                darkTheme: FlexThemeData.dark(scheme: FlexScheme.blueWhale),
                // ThemeData.light(useMaterial3: true),
                // darkTheme: ThemeData.dark(useMaterial3: true),
                home: UpgradeAlert(child: const Wrapper()),
              ));
        });
  }

  ThemeData light() {
    const accentColor = Color(0xFF0D5D91);
    const fontFamily = kIsWeb ? 'Roboto' : null;
    const pageTransitionsTheme = PageTransitionsTheme(builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
    });
    // Intl.defaultLocale = localeSelector(state);
    // final locale = AppLocalization.createLocale(localeSelector(state));
    // _initTimeago();

    final textButtonTheme = TextButton.styleFrom(
      minimumSize: const Size(88, 36),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(cBorderRadius)),
      ),
    );

    final outlinedButtonTheme = OutlinedButton.styleFrom(
        foregroundColor: Colors.black87 // state.prefState.enableDarkMode ? Colors.white : Colors.black87,
        );

    return ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: accentColor,
        background: Colors.white,
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.white,
      ),
      tooltipTheme: const TooltipThemeData(
        waitDuration: Duration(milliseconds: 500),
      ),
      pageTransitionsTheme: pageTransitionsTheme,
      primaryColor: accentColor,
      indicatorColor: accentColor,
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: accentColor,
      ),
      fontFamily: fontFamily,
      canvasColor: Colors.white,
      cardColor: Colors.white,
      // hasAccentColor ? accentColor : const Color(0xFF0D5D91),
      primaryColorDark: const Color(0xFF0D5D91),
      //hasAccentColor ? accentColor : const Color(0xFF5dabf4),
      primaryColorLight: const Color(0xFF5dabf4),
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      tabBarTheme: TabBarTheme(
        // hasAccentColor ? Colors.white : Colors.black,
        labelColor: Colors.black,
        //hasAccentColor ? Colors.white.withOpacity(.65) : Colors.black.withOpacity(.65),
        unselectedLabelColor: Colors.black.withOpacity(.65),
      ),
      iconTheme: const IconThemeData(
        // hasAccentColor ? null : accentColor,
        color: null,
      ),
      appBarTheme: const AppBarTheme(
        // hasAccentColor ? accentColor : Colors.white,
        color: accentColor,
        iconTheme: IconThemeData(
          // hasAccentColor ? Colors.white : accentColor,
          color: Colors.white,
        ),
        // hasAccentColor ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.white),
      ),
      textButtonTheme: TextButtonThemeData(style: textButtonTheme),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonTheme),
    );
  }
}
