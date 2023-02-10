// bool isDesktop(BuildContext context) => Provider.of<MySettings>(context).isDesktop;
// bool isMobile(BuildContext context) => !isDesktop(context);
// bool isNotMobile(BuildContext context)=> !isMobile(context);

// bool isDarkMode(BuildContext context) => Provider.of<MySettings>(context).isDarkMode;

import 'dart:io';

import 'package:flutter/foundation.dart';

bool isDesktopOS() => isMacOS() || isWindows() || isLinux();

bool isMobileOS() => isAndroid() || isIOS();

bool isWeb() {
  return kIsWeb;
}

bool isApple() {
  if (kIsWeb) {
    return false;
  }

  return Platform.isIOS || Platform.isMacOS;
}

bool isMacOS() {
  if (kIsWeb) {
    return false;
  }

  return Platform.isMacOS;
}

bool isWindows() {
  if (kIsWeb) {
    return false;
  }

  return Platform.isWindows;
}

bool isLinux() {
  if (kIsWeb) {
    return false;
  }

  return Platform.isLinux;
}

bool isAndroid() {
  if (kIsWeb) {
    return false;
  }

  return Platform.isAndroid;
}

bool isIOS() {
  if (kIsWeb) {
    return false;
  }

  return Platform.isIOS;
}
