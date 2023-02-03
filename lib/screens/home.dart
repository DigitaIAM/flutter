import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:nae_hr/models/ui/bloc.dart';
import 'package:nae_hr/models/ui/state.dart';
import 'package:nae_hr/widgets/app_border.dart';
import 'package:nae_hr/widgets/change_layout_banner.dart';
import 'package:nae_hr/widgets/menu_drawer_builder.dart';
import 'package:provider/provider.dart';

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
    final settings = Provider.of<MySettings>(context);
    // SizeConfig().init(context);

    bool showFilterSidebar = false;

    return BlocProvider(
        create: (_) => bloc,
        child: SafeArea(
            child: Column(children: [
          Expanded(
              child: ChangeLayoutBanner(
                  child: BlocBuilder<UiBloc, UiState>(
            builder: (context, uiState) => Row(children: <Widget>[
              if (uiState.showMenu) const MenuDrawerBuilder(),
              Expanded(
                  child: AppBorder(
                isLeft: uiState.showMenu &&
                    (!settings.isFullScreen || showFilterSidebar),
                child: uiState.entityScreen(),
              )),
            ]),
          )))
        ])));
  }
}
