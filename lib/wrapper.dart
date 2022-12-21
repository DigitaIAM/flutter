import 'package:nae_hr/core/my_settings.dart';
import 'package:nae_hr/screens/login.dart';
import 'package:nae_hr/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);

    if (settings.token.isEmpty) {
      return const LoginPage();
    } else {
      return const HomePage();
    }
  }
}
