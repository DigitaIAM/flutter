import 'package:flutter/material.dart';

ThemeData getThemeByName(String themeName) {
  switch (themeName) {
    case "LightTheme": { return lightTheme(); }
    case "PurpleTheme": { return purpleTheme(); }
    case "BrownTheme": { return brownTheme(); }
    case "RedTheme": { return redTheme(); }
    case "WhiteTheme": { return whiteTheme(); }
    case "GreenTheme": { return greenTheme(); }
    case "DarkTheme": { return darkTheme(); }
    default: { return lightTheme(); }
  }
}

ThemeData lightTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
    ),
  );
}

ThemeData purpleTheme() {
  final ThemeData base = ThemeData(primarySwatch: Colors.purple, brightness: Brightness.light);
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
    ),
  );
}

ThemeData redTheme() {
  final ThemeData base = ThemeData(primarySwatch: Colors.deepOrange, brightness: Brightness.light);
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
    ),
  );
}

ThemeData whiteTheme() {
  final ThemeData base = ThemeData(primarySwatch: Colors.grey, brightness: Brightness.light);
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
    ),
  );
}

ThemeData greenTheme() {
  final ThemeData base = ThemeData(primarySwatch: Colors.green, brightness: Brightness.light);
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
    ),
  );
}

ThemeData brownTheme() {
  final ThemeData base = ThemeData(primarySwatch: Colors.brown, brightness: Brightness.light);
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
    ),
  );
}

ThemeData darkTheme() {
  final ThemeData base = ThemeData.dark();
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
    ),
  );
}


Color getLoginColor(String _themeName) {
  switch (_themeName) {
    case "DarkTheme": {return Colors.lime; }
    case "BrownTheme": {return Colors.brown[300]!; }
    case "PurpleTheme": {return Colors.purple[300]!; }
    case "RedTheme": {return Colors.red[300]!; }
    case "GreenTheme": {return Colors.green[300]!; }
    case "WhiteTheme": {return Colors.white; }
    default: {return Colors.green; }
  }
}


Color getNavigationBarColor(String _themeName) {
  switch (_themeName) {
    case "DarkTheme": {return Colors.black; }
    case "PurpleTheme": {return Colors.purple[100]!; }
    case "RedTheme": {return Colors.red[100]!; }
    case "WhiteTheme": {return Colors.white; }
    case "GreenTheme": {return Colors.green[100]!; }
    case "BrownTheme": {return Colors.brown[200]!; }
    default: {return Colors.white; }
  }
}


Brightness getBrightness(String _themeName) {
  switch (_themeName) {
    case "DarkTheme": {return Brightness.light; }
    default: {return Brightness.dark; }
  }
}