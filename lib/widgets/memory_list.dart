import 'dart:async';

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
import 'package:nae/widgets/swipe_action.dart';
import 'package:overflow_view/overflow_view.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

import '../models/ui/state.dart';

IconData? getActionIcon(String action) {
  // return Icons.warning;
  return null;
}

class MemoryBlocHolder extends StatefulWidget {
  const MemoryBlocHolder({super.key, this.schema, this.init, required this.child});

  final List<Field>? schema;
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
    bloc = MemoryBloc(schema: widget.schema);
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

enum Mode { auto, desktop, mobile }

class MemoryList extends StatefulWidget {
  final Mode mode;
  final String service;
  final List<String> ctx;
  final List<Field> schema;

  final int? limit;
  final String? search;
  final Map<String, dynamic> filter;
  List<MemoryItem> Function(List<MemoryItem>)? preprocess = (items) => items;

  final MemoryItem Function(MemoryItem)? groupBy;
  final int Function(MemoryItem, MemoryItem)? groupComparator;
  final bool sortByName;

  final Widget Function(MemoryItem) title;
  final Widget Function(MemoryItem) subtitle;
  final Function(BuildContext, MemoryItem)? onTap;

  final List<ItemAction> actions;

  MemoryList({
    super.key,
    required this.ctx,
    required this.schema,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.groupBy,
    this.groupComparator,
    this.sortByName = false,
    this.limit,
    this.search,
    this.filter = const {},
    this.service = 'memories',
    this.actions = const [],
    this.preprocess,
    this.mode = Mode.auto,
  });

  @override
  State<StatefulWidget> createState() => _MemoryListState();
}

class _MemoryListState extends State<MemoryList> {
  PlutoGridStateManager? stateManager;

  late ScrollController _scrollController;
  VoidCallback? listener;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void loadMore(UiState uiState, RequestState state) {
    // print("loadMore ${state.hasReachedMax} $isLoading");
    if (!state.hasReachedMax) {
      if (uiState.isMobile) {
        if (isLoading) {
          return;
        }
        isLoading = true;
      }
      context.read<MemoryBloc>().add(MemoryFetch(
            widget.service,
            widget.ctx,
            schema: widget.schema,
            limit: widget.limit,
            search: widget.search,
            filter: widget.filter,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final List<String> actions = [];

    return BlocBuilder<UiBloc, UiState>(
      builder: (_, uiState) => RefreshIndicator(
        onRefresh: () async {
          // print("onRefresh");
          context.read<MemoryBloc>().add(MemoryFetch(
                widget.service,
                widget.ctx,
                schema: widget.schema,
                limit: widget.limit,
                search: widget.search,
                filter: widget.filter,
                reset: true,
              ));

          await Future.delayed(
            const Duration(seconds: 1),
          );
        }, // widget.onRefreshed(context),
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

    return BlocBuilder<MemoryBloc, RequestState>(
      buildWhen: (o, n) {
        isLoading = false;
        if (uiState.isMobile) {
          return true;
        }
        return o.status != n.status;
      },
      builder: (context, state) {
        // print("builder ${state.status}");
        switch (state.status) {
          case RequestStatus.failure:
            return Center(child: Text(localization.translate('failed to fetch data')));
          case RequestStatus.success:
            if (state.items.isEmpty) {
              return Center(child: Text(localization.translate('nothing yet')));
            }
            if ((widget.mode == Mode.auto && uiState.isMobile) || widget.mode == Mode.mobile) {
              return buildList(context, uiState, state);
            } else {
              return buildPlutoGrid(context, uiState, state);
            }
          case RequestStatus.initiate:
            if ((widget.mode == Mode.auto && uiState.isMobile) || widget.mode == Mode.mobile) {
              // trigger initial load
              loadMore(uiState, state);
              return const Center(child: CircularProgressIndicator());
            } else {
              // PlutoGrid trigger initial load
              return buildPlutoGrid(context, uiState, state);
            }
        }
      },
    );
  }

  Widget buildList(BuildContext context, UiState uiState, RequestState state) {
    if (listener != null) {
      _scrollController.removeListener(listener!);
    }
    listener = () {
      var nextPageTrigger = _scrollController.position.maxScrollExtent - 500;
      if (_scrollController.position.pixels > nextPageTrigger) {
        loadMore(uiState, state);
      }
    };
    _scrollController.addListener(listener!);

    final items = sort(state.items, widget.sortByName);
    if (widget.groupBy != null) {
      return GroupedListView<MemoryItem, MemoryItem>(
        elements: items,
        groupBy: widget.groupBy!,
        groupComparator: widget.groupComparator ?? (g1, g2) => g2.name().compareTo(g1.name()),
        itemComparator: (item1, item2) => item1.name().toLowerCase().compareTo(item2.name().toLowerCase()),
        order: GroupedListOrder.ASC,
        useStickyGroupSeparators: true,
        stickyHeaderBackgroundColor: Theme.of(context).secondaryHeaderColor,
        controller: _scrollController,
        groupSeparatorBuilder: (MemoryItem value) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value.name(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        itemBuilder: (context, item) {
          if (widget.actions.isEmpty) {
            return card(context, item);
          }
          return SwipeActionWidget(
            item: item,
            actions: widget.actions,
            // key: key,
            child: card(context, item),
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: items.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          final item = items[index];
          if (widget.actions.isEmpty) {
            return card(context, item);
          }
          return SwipeActionWidget(
            item: item,
            actions: widget.actions,
            // key: key,
            child: card(context, item),
          );
        },
      );
    }
  }

  dynamic groupBy(BuildContext context, String filter, Map element) {
    final localization = AppLocalizations.of(context);

    if (filter == cDate) {
      return element[cDate] ?? '';
    } else if (filter == cCategory) {
      return localization.translate(element['_category']) ?? '';
    } else {
      return '';
    }
  }

  Widget card(BuildContext context, MemoryItem item) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        // leading: const Icon(Icons.account_circle),
        title: widget.title(item),
        subtitle: widget.subtitle(item),
        trailing: widget.onTap == null ? null : const Icon(Icons.arrow_forward),
        onTap: () {
          widget.onTap?.call(context, item);
        },
      ),
    );
  }

  PlutoGrid buildPlutoGrid(BuildContext context, UiState uiState, RequestState state) {
    final localization = AppLocalizations.of(context);

    final List<PlutoColumn> columns = widget.schema.where((field) => field.type is! ListType).map((field) {
      PlutoColumnType type = PlutoColumnType.text();
      bool isNumber = false;
      if (field.type is NumberType) {
        isNumber = true;
        type = PlutoColumnType.text();
      } else if (field.type is DateType) {
        type = PlutoColumnType.date();
      } else if (field.type is ReferenceType) {
        type = PlutoColumnType.text();
      }

      return PlutoColumn(
        title: localization.translate(field.name.replaceAll('~', '')),
        field: field.name,
        type: type,
        textAlign: isNumber ? PlutoColumnTextAlign.end : PlutoColumnTextAlign.start,
      );
    }).toList();

    final theme = Theme.of(context);
    final DataTableThemeData dataTableTheme = DataTableTheme.of(context);

    // final Set<MaterialState> selected = <MaterialState>{
    //   MaterialState.selected,
    // };

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
          gridBackgroundColor: theme.colorScheme.background,
          rowColor: theme.colorScheme.background,

          gridBorderColor: theme.colorScheme.background,
          borderColor: theme.colorScheme.background,

          oddRowColor: theme.colorScheme.secondary.withAlpha(5),
          evenRowColor: theme.colorScheme.secondary.withAlpha(15),

          activatedColor: theme.colorScheme.secondary.withAlpha(25),
          // activatedColor: theme.dataTableTheme.dataRowColor?.resolve(selected) ?? theme.indicatorColor,

          columnTextStyle: theme.textTheme.bodySmall!,
          // columnTextStyle: const TextStyle(
          //   color: Colors.black,
          //   decoration: TextDecoration.none,
          //   fontSize: 14,
          //   fontWeight: FontWeight.w600,
          // ),
          cellTextStyle: theme.textTheme.bodyMedium!,
          // cellTextStyle: const TextStyle(
          //   color: Colors.black,
          //   fontSize: 14,
          // ),
          menuBackgroundColor: theme.colorScheme.background,
          // theme.dropdownMenuTheme.menuStyle?.backgroundColor?.resolve(<MaterialState>{}) ?? Colors.white,
        ));

    return PlutoGrid(
      key: ValueKey('__${state.query}_${state.created.toString()}__'),
      columns: columns,
      rows: intoRows(state, null),
      // columnGroups: columnGroups,
      configuration: config,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        stateManager = event.stateManager;
        // stateManager.setShowColumnFilter(true);
        stateManager?.setSelectingMode(PlutoGridSelectingMode.row);
        // stateManager?.setShowColumnFilter(true);
      },
      onChanged: (PlutoGridOnChangedEvent event) {
        print(event);
      },
      onSelected: (PlutoGridOnSelectedEvent event) {
        final item = event.row?.cells["_memory_"]?.value;
        if (item is MemoryItem) {
          widget.onTap?.call(context, item);
        }
      },
      mode: PlutoGridMode.select,
      createFooter: (stateManager) => InfinityScroll(
        intoRows: intoRows,
        initialFetch: true,
        fetchWithSorting: false,
        fetchWithFiltering: false,
        fetch: (r) => loadMore(uiState, state),
        stateManager: stateManager,
      ),
    );
  }

  List<PlutoRow> intoRows(RequestState state, PlutoRow? lastRow) {
    var items = sort(state.items, widget.sortByName);
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
            label = ref.name();
          }
          cells[field.name] = PlutoCell(value: label);
        } else {
          cells[field.name] = PlutoCell(value: field.resolve(item.json) ?? "");
        }
      }
      return PlutoRow(key: ValueKey('__${item.id}'), cells: cells);
    }));
  }

  List<MemoryItem> sort(List<MemoryItem> items, bool sortByName) {
    final List<MemoryItem> localItems = widget.preprocess?.call(items) ?? items;
    if (sortByName) {
      localItems.sort((a, b) {
        String la = '';
        String lb = '';

        if (a.json['_category'] == cGoods && b.json['_category'] == cGoods) {
          final ga = a.json[cGoods];
          if (ga != null && ga is MemoryItem) {
            la = ga.name();
          }

          final gb = b.json[cGoods];
          if (gb != null && gb is MemoryItem) {
            lb = gb.name();
          }
        } else if (a.json['_category'] == cBatch && b.json['_category'] == cBatch) {
          final da = a.json[cBatch]?[cDate];
          if (da != null) {
            la = da;
          }

          final db = b.json[cBatch]?[cDate];
          if (db != null) {
            lb = db;
          }
        }

        return la.compareTo(lb);
      });
    }
    return localItems;
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

class InfinityScroll extends StatefulWidget {
  const InfinityScroll({
    required this.intoRows,
    this.initialFetch = true,
    this.fetchWithSorting = true,
    this.fetchWithFiltering = true,
    required this.fetch,
    required this.stateManager,
    super.key,
  });

  final bool initialFetch;

  final bool fetchWithSorting;
  final bool fetchWithFiltering;

  final void Function(PlutoInfinityScrollRowsRequest) fetch;

  final PlutoGridStateManager stateManager;

  final List<PlutoRow> Function(RequestState state, PlutoRow? lastRow) intoRows;

  @override
  State<InfinityScroll> createState() => _InfinityScrollState();
}

class _InfinityScrollState extends State<InfinityScroll> {
  late final StreamSubscription<PlutoGridEvent> _events;

  bool _isFetching = false;

  bool _isLast = false;

  PlutoGridStateManager get stateManager => widget.stateManager;

  ScrollController get scroll => stateManager.scroll.bodyRowsVertical!;

  @override
  void initState() {
    super.initState();

    if (widget.fetchWithSorting) {
      stateManager.setSortOnlyEvent(true);
    }

    if (widget.fetchWithFiltering) {
      stateManager.setFilterOnlyEvent(true);
    }

    _events = stateManager.eventManager!.listener(_eventListener);

    scroll.addListener(_scrollListener);

    if (widget.initialFetch) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _update(null);
      });
    }
  }

  @override
  void dispose() {
    scroll.removeListener(_scrollListener);

    _events.cancel();

    super.dispose();
  }

  void _eventListener(PlutoGridEvent event) {
    if (event is PlutoGridCannotMoveCurrentCellEvent && event.direction.isDown && !_isFetching) {
      _update(stateManager.refRows.last);
    } else if (event is PlutoGridChangeColumnSortEvent) {
      _update(null);
    } else if (event is PlutoGridSetColumnFilterEvent) {
      _update(null);
    }
  }

  void _scrollListener() {
    if (scroll.offset == scroll.position.maxScrollExtent && !_isFetching) {
      _update(stateManager.refRows.last);
    }
  }

  void _update(PlutoRow? lastRow) {
    if (lastRow == null) _isLast = false;

    if (_isLast) return;

    _isFetching = true;

    stateManager.setShowLoading(
      true,
      level: PlutoGridLoadingLevel.rows,
      // lastRow == null ? PlutoGridLoadingLevel.rows : PlutoGridLoadingLevel.rowsBottomCircular,
    );

    final request = PlutoInfinityScrollRowsRequest(
      lastRow: lastRow,
      sortColumn: stateManager.getSortedColumn,
      filterRows: stateManager.filterRows,
    );

    print("fetch");
    widget.fetch(request);
  }

  void fetched(PlutoInfinityScrollRowsResponse response) {
    // if (lastRow == null) {
    //   scroll.jumpTo(0);
    //   stateManager.removeAllRows(notify: false);
    // }

    stateManager.appendRows(response.rows);

    stateManager.setShowLoading(false);

    _isFetching = false;

    _isLast = response.isLast;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MemoryBloc, RequestState>(
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          final rows = stateManager.refRows;
          fetched(PlutoInfinityScrollRowsResponse(
            isLast: state.hasReachedMax,
            rows: widget.intoRows(state, rows.isNotEmpty ? rows.last : null),
          ));
        });
      },
      child: const SizedBox.shrink(),
    );
  }
}
