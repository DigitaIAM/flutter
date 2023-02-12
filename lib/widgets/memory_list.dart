import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
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

  const MemoryList({super.key, required this.ctx, required this.schema});

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
      builder: (_, uiState) => BlocBuilder<MemoryBloc, RequestState>(
        // init: (bloc) => bloc.add(MemoryFetch("memories", widget.ctx)),
        builder: (context, state) => RefreshIndicator(
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
                  listOrTable(),
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
      ),
    );
  }

  Widget listOrTable() {
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
        title: localization.translate(field.name),
        field: field.name,
        type: type,
      );
    }).toList();

    return BlocBuilder<MemoryBloc, RequestState>(builder: (context, state) {
      switch (state.status) {
        case RequestStatus.failure:
          return Center(child: Text(localization.translate('failed to fetch data')));
        case RequestStatus.success:
          if (state.items.isEmpty) {
            return Center(child: Text(localization.translate('nothing yet')));
          }
          final rows = List.of(state.items.map((item) {
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
          return buildPlutoGrid(context, columns, rows);
        case RequestStatus.loading:
          return const Center(child: CircularProgressIndicator());
      }
    });
  }

  PlutoGrid buildPlutoGrid(BuildContext context, List<PlutoColumn> columns, List<PlutoRow> rows) {
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
      rows: rows,
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
        print("onSelected");
        final item = event.row?.cells["_memory_"]?.value;
        if (item is MemoryItem) {
          print("fire ChangeView");
          context.read<UiBloc>().add(ChangeView(widget.ctx, entity: item));
        }
      },
      mode: PlutoGridMode.select,
    );
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
