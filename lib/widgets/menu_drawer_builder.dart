import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/constants.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:nae_hr/core/platform.dart';
import 'package:nae_hr/models/memory/bloc.dart';
import 'package:nae_hr/models/memory/event.dart';
import 'package:nae_hr/models/memory/item.dart';
import 'package:nae_hr/models/memory/state.dart';
import 'package:nae_hr/models/ui/bloc.dart';
import 'package:nae_hr/models/ui/event.dart';
import 'package:nae_hr/models/ui/state.dart';
import 'package:nae_hr/screens/common/uom/screen.dart';
import 'package:nae_hr/screens/production/orders/screen.dart';
import 'package:nae_hr/widgets/app_border.dart';
import 'package:nae_hr/widgets/my_dropdown_button.dart';
import 'package:nae_hr/widgets/scrollable_list_view.dart';
import 'package:provider/provider.dart';

class MenuDrawerBuilder extends StatelessWidget {
  const MenuDrawerBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return const MenuDrawer(); // TODO viewModel: viewModel);
  }
}

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  late MemoryBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MemoryBloc();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return BlocProvider(
        create: (_) => bloc..add(MemoryFetch("companies", const [])),
        child: FocusTraversalGroup(
            child: BlocBuilder<UiBloc, UiState>(
                builder: (context, uiState) => SizedBox(
                    width: uiState.isMenuCollapsed
                        ? 65
                        : isDesktop(context)
                            ? cDrawerWidthDesktop
                            : cDrawerWidthMobile,
                    child: Drawer(
                        child: SafeArea(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                          Expanded(
                              child: Container(
                                  color: Theme.of(context).cardColor,
                                  child: ScrollableListView(children: <Widget>[
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 3),
                                        color: Theme.of(context).cardColor,
                                        child: uiState.isMenuCollapsed
                                            ? collapsedCompanySelector()
                                            : expandedCompanySelector()),
                                    DrawerTile(
                                      ctx: ProductionOrdersScreen.route,
                                      icon: ProductionOrdersScreen.icon,
                                      title: localization
                                          .translate("production orders"),
                                      onTap: () => context.read<UiBloc>().add(
                                          ChangeView(
                                              ProductionOrdersScreen.route)),
                                      // onLongPress: () => ,
                                    ),
                                    DrawerTile(
                                      ctx: const ["products"],
                                      icon: Icons
                                          .people, // getEntityIcon(EntityType.dashboard),
                                      title: localization.translate("products"),
                                      onTap: () => context
                                          .read<UiBloc>()
                                          .add(ChangeView(const ["products"])),
                                      // onLongPress: () => ,
                                    ),
                                    DrawerTile(
                                      ctx: UomScreen.route,
                                      icon: UomScreen
                                          .icon, // getEntityIcon(EntityType.dashboard),
                                      title: localization.translate("uom"),
                                      onTap: () => context
                                          .read<UiBloc>()
                                          .add(ChangeView(UomScreen.route)),
                                      // onLongPress: () => ,
                                    ),
                                  ]))),
                          SizedBox(
                            height: cBarHeight,
                            child: AppBorder(
                              isTop: true,
                              child: Align(
                                alignment: const Alignment(0, 1),
                                child: uiState.isMenuCollapsed
                                    ? const SidebarFooterCollapsed()
                                    : const SidebarFooter(),
                              ),
                            ),
                          ),
                        ])))))));
  }

  Widget collapsedCompanySelector() {
    return const SizedBox(); // TODO PopupMenuButton<String>();
  }

  Widget expandedCompanySelector() {
    final settings = Provider.of<MySettings>(context);

    return SizedBox(
        height: cBarHeight,
        child: BlocBuilder<MemoryBloc, RequestState>(builder: (context, state) {
          MemoryItem? selected;
          for (final item in state.items) {
            if (item.id == settings.companyId) {
              selected = item;
              break;
            }
          }
          return MyDropdownButton<MemoryItem>(
              value: selected,
              items: [
                ...state.items
                    .map((company) => DropdownMenuItem<MemoryItem>(
                        value: company, child: ItemWidget(item: company)))
                    .toList(),
              ],
              onChanged: (MemoryItem? value) {
                if (value != null) {
                  setState(() => settings.setCompanyId(value.id));
                }
              });
        }));
  }
}

class SidebarFooterCollapsed extends StatelessWidget {
  const SidebarFooterCollapsed({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).cardColor,
      child: IconButton(
        icon: Icon(
          Icons.chevron_right,
          color: settings.isUpdateAvailable
              ? Theme.of(context).colorScheme.secondary
              : null,
        ),
        tooltip: settings.enableTooltips
            ? AppLocalizations.of(context).translate("show_menu")
            : null,
        onPressed: () {
          context.read<UiBloc>().add(MenuVisibility(collapsed: false));
        },
      ),
    );
  }
}

class SidebarFooter extends StatelessWidget {
  const SidebarFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);

    return Material(
        color: Theme.of(context).bottomAppBarTheme.color,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // if (isNotMobile(context))
              AppBorder(
                isLeft: true,
                child: Tooltip(
                  message: settings.enableTooltips
                      ? AppLocalizations.of(context).translate("hide_menu")
                      : '',
                  child: InkWell(
                    onTap: () => context
                        .read<UiBloc>()
                        .add(MenuVisibility(collapsed: true)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.chevron_left),
                    ),
                  ),
                ),
              )
            ]));
  }
}

class DrawerTile extends StatefulWidget {
  final List<String> ctx;
  final String title;
  final IconData icon;

  // final String entityType;

  final void Function()? onTap;
  final void Function()? onLongPress;

  const DrawerTile(
      {super.key,
      required this.ctx,
      required this.title,
      required this.icon,
      this.onTap,
      this.onLongPress});

  @override
  State<DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<DrawerTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UiBloc, UiState>(builder: (context, uiState) {
      final isSelected = uiState.currentRoute == widget.ctx;

      bool isLoading = false;

      Widget? iconWidget;
      Color color = Colors.transparent;

      Color textColor = Theme.of(context)
          .textTheme
          .bodyLarge!
          .color!
          .withOpacity(isSelected ? 1 : .7);

      Widget child = Material(
        color: color,
        child: Opacity(
          opacity: isSelected ? 1 : .8,
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 12),
            dense: true,
            leading: _isHovered && isDesktop(context) && iconWidget != null
                ? iconWidget
                : isLoading
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: SizedBox(
                          child: CircularProgressIndicator(),
                          width: 22,
                          height: 22,
                        ),
                      )
                    : FocusTraversalGroup(
                        descendantsAreFocusable: false,
                        child: IconButton(
                          icon: Icon(widget.icon),
                          color: textColor,
                          onPressed: widget.onTap,
                        ),
                      ),
            title: Text(
              widget.title,
              key: ValueKey('menu_${widget.title}'),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 14,
                    color: textColor,
                  ),
            ),
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            trailing: isMobile(context)
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: iconWidget,
                  )
                : null,
          ),
        ),
      );

      return MouseRegion(
        onEnter: (event) => setState(() => _isHovered = true),
        onExit: (event) => setState(() => _isHovered = false),
        child: child,
      );
    });
  }
}

class ItemWidget extends StatefulWidget {
  final MemoryItem item;

  const ItemWidget({super.key, required this.item});

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Expanded(child: Text(widget.item.label()))]);
  }
}
