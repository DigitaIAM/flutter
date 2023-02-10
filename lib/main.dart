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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

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
                theme: light(),
                // ThemeData.light(useMaterial3: true),
                darkTheme: ThemeData.dark(useMaterial3: true),
                home: const Wrapper(),
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
      backgroundColor: Colors.white,
      canvasColor: Colors.white,
      cardColor: Colors.white,
      bottomAppBarColor: Colors.white,
      primaryColorDark: const Color(0xFF0D5D91),
      // hasAccentColor ? accentColor : const Color(0xFF0D5D91),
      primaryColorLight: const Color(0xFF5dabf4),
      //hasAccentColor ? accentColor : const Color(0xFF5dabf4),
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.black, // hasAccentColor ? Colors.white : Colors.black,
        unselectedLabelColor: Colors.black
            .withOpacity(.65), //hasAccentColor ? Colors.white.withOpacity(.65) : Colors.black.withOpacity(.65),
      ),
      iconTheme: IconThemeData(
        color: null, // hasAccentColor ? null : accentColor,
      ),
      appBarTheme: AppBarTheme(
        color: accentColor, // hasAccentColor ? accentColor : Colors.white,
        iconTheme: IconThemeData(
          color: Colors.white, // hasAccentColor ? Colors.white : accentColor,
        ),
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.white), // hasAccentColor ? Colors.white : Colors.black),
      ),
      textButtonTheme: TextButtonThemeData(style: textButtonTheme),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonTheme),
    );
  }
}
