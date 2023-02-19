import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/icon_text.dart';
import 'package:overflow_view/overflow_view.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../models/ui/state.dart';

IconData? getActionIcon(String action) {
  // return Icons.warning;
  return null;
}

class MemoryBlocHolder extends StatefulWidget {
  const MemoryBlocHolder({super.key, this.init, required this.child});

  final Function(MemoryBloc bloc)? init;
  final Widget child;

  @override
  State<MemoryBlocHolder> createState() => _MemoryBlocHolderState();
}

class _MemoryBlocHolderState extends State<MemoryBlocHolder> {
  late MemoryBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MemoryBloc();
    widget.init?.call(bloc);
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => bloc,
      child: widget.child,
    );
  }
}

class MemoryList extends StatefulWidget {
  final List<String> ctx;
  final List<Field> schema;

  final String Function(MemoryItem) title;
  final String Function(MemoryItem) subtitle;
  final Function(MemoryItem) onTap;

  const MemoryList({
    super.key,
    required this.ctx,
    required this.schema,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _MemoryListState();
}

class _MemoryListState extends State<MemoryList> {
  PlutoGridStateManager? stateManager;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final List<String> actions = [];

    return BlocBuilder<UiBloc, UiState>(
      builder: (_, uiState) => RefreshIndicator(
        onRefresh: () => Future<void>(() => {}), // widget.onRefreshed(context),
        child: Column(children: [
          AnimatedContainer(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).cardColor,
            height: 0,
            // isInMultiselect ? kTopBottomBarHeight : 0,
            duration: const Duration(milliseconds: cAnimationDuration),
            curve: Curves.easeInOutCubic,
            child: AnimatedOpacity(
              opacity: 0, // isInMultiselect ? 1 : 0,
              duration: const Duration(milliseconds: cAnimationDuration),
              curve: Curves.easeInOutCubic,
              child: Row(children: [
                if (uiState.isDesktop) ...[
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("")
                      // isList
                      //   ? '($countSelected)'
                      //   : localization.countSelected
                      //   .replaceFirst(':count', '$countSelected')),
                      ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: OverflowView.flexible(
                          spacing: 8,
                          children: actions
                              .map(
                                (action) => OutlinedButton(
                                  child: IconText(
                                    icon: getActionIcon(action),
                                    text: AppLocalizations.of(context).translate(action),
                                  ),
                                  onPressed: () {
                                    // handleEntitiesActions(entities, action);
                                    // widget.onClearMultiselect();
                                  },
                                ),
                              )
                              .toList(),
                          builder: (context, remaining) {
                            return PopupMenuButton<String>(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        localization.translate("more"),
                                        style: theme.textTheme
                                            .bodySmall, // TextStyle(color: enableDarkMode ? Colors.white : Colors.black),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: theme.textTheme.bodySmall?.color ??
                                            Colors.white, // enableDarkMode ? Colors.white : Colors.black
                                      ),
                                    ],
                                  ),
                                ),
                                onSelected: (String action) {
                                  // handleEntitiesActions(entities, action);
                                  // widget.onClearMultiselect();
                                },
                                itemBuilder: (BuildContext context) {
                                  return actions.toList().sublist(actions.length - remaining).map((action) {
                                    return PopupMenuItem<String>(
                                      value: action,
                                      child: Row(
                                        children: <Widget>[
                                          Icon(getActionIcon(action), color: Theme.of(context).colorScheme.secondary),
                                          const SizedBox(width: 16.0),
                                          Text(localization.translate(action)),
                                        ],
                                      ),
                                    );
                                  }).toList();
                                });
                          }),
                    ),
                  ),
                ] else
                  ...[]
              ]),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                listOrTable(uiState),
                // if ((state.isLoading &&
                //     (isMobile(context) || !entityType.isSetting)) ||
                //     (state.isSaving &&
                //         (entityType.isSetting ||
                //             (!state.prefState.isPreviewVisible && !state.uiState.isEditing)
                //         )))
                //   const LinearProgressIndicator(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget listOrTable(UiState uiState) {
    final localization = AppLocalizations.of(context);

    return BlocBuilder<MemoryBloc, RequestState>(builder: (context, state) {
      switch (state.status) {
        case RequestStatus.failure:
          return Center(child: Text(localization.translate('failed to fetch data')));
        case RequestStatus.success:
          if (state.items.isEmpty) {
            return Center(child: Text(localization.translate('nothing yet')));
          }
          if (uiState.isMobile) {
            return buildList(context, state);
          } else {
            return buildPlutoGrid(context, state);
          }
        case RequestStatus.loading:
          return const Center(child: CircularProgressIndicator());
      }
    });
  }

  GroupedListView buildList(BuildContext context, RequestState state) {
    return GroupedListView<MemoryItem, String>(
      elements: state.items,
      groupBy: (element) => element.json['date'] ?? '',
      groupComparator: (g1, g2) => g2.compareTo(g1),
      itemComparator: (item1, item2) => item1.id.compareTo(item2.id),
      order: GroupedListOrder.ASC,
      useStickyGroupSeparators: true,
      groupSeparatorBuilder: (String value) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      itemBuilder: (context, item) {
        return Card(
          elevation: 3.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: SizedBox(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              // leading: const Icon(Icons.account_circle),
              title: Text(widget.title(item)),
              subtitle: Text(widget.subtitle(item)),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                widget.onTap(item);
              },
            ),
          ),
        );
      },
    );
  }

  PlutoGrid buildPlutoGrid(BuildContext context, RequestState state) {
    final localization = AppLocalizations.of(context);

    final List<PlutoColumn> columns = widget.schema.map((field) {
      PlutoColumnType type = PlutoColumnType.text();
      if (field.type is NumberType) {
        type = PlutoColumnType.number();
      } else if (field.type is DateType) {
        type = PlutoColumnType.date();
      } else if (field.type is ReferenceType) {
        type = PlutoColumnType.text();
      }

      return PlutoColumn(
        title: localization.translate(field.name.replaceAll('~', '')),
        field: field.name,
        type: type,
      );
    }).toList();

    final theme = Theme.of(context);
    final DataTableThemeData dataTableTheme = DataTableTheme.of(context);

    final Set<MaterialState> selected = <MaterialState>{
      MaterialState.selected,
    };

    final MaterialStateProperty<Color?>? effectiveDataRowColor =
        dataTableTheme.dataRowColor ?? theme.dataTableTheme.dataRowColor;

    // final config = PlutoGridConfiguration.dark(
    //     enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
    //     style: PlutoGridStyleConfig.dark(
    //       gridBackgroundColor: theme.canvasColor,
    //       rowColor: theme.canvasColor,
    //     ));

    final config = PlutoGridConfiguration.dark(
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
        style: PlutoGridStyleConfig(
          gridBackgroundColor: theme.canvasColor,
          rowColor: theme.canvasColor,
          activatedColor: theme.dataTableTheme.dataRowColor?.resolve(selected) ?? theme.primaryColor,
          columnTextStyle: theme.textTheme.bodySmall!,
          // const TextStyle(
          //   color: Colors.black,
          //   decoration: TextDecoration.none,
          //   fontSize: 14,
          //   fontWeight: FontWeight.w600,
          // ),
          cellTextStyle: theme.textTheme.bodyMedium!,
          // const TextStyle(
          //   color: Colors.black,
          //   fontSize: 14,
          // ),
        ));

    return PlutoGrid(
        key: UniqueKey(),
        columns: columns,
        rows: intoRows(state, null),
        // columnGroups: columnGroups,
        configuration: config,
        onLoaded: (PlutoGridOnLoadedEvent event) {
          print(event);
          stateManager = event.stateManager;
          // stateManager.setShowColumnFilter(true);
          stateManager?.setSelectingMode(PlutoGridSelectingMode.row);
        },
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        onSelected: (PlutoGridOnSelectedEvent event) {
          final item = event.row?.cells["_memory_"]?.value;
          if (item is MemoryItem) {
            widget.onTap(item);
          }
        },
        mode: PlutoGridMode.select,
        createFooter: (stateManager) => PlutoInfinityScrollRows(
            initialFetch: true,
            fetch: (r) async {
              print('createFooter fetch ${state.hasReachedMax} ${state.status}');
              if (state.status == RequestStatus.success) {
                print('fetch more');
                context.read<MemoryBloc>().add(MemoryFetch('memories', widget.ctx, schema: widget.schema));
              }

              return PlutoInfinityScrollRowsResponse(isLast: false, rows: intoRows(state, r.lastRow));
            },
            stateManager: stateManager));
  }

  List<PlutoRow> intoRows(RequestState state, PlutoRow? lastRow) {
    var items = state.items;
    if (lastRow != null) {
      final after = lastRow.cells['_memory_']?.value;
      if (after != null) {
        final pos = items.indexOf(after);
        if (pos >= items.length) {
          return [];
        }
        items = items.sublist(pos + 1);
      }
    }
    return List.of(items.map((item) {
      final cells = {
        '_memory_': PlutoCell(value: item),
      };
      for (final field in widget.schema) {
        if (field.type is ReferenceType) {
          String label = '';
          final ref = item.json[field.name];
          if (ref is MemoryItem) {
            label = ref.json['name'] ?? '';
          }
          cells[field.name] = PlutoCell(value: label);
        } else {
          cells[field.name] = PlutoCell(value: item.json[field.name] ?? "");
        }
      }
      return PlutoRow(cells: cells);
    }));
  }

// Widget list(RequestState state) {
//   return Column(
//     mainAxisSize: MainAxisSize.min,
//     children: <Widget>[
//       // if (uiState.filterEntityId != null && isMobile(context))
//       //   ListFilterMessage(
//       //     filterEntityId: uiState.filterEntityId,
//       //     filterEntityType: uiState.filterEntityType,
//       //     onPressed: (_) => viewEntityById(
//       //         entityId: state.uiState.filterEntityId,
//       //         entityType: state.uiState.filterEntityType),
//       //     onClearPressed: () => store.dispatch(ClearEntityFilter()),
//       //   ),
//       Flexible(
//         fit: FlexFit.loose,
//         child: entityList.isEmpty
//             ? HelpText(AppLocalization.of(context).clickPlusToCreateRecord)
//             : ScrollableListViewBuilder(
//           primary: true,
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           separatorBuilder: (context, index) =>
//           (index == 0 || index == entityList.length)
//               ? SizedBox()
//               : ListDivider(),
//           itemCount: entityList.length + 2,
//           itemBuilder: (BuildContext context, index) {
//             if (index == 0 || index == entityList.length + 1) {
//               return Container(
//                 color: Theme.of(context).cardColor,
//                 height: 25,
//               );
//             } else {
//               return widget.itemBuilder(context, index - 1);
//             }
//           },
//         ),
//       ),
//     ],
//   );
// }
//
// Widget table(RequestState state) {
//   final settings = Provider.of<MySettings>(context);
//
//   final rowsPerPage = settings.prefRowsPerPage;
//
//   return Column(
//     mainAxisSize: MainAxisSize.max,
//     children: [
//       // if (uiState.filterEntityId != null && isMobile(context))
//       //   ListFilterMessage(
//       //     filterEntityId: uiState.filterEntityId,
//       //     filterEntityType: uiState.filterEntityType,
//       //     onPressed: (_) {
//       //       viewEntityById(
//       //           entityId: state.uiState.filterEntityId,
//       //           entityType: state.uiState.filterEntityType);
//       //     },
//       //     onClearPressed: () {
//       //       store.dispatch(ClearEntityFilter());
//       //     },
//       //   ),
//       Expanded(
//         child: SingleChildScrollView(
//           primary: true,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             child: AppPaginatedDataTable(
//               onSelectAll: (value) {
//                 final startIndex =
//                 min(_firstRowIndex, entityList.length - 1);
//                 final endIndex =
//                 min(_firstRowIndex + rowsPerPage, entityList.length);
//                 final entities = entityList
//                     .sublist(startIndex, endIndex)
//                     .map<BaseEntity>(
//                         (String entityId) => entityMap[entityId])
//                     .where((invoice) =>
//                 value != listUIState.isSelected(invoice.id))
//                     .toList();
//                 handleEntitiesActions(
//                     entities, EntityAction.toggleMultiselect);
//               },
//               columns: [
//                 if (!isInMultiselect) DataColumn(label: SizedBox()),
//                 ...widget.tableColumns.map((field) {
//                   String label =
//                   AppLocalization.of(context).lookup(field);
//                   if (field.startsWith('custom')) {
//                     final key = field.replaceFirst(
//                         'custom', entityType.snakeCase);
//                     label = state.company.getCustomFieldLabel(key);
//                   }
//                   return DataColumn(
//                       label: Container(
//                         child: Text(
//                           label,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       onSort: (int columnIndex, bool ascending) {
//                         widget.onSortColumn(field);
//                       });
//                 }),
//               ],
//               source: dataTableSource,
//               sortColumnIndex:
//               widget.tableColumns.contains(listUIState.sortField)
//                   ? widget.tableColumns.indexOf(listUIState.sortField)
//                   : 0,
//               sortAscending: listUIState.sortAscending,
//               rowsPerPage: state.prefState.rowsPerPage,
//               onPageChanged: (row) => _firstRowIndex = row,
//               initialFirstRowIndex: _firstRowIndex,
//               availableRowsPerPage: [
//                 10,
//                 25,
//                 50,
//                 100,
//               ],
//               onRowsPerPageChanged: (value) {
//                 store.dispatch(UpdateUserPreferences(rowsPerPage: value));
//               },
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }
}
