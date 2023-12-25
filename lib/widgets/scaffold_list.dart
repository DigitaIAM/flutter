import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/widgets/icon_text.dart';
import 'package:nae/widgets/menu_drawer_builder.dart';

import '../models/ui/state.dart';

class ScaffoldList extends StatelessWidget {
  const ScaffoldList({
    super.key,
    required this.entityType,
    required this.appBarTitle,
    this.buttons,
    required this.body,
    this.onHamburgerLongPress,
    this.floatingActionButton,
  });

  final List<String>? entityType;

  final Widget appBarTitle;
  final Widget? buttons;
  final Widget body;

  final GestureLongPressCallback? onHamburgerLongPress;
  final FloatingActionButton? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return BlocBuilder<UiBloc, UiState>(builder: (context, uiState) {
      Widget leading = const SizedBox();
      if (uiState.isMobile || uiState.isMenuFloated) {
        leading = Builder(
          builder: (context) => InkWell(
            onLongPress: onHamburgerLongPress,
            child: IconButton(
              tooltip: localization.translate("menuSidebar"),
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        );
      } else if (entityType != null) {
        // TODO check can create
        leading = Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: OutlinedButton(
            // style: ButtonStyle(
            //   backgroundColor: MaterialStateProperty.all(theme.primaryColor)
            // ),
            onPressed: () {
              context.read<UiBloc>().add(ChangeView(entityType!, action: 'edit', entity: MemoryItem.create()));
            },
            child: IconText(
              text: localization.translate("create"),
              style: const TextStyle(
                color: Colors.white,
              ),
              icon: Icons.add,
              // style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      } else if (buttons != null) {
        leading = Padding(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 38), child: buttons);
      }

      double leadingWidth = (uiState.isDesktop ? 100 : 10) + (cMinInteractiveDimension * (uiState.isMobile ? 1 : 2));

      return WillPopScope(
        onWillPop: () async {
          // store.dispatch(ViewDashboard());
          return false;
        },
        child: Scaffold(
          drawer: uiState.isMobile || uiState.isMenuFloated ? const MenuDrawerBuilder() : null,
          appBar: AppBar(
              centerTitle: false,
              automaticallyImplyLeading: false,
              leading: leading,
              leadingWidth: leadingWidth,
              title: Row(children: [
                Expanded(child: appBarTitle),
              ])),
          floatingActionButton: floatingActionButton,
          body: ClipRect(
            child: body,
          ),
        ),
      );
    });
  }
}
