import 'package:decimal/decimal.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/screens/production/production_report/screen.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/scrolling_date_calendar.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:flutter/services.dart';

class KpiReportScreen extends StatefulWidget {
  const KpiReportScreen({
    super.key,
    required this.entity,
  });

  final MemoryItem entity;

  @override
  State<KpiReportScreen> createState() => _KpiReportScreenState();
}

class _KpiReportScreenState extends State<KpiReportScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_kpiReport');
  final FocusScopeNode _focusNode = FocusScopeNode();

  MemoryItem formEntity = MemoryItem.empty();

  PlutoGridStateManager? stateManager;

  @override
  bool get wantKeepAlive => true;

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
              const SizedBox(
                height: 10,
                width: 60,
              ),
              //  copy(context, )
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

  Widget tableWidget() {
    final selectedDate = _selectedDate();
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
            loadMore(context, state);
            return const Center(child: Text('loading'));
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
    final selectedDate = _selectedDate();
    final date = selectedDate.toString().substring(0, 7);

    return MemoryFetch(
      'memories',
      const ['production', 'order'],
      schema: ProductionReportView.schema,
      limit: 100,
      // search: widget.search,
      filter: {
        "\$starts-with": {"date": date} // , "area": selectedArea},
      },
      reset: reset,
    );
  }

  // person-id, product-id, (planned, produced) = decimal
  (
    Map<String, MemoryItem>,
    Map<String, MemoryItem>,
    Map<String, Map<String, Map<String, Decimal>>>
  ) prepare(List<MemoryItem> data) {
    Map<String, Map<String, Map<String, Decimal>>> agr = {};

    Map<String, MemoryItem> people = {};
    Map<String, MemoryItem> products = {};

    for (MemoryItem item in data) {
      final json = item.json;

      final personId = json['operator']['_id'];
      final productId = json['product']['_id'];
      final planned = Decimal.tryParse(json['planned']) ?? Decimal.zero;
      final produced = Qty.fromJson(json['produced']).lower;

      people[personId] = MemoryItem.from(json['operator'] ?? {});
      products[productId] = MemoryItem.from(json['product'] ?? {});

      agr.update(
        personId,
        (products) {
          products.update(
            productId,
            (numbers) {
              numbers.update(
                'planned',
                (number) => number + planned,
                ifAbsent: () => planned,
              );

              numbers.update(
                'produced',
                (number) => number + produced,
                ifAbsent: () => produced,
              );

              return numbers;
            },
            ifAbsent: () => {'planned': planned, 'produced': produced},
          );
          return products;
        },
        ifAbsent: () => {
          productId: {'planned': planned, 'produced': produced}
        },
      );
    }

    print("agr $agr");

    return (people, products, agr);
  }

  Widget excel(BuildContext context, List<PlutoRow> rows,
      List<PlutoColumn> columns, List<PlutoColumnGroup> groups) {
    exportExcel() {
      Excel excel = Excel.createExcel();

      final s = excel.getDefaultSheet();
      if (s != null) {
        excel.rename(s, 'Sheet');
      }
      Sheet sheet = excel['Sheet'];

      List<TextCellValue> list = [];

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
          // if (col.type is PlutoColumnTypeNumber) {
          //   list.add(DoubleCellValue(row.cells[col.field]?.value));
          // } else {
          list.add(TextCellValue(row.cells[col.field]?.value ?? ''));
          // }
        }
        sheet.appendRow(list);
      }

      excel.save(fileName: "export.xlsx");
    }

    return ElevatedButton(onPressed: exportExcel, child: const Text('Excel'));
  }

  // Widget copy(BuildContext context, List<PlutoRow> rows,
  //     List<PlutoColumn> columns, List<PlutoColumnGroup> groups) {
  //   var string = '';
  //
  //   for (PlutoColumn col in columns) {
  //     for (PlutoColumnGroup group in groups) {
  //       if (group.fields?[0] == col.field) {
  //         string += group.title;
  //       }
  //     }
  //     string += '\t';
  //   }
  //   string += '\n';
  //
  //   // print("string $string");
  //
  //   for (PlutoColumn col in columns) {
  //     string += '${col.title}\t';
  //   }
  //   string += '\n';
  //
  //   for (PlutoRow row in rows) {
  //     for (PlutoColumn col in columns) {
  //       string += row.cells[col.field]?.value ?? '';
  //       string += '\t';
  //     }
  //     string += '\n';
  //     // print("string $string");
  //   }
  //   return ElevatedButton(
  //     onPressed: () {
  //       Clipboard.setData(ClipboardData(text: string)).then((_) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('Данные скопированы')));
  //       });
  //     },
  //     child: const Text('Скопировать'),
  //   );
  // }

  List<PlutoRow> intoRows(
      List<PlutoColumn> columns,
      Map<String, MemoryItem> people,
      Map<String, Map<String, Map<String, Decimal>>> data) {
    // Map<String, PlutoCell> sumAll = {'person': PlutoCell(value: 'итого')};

    List<PlutoRow> result = [];
    for (final ePerson in people.entries) {
      Map<String, PlutoCell> cells = {};

      for (PlutoColumn column in columns) {
        cells[column.field] = PlutoCell(value: '');
      }

      cells['person'] = PlutoCell(value: ePerson.value.name());

      final products = data[ePerson.key] ?? {};
      for (final eProduct in products.entries) {
        for (final eNumber in eProduct.value.entries) {
          cells['${eProduct.key}_${eNumber.key}'] =
              PlutoCell(value: eNumber.value.toString());
        }

        final planned = eProduct.value['planned'] ?? Decimal.zero;
        final produced = eProduct.value['produced'] ?? Decimal.zero;

        var per = '';
        if (planned != Decimal.zero) {
          per = ((produced / planned) * Decimal.fromInt(100).toRational())
              .round()
              .toString();
        }

        cells['${eProduct.key}_per'] = PlutoCell(value: per);
      }

      result.add(PlutoRow(cells: cells));
    }
    return result;
  }

  Widget buildPlutoGrid(BuildContext context, RequestState state) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context);

    final List<PlutoColumnGroup> columnGroups = [];
    final List<PlutoColumn> columns = [];

    final (people, products, data) = prepare(state.items);

    columns.add(PlutoColumn(
      title: localization.translate('person'),
      field: 'person',
      type: PlutoColumnType.text(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.center,
      width: 150,
      backgroundColor: theme.dividerColor.withAlpha(30),
    ));

    for (final product in products.entries) {
      final kPlanned = '${product.key}_planned';

      columns.add(PlutoColumn(
        title: 'план',
        field: kPlanned,
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.end,
        width: 100,
        backgroundColor: theme.dividerColor.withAlpha(30),
      ));

      final kProduced = '${product.key}_produced';
      columns.add(PlutoColumn(
        title: 'факт',
        field: kProduced,
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.end,
        width: 100,
        backgroundColor: theme.dividerColor.withAlpha(30),
      ));

      final kPer = '${product.key}_per';
      columns.add(PlutoColumn(
        title: '% от плана',
        field: kPer,
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.end,
        width: 50,
        backgroundColor: theme.dividerColor.withAlpha(30),
      ));

      columnGroups.add(PlutoColumnGroup(
        title: product.value.name(),
        fields: [kPlanned, kProduced, kPer],
        backgroundColor: theme.dividerColor.withAlpha(30),
      ));
    }

    List<PlutoRow> rows = intoRows(columns, people, data);

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

    return Column(children: [
      excel(context, rows, columns, columnGroups),
      Expanded(
          child: PlutoGrid(
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
      ))
    ]);
  }
}
