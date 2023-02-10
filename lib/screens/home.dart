import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/widgets/app_border.dart';
import 'package:nae/widgets/change_layout_banner.dart';
import 'package:nae/widgets/menu_drawer_builder.dart';

import '../models/ui/state.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UiBloc, UiState>(
      builder: (context, uiState) => SafeArea(
        child: Column(children: [
          Expanded(
            child: ChangeLayoutBanner(
              child: content(context, uiState),
            ),
          ),
        ]),
      ),
    );
  }

  Widget content(BuildContext context, UiState uiState) {
    bool showFilterSidebar = false;

    return Row(children: <Widget>[
      if (uiState.showMenu) const MenuDrawerBuilder(),
      Expanded(
        child: AppBorder(
          isLeft: uiState.showMenu && (!uiState.isFullScreen || showFilterSidebar),
          child: uiState.entityScreen(),
        ),
      ),
    ]);
  }
}
