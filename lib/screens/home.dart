import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae_hr/models/ui/bloc.dart';
import 'package:nae_hr/widgets/app_border.dart';
import 'package:nae_hr/widgets/change_layout_banner.dart';
import 'package:nae_hr/widgets/menu_drawer_builder.dart';

import '../models/ui/state.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UiBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = UiBloc();
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
      child: SafeArea(
        child: Column(children: [
          Expanded(
            child: ChangeLayoutBanner(
              child: Builder(builder: (context) => content(context)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget content(BuildContext context) {
    bool showFilterSidebar = false;

    return BlocBuilder<UiBloc, UiState>(
      builder: (context, uiState) => Row(children: <Widget>[
        if (uiState.showMenu) const MenuDrawerBuilder(),
        Expanded(
          child: AppBorder(
            isLeft: uiState.showMenu && (!uiState.isFullScreen || showFilterSidebar),
            child: uiState.entityScreen(),
          ),
        ),
      ]),
    );
  }
}
