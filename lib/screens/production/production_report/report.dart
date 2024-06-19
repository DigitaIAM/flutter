import 'package:decimal/decimal.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/screens/production/production_report/excel.dart';
import 'package:nae/screens/production/production_report/screen.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/scrolling_date_calendar.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class ProReportScreen extends StatefulWidget {
  const ProReportScreen({
    super.key,
    required this.entity,
  });

  final MemoryItem entity;

  @override
  State<ProReportScreen> createState() => _ProReportScreenState();
}

class _ProReportScreenState extends State<ProReportScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_productionReport');
  final FocusScopeNode _focusNode = FocusScopeNode();

  MemoryItem formEntity = MemoryItem.empty();

  PlutoGridStateManager? stateManager;

  List<PlutoColumn>? _columns;
  List<PlutoColumnGroup>? _groups;
  List<PlutoRow>? _rows;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // print("_MovementReportScreenState.initState");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider(
      create: (ctx) {
        return MemoryBloc(schema: [])..add(request(true));
      },
      child: BlocBuilder<MemoryBloc, RequestState>(builder: (context, state) {
        if (state.event is MemoryFetch) {
          final req = request(true);
          final oldFilter = (state.event as MemoryFetch).filter;
          if (!mapEquals(
              req.filter['\$starts-with'], oldFilter['\$starts-with'])) {
            context.read<MemoryBloc>().add(req);
          }
        }
        return Column(children: [
          Row(
            children: [
              dateWidget(),
              selectedArea(context),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: exportToExcel,
                  child: const Text('Excel'),
                ),
              ),
            ],
          ),
          Expanded(
            child: Stack(alignment: Alignment.topCenter, children: <Widget>[
              tableWidget(),
            ]),
          ),
        ]);
      }),
    );
  }

  void exportToExcel() {
    final columns = _columns!;
    final groups = _groups!;
    final rows = _rows!;

    Excel excel = Excel.createExcel();

    final s = excel.getDefaultSheet();
    if (s != null) {
      excel.rename(s, 'Sheet');
    }
    Sheet sheet = excel['Sheet'];

    List<CellValue> list = [];

    List<(int, int, String)> toMerge = [];
    int index = 0;
    (int, String) last = (-1, '');

    for (PlutoColumn col in columns) {
      for (PlutoColumnGroup group in groups) {
        if (group.fields?[0] == col.field) {
          if (last.$1 != -1 && last.$1 != index - 1) {
            toMerge.add((last.$1, index - 1, last.$2));
          }
          last = (index, group.title);
        }
      }
      index += 1;
    }
    if (last.$1 != -1 && last.$1 != index - 1) {
      toMerge.add((last.$1, index - 1, last.$2));
    }

    for (final item in toMerge) {
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: item.$1, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: item.$2, rowIndex: 0),
        customValue: TextCellValue(item.$3),
      );
    }

    list = [];
    for (PlutoColumn col in columns) {
      list.add(TextCellValue(col.title));
    }
    sheet.appendRow(list);

    for (PlutoRow row in rows) {
      list = [];
      for (PlutoColumn col in columns) {
        // TODO number and formula
        final v = row.cells[col.field]?.value;

        if (v is Decimal) {
          if (v.isInteger) {
            list.add(IntCellValue(v.toBigInt().toInt()));
          } else {
            list.add(DoubleCellValue(v.toDouble()));
          }
        } else {
          list.add(TextCellValue(v?.toString() ?? ''));
        }
      }
      sheet.appendRow(list);
    }

    excel.save(fileName: "export.xlsx");
  }

  Widget dateWidget() {
    final selectedDate = _selectedDate();
    DateTime startDate = selectedDate.subtract(const Duration(days: 365 * 2));
    DateTime endDate = selectedDate.add(const Duration(days: 31));

    return SizedBox(
      width: 300,
      height: 60,
      child: ScrollingDayCalendar(
        startDate: startDate,
        endDate: endDate,
        selectedDate: selectedDate,
        onDateChange: (_, DateTime date) {
          setState(() {
            widget.entity.json['date'] = date;
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
      ),
    );
  }

  Widget selectedArea(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return SizedBox(
      width: 300,
      height: 60,
      child: AppForm(
        formKey: _formKey,
        focusNode: _focusNode,
        entity: formEntity,
        schema: const [fArea],
        onChanged: () {
          final state = _formKey.currentState!;
          state.save();

          // print("state.value ${state.value}");

          MemoryItem? area = state.value[cArea];
          setState(() {
            formEntity = MemoryItem(
              id: formEntity.id,
              json: {cArea: area ?? MemoryItem.empty()},
            );

            // print("area selected ${area?.json}");
            widget.entity.json[cArea] = area?.id;
            widget.entity.json[cName] = area?.name() ?? '';
            // widget.updateReport(widget.entity);
          });

          // debugPrint("report onChanged: $selectedArea");
        },
        child: DecoratedFormPickerField(
          creatable: false,
          ctx: const [cProduction, cArea],
          name: cArea,
          label: localization.translate('area'),
          autofocus: true,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
          onSave: (context) {},
          // keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  void reset() {
    // print("reset $selectedArea");
    // if (!(selectedArea?.isEmpty ?? true)) {
    //   //  print("fetching ${selectedArea?.isEmpty ?? false}");
    //   final strDate = selectedDate.toString().substring(0, 7);
    //   final areaId = selectedArea!.id;
    //
    //   final filters = {"date": strDate, "area": areaId};
    //   context.read<MemoryBloc>().add(MemoryFetch(
    //     'memories',
    //     const ['production', 'order'],
    //     schema: ProductionReportView.schema,
    //     limit: 100,
    //     // search: widget.search,
    //     filter: {
    //       "\$starts-with": filters,
    //     },
    //     reset: true,
    //   ));
    // } else {
    //   context.read<MemoryBloc>().add(MemoryFetch(
    //     'memories',
    //     const ['production', 'order'],
    //     schema: ProductionReportView.schema,
    //     limit: 0,
    //     reset: true,
    //   ));
    // }
  }

  DateTime _selectedDate() {
    return widget.entity.json['date'] ?? DT.today();
  }

  String _selectedArea() {
    return widget.entity.json[cArea] ?? '';
  }

  Widget tableWidget() {
    final selectedDate = _selectedDate();
    final selectedArea = _selectedArea();
    return BlocBuilder<MemoryBloc, RequestState>(
      key: ValueKey('__reportTable_$selectedDate'),
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
            if (selectedArea.isNotEmpty) {
              loadMore(context, state);
              return const Center(child: Text('loading'));
            } else {
              return const Center(child: Text(''));
            }
        }
      },
    );
  }

  void loadMore(BuildContext context, RequestState state) {
    if (!state.hasReachedMax) {
      context.read<MemoryBloc>().add(request(false));
    }
  }

  MemoryFetch request(bool reset) {
    final selectedArea = _selectedArea();
    if (selectedArea.isNotEmpty) {
      final selectedDate = _selectedDate();
      final date = selectedDate.toString().substring(0, 7);

      return MemoryFetch(
        'memories',
        const ['production', 'order'],
        schema: ProductionReportView.schema,
        limit: 100,
        // search: widget.search,
        filter: {
          "\$starts-with": {"date": date, "area": selectedArea},
        },
        reset: reset,
      );
    } else {
      return MemoryFetch(
        'memories',
        const ['production', 'order'],
        schema: ProductionReportView.schema,
        limit: 0,
        reset: true,
      );
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
      // if (produced.isNotEmpty) {
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
      // }

      Map? material = json['_material'];

      // print('material $material');

      if (material != null && material.isNotEmpty) {
        final used = material['used'];
        if (used != null && used.isNotEmpty) {
          for (Map value in used) {
            final keyUsed = 'used ${value['goods']?['name'] ?? ''}';

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

            final qty = Qty.fromJson(value['qty']);

            cells[keyProduced] = PlutoCell(value: qty);

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
        // print("sum $sum");
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

    _rows = rows;
    _columns = columns;
    _groups = columnGroups;

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
