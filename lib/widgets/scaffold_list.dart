import 'package:flutter/material.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/constants.dart';
import 'package:nae_hr/core/platform.dart';
import 'package:nae_hr/model/ui/ui_bloc.dart';
import 'package:nae_hr/model/ui/ui_event.dart';
import 'package:nae_hr/widgets/icon_text.dart';
import 'package:nae_hr/widgets/menu_drawer_builder.dart';
import 'package:provider/provider.dart';

import '../model/memory/item.dart';

class ScaffoldList extends StatelessWidget {

  const ScaffoldList({super.key,
    required this.entityType,
    required this.appBarTitle,
    required this.body,
    this.onHamburgerLongPress,
  });

  final List<String> entityType;

  final Widget appBarTitle;
  final Widget body;

  final GestureLongPressCallback? onHamburgerLongPress;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final uiState = context.read<UiBloc>().state; // TODO move to builder

    Widget leading = const SizedBox();
    if (isMobile(context) || uiState.isMenuFloated) {
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
    } else if (entityType != null) { // TODO check can create
      leading = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: OutlinedButton(
          // style: ButtonStyle(
          //   backgroundColor: MaterialStateProperty.all(theme.primaryColor)
          // ),
          onPressed: () {
            context.read<UiBloc>().add(ChangeView(entityType, action: 'edit', entity: MemoryItem.create()));
          },
          child: IconText(
            text: localization.translate("create"),
            icon: Icons.add,
            // style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    double leadingWidth = (isDesktop(context) ? 100 : 10) +
        (cMinInteractiveDimension * (isMobile(context) ? 1 : 2));

    return WillPopScope(
        onWillPop: () async {
          // store.dispatch(ViewDashboard());
          return false;
        },
        child: Scaffold(
          drawer: isMobile(context) || uiState.isMenuFloated ? const MenuDrawerBuilder() : null,
          appBar: AppBar(
            centerTitle: false,
            automaticallyImplyLeading: false,
            leading: leading,
            leadingWidth: leadingWidth,
            title: Row(
              children: [
                Expanded(child: appBarTitle),
              ]
            )
          ),
          body: ClipRect(
            child: body,
          ),
        )
    );
  }
}