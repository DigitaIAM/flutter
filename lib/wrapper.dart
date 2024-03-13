import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/core/my_settings.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/screens/home.dart';
import 'package:nae/screens/login.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  late UiBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = UiBloc.create();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => bloc, // UiBloc(),
        child: page(context));
  }

  Widget page(BuildContext context) {
    final settings = Provider.of<MySettings>(context);

    if (settings.token.isEmpty) {
      return const LoginPage();
    } else {
      return const HomePage();
    }
  }
}
