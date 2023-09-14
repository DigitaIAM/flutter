import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/models/ui/state.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/production/order/view.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/scaffold_list.dart';
import 'package:nae/widgets/scrolling_date_calendar.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ProductionReportView extends Entity {
  static const List<String> ctx = ['report', 'production'];

  static final List<Field> schema = [
    const Field('document', ReferenceType(['document'])),
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "production report";

  @override
  IconData icon() => Icons.production_quantity_limits;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}'),
      ctx: ctx,
      schema: schema,
      list: const ProductionReportScreen(),
      // TODO view document (order) on click
      view: ProductionOrderView(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
        tabIndex: 0,
      ),
    );
  }
}

class ProductionReportScreen extends StatefulWidget {
  const ProductionReportScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProductionReportScreenState();
}

class _ProductionReportScreenState extends State<ProductionReportScreen> {
  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    Widget pageItems = ProductionReportPlutoGrid(selectedDate);
    DateTime startDate = DateTime.now().subtract(const Duration(days: 365 * 2));
    DateTime endDate = DateTime.now().add(const Duration(days: 31));
    // String widgetKeyFormat = "yyyy-MM-dd";

    return ScaffoldList(
      entityType: null,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.productionOrderListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      buttons: const Row(
        // TODO add widget for choosing month and widget for choosing area
        children: [],
      ),
      // body: const ProductionReportPlutoGrid(),
      body: ScrollingDayCalendar(
        startDate: startDate,
        endDate: endDate,
        selectedDate: selectedDate,
        onDateChange: (_, DateTime date) {
          setState(() {
            // TODO need some sort of listener to change state?
            selectedDate = date;
            pageItems = ProductionReportPlutoGrid(date);
          });
        },
        dateStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        pageItems: pageItems,
        displayDateFormat: "MM/yyyy",
        dateBackgroundColor: Colors.grey,
        forwardIcon: Icons.arrow_forward,
        backwardIcon: Icons.arrow_back,
        pageChangeDuration: const Duration(
          milliseconds: 400,
        ),
        noItemsWidget: const Center(
          child: Text("No items have been added for this date"), // add buttons etc here to add new items for date
        ),
      ),
    );
  }
}

class ProductionReportPlutoGrid extends StatefulWidget {
  const ProductionReportPlutoGrid(this.date, {Key? key}) : super(key: key);

  // final void Function(BuildContext) loadMore;
  // final RequestState stateData;
  final DateTime date;

  @override
  State<StatefulWidget> createState() => _ProductionReportPlutoGrid();
}

class _ProductionReportPlutoGrid extends State<ProductionReportPlutoGrid> {
  PlutoGridStateManager? stateManager;

  late ScrollController _scrollController;

  final List<PlutoColumn> columns = [];

  List<PlutoRow> rows = [];

  final List<PlutoColumnGroup> columnGroups = [];

  @override
  void initState() {
    super.initState();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return buildPlutoGrid(context);
  // }

  void loadMore(BuildContext context, RequestState state, Map<String, String> filters) {
    if (!state.hasReachedMax) {
      context.read<MemoryBloc>().add(MemoryFetch(
            'memories',
            const ['production', 'order'],
            schema: ProductionReportView.schema,
            limit: 100,
            // search: widget.search,
            filter: {
              "\$starts-with": filters,
            },
            reset: true,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UiBloc, UiState>(
      builder: (_, uiState) => RefreshIndicator(
        onRefresh: () async {
          print("onRefresh");
          // loadMore(context);
          //
          // await Future.delayed(
          //   const Duration(seconds: 1),
          // );
        }, // widget.onRefreshed(context),
        child: Column(children: [
          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                getTable(uiState),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget getTable(UiState uiState) {
    // final localization = AppLocalizations.of(context);

    return BlocBuilder<MemoryBloc, RequestState>(
      // buildWhen: (o, n) {
      //   // isLoading = false;
      //   if (uiState.isMobile) {
      //     return true;
      //   }
      //   return o.status != n.status;
      // },
      builder: (context, state) {
        // print("builder ${state.status}");
        switch (state.status) {
          case RequestStatus.failure:
            return const Center(child: Text('failed to fetch data'));
          case RequestStatus.success:
            if (state.items.isEmpty) {
              return const Center(child: Text('nothing yet'));
            }

            return buildPlutoGrid(context, state);
          // if ((widget.mode == Mode.auto && uiState.isMobile) || widget.mode == Mode.mobile) {
          //   return buildList(context, uiState, state);
          // } else {
          //   return buildPlutoGrid(context, uiState, state);
          // }
          case RequestStatus.initiate:
            final date = widget.date.toString().substring(0, 7);
            print('__date $date');
            loadMore(context, state, {"date": date});
            return const Center(child: Text('loading'));
        }
      },
    );
  }

  List<Set<String>> getDataForColumns(List<MemoryItem> data) {
    List<Set<String>> result = [];
    Set<String> produced = {};
    Set<String> materialUsed = {};
    Set<String> materialProduced = {};

    for (MemoryItem item in data) {
      final json = item.json;

      String? product = json['product'];
      if (product != null) {
        produced.add(json['product']);
      }

      Map? material = json['_material'];
      if (material != null && material.isNotEmpty) {
        List? used = material['used'];
        if (used != null && used.isNotEmpty) {
          for (Map element in used) {
            element.forEach((key, _) {
              materialUsed.add(key);
            });
          }
        }

        List? produced = material['produced'];
        if (produced != null && produced.isNotEmpty) {
          for (Map element in produced) {
            element.forEach((key, _) {
              materialProduced.add(key);
            });
          }
        }
      }
    }

    result.add(produced);
    result.add(materialUsed);
    result.add(materialProduced);

    return result;
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
      Map<String, PlutoCell> cells = {};

      for (PlutoColumn column in columns) {
        cells[column.field] = PlutoCell(value: '');
      }

      final json = item.json;

      final date = DT.pretty(json['date'] ?? '');
      cells['date'] = PlutoCell(value: date);

      cells['area'] = PlutoCell(value: json['area'] ?? '');

      // "produced":{"piece":"1962.4","box":"8"}
      Map? produced = json['produced'];
      if (produced != null) {
        cells[json['product']] = PlutoCell(value: '${produced['piece']} шт., ${produced['box']} кор.');
      }

      Map? material = json['_material'];
      if (material != null && material.isNotEmpty) {
        List? used = material['used'];
        if (used != null && used.isNotEmpty) {
          for (Map element in used) {
            element.forEach((key, value) {
              cells[key] = PlutoCell(value: value);
            });
          }
        }

        List? produced = material['produced'];
        if (produced != null && produced.isNotEmpty) {
          for (Map element in produced) {
            element.forEach((key, value) {
              cells[key] = PlutoCell(value: value);
            });
          }
        }
      }
      return PlutoRow(key: ValueKey(item.id), cells: cells);
    }));
  }

  PlutoGrid buildPlutoGrid(BuildContext context, RequestState state) {
    print('_buildPlutoGrid');
    final theme = Theme.of(context);

    columns.add(PlutoColumn(
        title: 'date',
        field: 'date',
        type: PlutoColumnType.text(),
        titleTextAlign: PlutoColumnTextAlign.center,
        width: 100));
    columns.add(PlutoColumn(
        title: 'area',
        field: 'area',
        type: PlutoColumnType.text(),
        titleTextAlign: PlutoColumnTextAlign.center,
        width: 100));
    columnGroups.add(PlutoColumnGroup(title: 'order', fields: ['date', 'area']));

    final columnsData = getDataForColumns(state.items);

    // produced items
    List<String> producedGroupFields = [];
    for (String produced in columnsData.elementAt(0)) {
      columns.add(PlutoColumn(title: produced, field: produced, type: PlutoColumnType.text()));
      producedGroupFields.add(produced);
    }
    if (producedGroupFields.isNotEmpty) {
      columnGroups.add(PlutoColumnGroup(title: 'produced', fields: producedGroupFields));
    }

    // material used items
    List<String> materialUsedGroupFields = [];
    for (String materialUsed in columnsData.elementAt(1)) {
      columns.add(PlutoColumn(title: materialUsed, field: materialUsed, type: PlutoColumnType.text()));
      materialUsedGroupFields.add(materialUsed);
    }
    if (materialUsedGroupFields.isNotEmpty) {
      columnGroups.add(PlutoColumnGroup(title: 'used material', fields: materialUsedGroupFields));
    }

    // material produced items
    List<String> materialProducedGroupFields = [];
    for (String materialProduced in columnsData.elementAt(2)) {
      columns.add(PlutoColumn(title: materialProduced, field: materialProduced, type: PlutoColumnType.text()));
      materialProducedGroupFields.add(materialProduced);
    }
    if (materialProducedGroupFields.isNotEmpty) {
      columnGroups.add(PlutoColumnGroup(title: 'produced material', fields: materialProducedGroupFields));
    }

    rows = intoRows(state, null);

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
          columnTextStyle: theme.textTheme.bodySmall!,
          cellTextStyle: theme.textTheme.bodyMedium!,
          menuBackgroundColor: theme.colorScheme.background,
        ));

    return PlutoGrid(
      columns: columns,
      rows: rows,
      // rows: [],
      columnGroups: columnGroups,
      mode: PlutoGridMode.readOnly,
      configuration: config,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        stateManager = event.stateManager;
        // stateManager?.setSelectingMode(PlutoGridSelectingMode.row);
      },
      // createFooter: (stateManager) => InfinityScroll(
      //   intoRows: intoRows,
      //   initialFetch: true,
      //   fetchWithSorting: false,
      //   fetchWithFiltering: false,
      //   fetch: (r) => loadMore(context, state),
      //   stateManager: stateManager,
      // ),
    );
  }
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
