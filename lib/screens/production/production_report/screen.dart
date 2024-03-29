import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/models/ui/state.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/production/order/view.dart';
import 'package:nae/screens/wh/goods_dispatch.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/scaffold_list.dart';
import 'package:nae/widgets/scrolling_date_calendar.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class ProductionReportView extends Entity {
  static const List<String> ctx = ['report', 'production'];

  static final List<Field> schema = [];

  @override
  List<String> route() => ctx;

  @override
  String name() => "production report";

  @override
  IconData icon() => Icons.conveyor_belt;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}'),
      ctx: ctx,
      schema: schema,
      list: ProductionReportScreen(DateTime.now()),
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
  const ProductionReportScreen(this.initDate, {super.key});

  final DateTime initDate;

  @override
  State<StatefulWidget> createState() => _ProductionReportScreenState();
}

class _ProductionReportScreenState extends State<ProductionReportScreen> {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_uomEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  late DateTime selectedDate;
  MemoryItem? selectedArea;
  MemoryItem formEntity = MemoryItem.empty();

  @override
  initState() {
    super.initState();

    selectedDate = widget.initDate;

    // print('initState selectedArea ${widget.initDate} $selectedArea');
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    // print('build selectedArea $selectedArea');

    // Widget pageItems = ProductionReportPlutoGrid(selectedDate, key: UniqueKey());
    DateTime startDate = selectedDate.subtract(const Duration(days: 365 * 2));
    DateTime endDate = selectedDate.add(const Duration(days: 31));

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
          // TODO add widget for choosing area
          children: [],
        ),
        // body: const ProductionReportPlutoGrid(),
        body: Column(
          children: [
            SizedBox(
                height: 60,
                child: Row(
                  children: [
                    SizedBox(
                        width: 300,
                        height: 60,
                        child: ScrollingDayCalendar(
                          startDate: startDate,
                          endDate: endDate,
                          selectedDate: selectedDate,
                          onDateChange: (_, DateTime date) {
                            setState(() {
                              selectedDate = date;
                              reset();
                            });
                          },
                          dateStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          // pageItems: pageItems,
                          displayDateFormat: "MMMM yyyy",
                          dateBackgroundColor: Colors.grey,
                          forwardIcon: Icons.arrow_forward,
                          backwardIcon: Icons.arrow_back,
                          pageChangeDuration: const Duration(
                            milliseconds: 400,
                          ),
                          noItemsWidget: Container(),
                        )),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 300,
                      height: 60,
                      child: AppForm(
                        formKey: _formKey,
                        focusNode: _focusNode,
                        entity: formEntity,
                        schema: const [
                          Field('area', ReferenceType(['area']))
                        ],
                        onChanged: () {
                          final state = _formKey.currentState!;
                          state.save();

                          MemoryItem? area = state.value['area'];
                          setState(() {
                            formEntity = area ?? MemoryItem.empty();
                            selectedArea = area;
                            reset();
                          });

                          debugPrint("report onChanged: $selectedArea");
                        },
                        child: DecoratedFormPickerField(
                          creatable: false,
                          ctx: const ['production', 'area'],
                          name: 'area',
                          label: localization.translate('area'),
                          autofocus: true,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          onSave: (context) {},
                          // keyboardType: TextInputType.text,
                        ),
                      ),
                    ),
                  ],
                )),
            Expanded(
                child: ProductionReportPlutoGrid(selectedDate, selectedArea,
                    key: UniqueKey()))
          ],
        ));
  }

  void reset() {
    print("load more $selectedArea");
    if (!(selectedArea?.isEmpty ?? true)) {
      print("fetching ${selectedArea?.isEmpty ?? false}");
      final strDate = selectedDate.toString().substring(0, 7);
      final areaId = selectedArea!.id;

      final filters = {"date": strDate, "area": areaId};
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
    } else {
      context.read<MemoryBloc>().add(MemoryFetch(
            'memories',
            const ['production', 'order'],
            schema: ProductionReportView.schema,
            limit: 0,
            reset: true,
          ));
    }
  }
}

class ProductionReportPlutoGrid extends StatefulWidget {
  const ProductionReportPlutoGrid(this.selectedDate, this.selectedArea,
      {Key? key})
      : super(key: key);
  final DateTime selectedDate;
  final MemoryItem? selectedArea;

  @override
  State<StatefulWidget> createState() => _ProductionReportPlutoGrid();
}

class _ProductionReportPlutoGrid extends State<ProductionReportPlutoGrid> {
  PlutoGridStateManager? stateManager;

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
    return BlocBuilder<MemoryBloc, RequestState>(
      key: ValueKey('ReportTable_${widget.selectedDate}'),
      builder: (context, state) {
        switch (state.status) {
          case RequestStatus.failure:
            return const Center(child: Text('failed to fetch data'));
          case RequestStatus.success:
            if (state.items.isEmpty) {
              return const Center(child: Text('nothing yet'));
            }

            return buildPlutoGrid(context, state);
          case RequestStatus.initiate:
            if (!(widget.selectedArea?.isEmpty ?? true)) {
              final date = widget.selectedDate.toString().substring(0, 7);
              final area =
                  widget.selectedArea != null ? widget.selectedArea!.id : '';
              loadMore(context, state, {"date": date, "area": area});
              return const Center(child: Text('loading'));
            } else {
              return const Center(child: Text(''));
            }
        }
      },
    );
  }

  void loadMore(
      BuildContext context, RequestState state, Map<String, String> filters) {
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

  (Set<String>, Set<String>, Set<String>) getDataForColumns(
      List<MemoryItem> data) {
    Set<String> produced = {};
    Set<String> mUsed = {};
    Set<String> mProduced = {};

    for (MemoryItem item in data) {
      final json = item.json;

      Map? product = json['product'];

      if (product != null) {
        final partNumber = product['part_number'] ?? '';
        produced.add('${product['name'] ?? ''} $partNumber');
      }

      Map? material = json['_material'];

      if (material != null && material.isNotEmpty) {
        List? used = material['used'];
        if (used != null && used.isNotEmpty) {
          for (Map value in used) {
            mUsed.add(value['goods']?['name'] ?? '');
          }
        }

        List? produced = material['produced'];
        if (produced != null && produced.isNotEmpty) {
          for (Map value in produced) {
            mProduced.add(value['goods']?['name'] ?? '');
          }
        }
      }
    }

    return (produced, mUsed, mProduced);
  }

  List<PlutoRow> intoRows(List<PlutoColumn> columns, RequestState state) {
    var items = state.items;

    Map<String, PlutoCell> sumAll = {'date': PlutoCell(value: 'итого')};

    var result = List.of(items.map((item) {
      Map<String, PlutoCell> cells = {};

      for (PlutoColumn column in columns) {
        cells[column.field] = PlutoCell(value: '');
      }

      final json = item.json;
      // print('_json $json');

      final date =
          json['date'] != null ? json['date'].toString().substring(8) : '';
      cells['date'] = PlutoCell(value: date);

      Qty produced = Qty.fromJson(json['produced']);
      if (produced.isNotEmpty) {
        final name = json['product']?['name'] ?? '';
        final partNumber = json['product']?['part_number'] ?? '';
        final product = '$name $partNumber';

        final keyPiece = 'piece $product';
        cells[keyPiece] = PlutoCell(value: produced.lower);

        final keyBox = 'box $product';
        cells[keyBox] = PlutoCell(value: produced.upper);

        final piece = produced.lower;
        sumAll.update(
          keyPiece,
          (prev) => PlutoCell(value: prev.value + piece),
          ifAbsent: () => PlutoCell(value: piece),
        );

        final box = produced.upper;
        sumAll.update(
          keyBox,
          (prev) => PlutoCell(value: prev.value + box),
          ifAbsent: () => PlutoCell(value: box),
        );
      }

      Map? material = json['_material'];

      if (material != null && material.isNotEmpty) {
        final used = material['used'];
        if (used != null && used.isNotEmpty) {
          for (Map value in used) {
            final keyUsed = 'used ${value['goods']?['name'] ?? ''}';
            // final used = qtyToText(value['qty'] ?? '');
            final qty = Qty.fromJson(value['qty']);

            cells[keyUsed] = PlutoCell(value: qty);

            if (sumAll[keyUsed] != null) {
              final prev = sumAll[keyUsed]!.value;
              sumAll[keyUsed] = PlutoCell(value: prev + qty);
            } else {
              sumAll[keyUsed] = PlutoCell(value: qty);
            }
          }
        }

        final produced = material['produced'];
        if (produced != null && produced.isNotEmpty) {
          for (Map value in produced) {
            // final uom = value['uom']?['name'] ?? '';
            final keyProduced = 'produced ${value['goods']?['name'] ?? ''}';
            final produced = qtyToText(value['qty'] ?? '');
            cells[keyProduced] = PlutoCell(value: produced);

            final qty = Qty.fromJson(value['qty']);

            if (sumAll[keyProduced] != null) {
              final prev = sumAll[keyProduced]!.value;
              sumAll[keyProduced] = PlutoCell(value: prev + qty);
            } else {
              sumAll[keyProduced] = PlutoCell(value: qty);
            }
          }
        }

        // final baseUom = json['product']?['uom']?['name'] ?? '';

        Map? sum = material['sum'];
        if (sum != null) {
          final qty = Qty.fromJson(sum['delta']);
          cells['delta'] = PlutoCell(value: qty);

          sumAll.update(
            'delta',
            (prev) => PlutoCell(value: prev.value + qty),
            ifAbsent: () => PlutoCell(value: qty),
          );
        }
      }
      return PlutoRow(key: ValueKey(item.id), cells: cells);
    }));

    result.add(PlutoRow(key: const ValueKey('sum'), cells: sumAll));

    return result;
  }

  PlutoGrid buildPlutoGrid(BuildContext context, RequestState state) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context);

    final List<PlutoColumn> columns = [];

    columns.add(PlutoColumn(
      title: localization.translate('date'),
      field: 'date',
      type: PlutoColumnType.text(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.center,
      width: 100,
      backgroundColor: theme.dividerColor.withAlpha(30),
    ));

    final List<PlutoColumnGroup> columnGroups = [];
    // columnGroups.add(PlutoColumnGroup(
    //     title: localization.translate('order'), fields: ['date']));

    final (producedSet, mUsedSet, mProducedSet) =
        getDataForColumns(state.items);

    // produced items
    List<String> producedGroupFields = [];
    for (String produced in producedSet) {
      // workaround
      final titleInner = produced == 'Рулон полипропилен R'
          ? 'кг'
          : localization.translate('pieces');
      final titleOuter = produced == 'Рулон полипропилен R'
          ? 'рулоны'
          : localization.translate('boxes');

      columns.add(PlutoColumn(
        title: titleInner,
        field: 'piece $produced',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.end,
        width: 100,
        backgroundColor: theme.dividerColor.withAlpha(30),
      ));
      columns.add(PlutoColumn(
        title: titleOuter,
        field: 'box $produced',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.end,
        width: 100,
        backgroundColor: theme.dividerColor.withAlpha(30),
      ));

      columnGroups.add(PlutoColumnGroup(
        title: produced,
        fields: ['piece $produced', 'box $produced'],
        backgroundColor: theme.dividerColor.withAlpha(30),
      ));

      // columns.add(PlutoColumn(title: produced, field: produced, type: text));

      producedGroupFields.add(produced);
    }
    if (producedGroupFields.isNotEmpty) {
      columnGroups.add(PlutoColumnGroup(
        title: localization.translate('product'),
        fields: producedGroupFields,
      ));
    }

    // material used items
    List<String> materialUsedGroupFields = [];
    for (String materialUsed in mUsedSet) {
      columns.add(
        PlutoColumn(
          title: materialUsed,
          field: 'used $materialUsed',
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.end,
          width: 150,
          backgroundColor: theme.dividerColor,
          formatter: (v) {
            if (v is Qty) {
              return v.toStringAggregated();
            }
            return v.toString();
          },
        ),
      );
      materialUsedGroupFields.add('used $materialUsed');
    }
    if (materialUsedGroupFields.isNotEmpty) {
      columnGroups.add(PlutoColumnGroup(
        title: localization.translate('used material'),
        fields: materialUsedGroupFields,
        backgroundColor: theme.dividerColor,
      ));
    }

    // material produced items
    List<String> materialProducedGroupFields = [];
    for (String materialProduced in mProducedSet) {
      columns.add(PlutoColumn(
        title: materialProduced,
        field: 'produced $materialProduced',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.end,
        width: 150,
        backgroundColor: theme.dividerColor.withAlpha(30),
      ));
      materialProducedGroupFields.add('produced $materialProduced');
    }
    if (materialProducedGroupFields.isNotEmpty) {
      columnGroups.add(PlutoColumnGroup(
        title: localization.translate('produced material'),
        fields: materialProducedGroupFields,
        backgroundColor: theme.dividerColor.withAlpha(30),
      ));
    }

    if (materialUsedGroupFields.isNotEmpty ||
        materialProducedGroupFields.isNotEmpty) {
      columns.add(PlutoColumn(
        title: localization.translate('delta'),
        field: 'delta',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.end,
        width: 100,
        backgroundColor: theme.dividerColor,
      ));
    }

    List<PlutoRow> rows = intoRows(columns, state);

    final config = PlutoGridConfiguration.dark(
      enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
      style: PlutoGridStyleConfig(
        gridBackgroundColor: theme.colorScheme.background,
        rowColor: theme.colorScheme.background,
        gridBorderColor: theme.colorScheme.background,
        borderColor: theme.colorScheme.background,
        oddRowColor: theme.dividerColor.withAlpha(30),
        evenRowColor: theme.dividerColor.withAlpha(25),
        activatedColor: theme.colorScheme.secondary.withAlpha(25),
        columnTextStyle: theme.textTheme.bodySmall!,
        cellTextStyle: theme.textTheme.bodyMedium!,
        menuBackgroundColor: theme.colorScheme.background,
      ),
    );

    Map items = {};
    for (var element in state.items) {
      items[element.id] = element;
    }

    return PlutoGrid(
      key: UniqueKey(),
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
      onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
        final str = event.row.key.toString();
        final len = str.length - 3;
        final id = event.row.key.toString().substring(3, len);
        final MemoryItem item = items[id];
        // print("onRowDoubleTap ${item.json}");
        context
            .read<UiBloc>()
            .add(ChangeView(const ['production', 'order'], entity: item));
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
    if (event is PlutoGridCannotMoveCurrentCellEvent &&
        event.direction.isDown &&
        !_isFetching) {
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
