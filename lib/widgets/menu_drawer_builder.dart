import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/core/my_settings.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/models/ui/state.dart';
import 'package:nae/widgets/app_border.dart';
import 'package:nae/widgets/my_dropdown_button.dart';
import 'package:nae/widgets/scrollable_list_view.dart';
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
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => bloc..add(MemoryFetch("companies", const [])),
      child: FocusTraversalGroup(
        child: BlocBuilder<UiBloc, UiState>(
          builder: (context, uiState) => SizedBox(
            width: uiState.isMenuCollapsed
                ? cDrawerToolsWidth
                : uiState.isDesktop
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                                color: Theme.of(context).cardColor,
                                child:
                                    uiState.isMenuCollapsed ? collapsedCompanySelector() : expandedCompanySelector()),
                            ...List.generate(uiState.entities.length, (i) {
                              final list = uiState.entities[i];
                              final isLast = i == uiState.entities.length - 1;
                              return [
                                ...list.map((item) => DrawerTile(
                                      ctx: item.route(),
                                      icon: item.icon(),
                                      title: localization.translate(item.name()),
                                      onTap: () {
                                        if (uiState.isMobile) {
                                          context.read<UiBloc>().add(MenuVisibility(visible: false, collapsed: false));
                                        }
                                        context.read<UiBloc>().add(ChangeView(item.route()));
                                      },
                                      // onLongPress: () => ,
                                    )),
                                if (!isLast)
                                  Divider(
                                    height: 2,
                                    thickness: 1,
                                    indent: 2,
                                    endIndent: 2,
                                    color: theme.dividerColor,
                                  ),
                              ];
                            }).expand((element) => element)
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: cBarHeight,
                        child: AppBorder(
                          isTop: true,
                          child: Align(
                            alignment: const Alignment(0, 1),
                            child: uiState.isMenuCollapsed ? const SidebarFooterCollapsed() : const SidebarFooter(),
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget collapsedCompanySelector() {
    return const SizedBox(
      height: cBarHeight,
    ); // TODO PopupMenuButton<String>();
  }

  Widget expandedCompanySelector() {
    final settings = Provider.of<MySettings>(context);

    return SizedBox(
        height: cBarHeight,
        child: BlocBuilder<MemoryBloc, RequestState>(builder: (context, state) {
          MemoryItem? selected;
          for (final item in state.original) {
            if (item.id == settings.companyId) {
              selected = item;
              break;
            }
          }
          return MyDropdownButton<MemoryItem>(
              value: selected,
              items: [
                ...state.original
                    .map((company) => DropdownMenuItem<MemoryItem>(value: company, child: ItemWidget(item: company)))
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
          color: settings.isUpdateAvailable ? Theme.of(context).colorScheme.secondary : null,
        ),
        tooltip: settings.enableTooltips ? AppLocalizations.of(context).translate("show_menu") : null,
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
        child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          // if (isNotMobile(context))
          AppBorder(
            isLeft: true,
            child: Tooltip(
              message: settings.enableTooltips ? AppLocalizations.of(context).translate("hide_menu") : '',
              child: InkWell(
                onTap: () => context.read<UiBloc>().add(MenuVisibility(collapsed: true)),
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
      {super.key, required this.ctx, required this.title, required this.icon, this.onTap, this.onLongPress});

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

      Color textColor = Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(isSelected ? 1 : .7);

      Widget child = Material(
        color: color,
        child: Opacity(
          opacity: isSelected ? 1 : .8,
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 1),
            dense: true,
            leading: _isHovered && uiState.isDesktop && iconWidget != null
                ? iconWidget
                : isLoading
                    ? const Padding(
                        padding: EdgeInsets.only(left: 10),
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
            title: uiState.isMenuCollapsed
                ? null
                : Text(
                    widget.title,
                    key: ValueKey('menu_${widget.title}'),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 14,
                          color: textColor,
                        ),
                  ),
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            // trailing: uiState.isMobile
            //     ? Padding(
            //         padding: const EdgeInsets.only(right: 12),
            //         child: iconWidget,
            //       )
            //     : null,
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
        children: <Widget>[Expanded(child: Text(widget.item.name()))]);
  }
}
