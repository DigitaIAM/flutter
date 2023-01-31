import 'package:flutter/widgets.dart';

import 'package:nae_hr/core/my_settings.dart';
import 'package:provider/provider.dart';

bool isDesktop(BuildContext context) => Provider.of<MySettings>(context).isDesktop;
bool isMobile(BuildContext context) => !isDesktop(context);
bool isNotMobile(BuildContext context)=> !isMobile(context);

// bool isDarkMode(BuildContext context) => Provider.of<MySettings>(context).isDarkMode;