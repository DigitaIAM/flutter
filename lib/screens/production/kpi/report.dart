import 'package:decimal/decimal.dart';
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
import 'package:nae/screens/production/production_report/screen.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/scrolling_date_calendar.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

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
              selected(context),
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

  Widget selected(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return SizedBox(
      width: 700,
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

          MemoryItem? person = state.value[cOperator];
          setState(() {
            formEntity = MemoryItem(
              id: formEntity.id,
              json: {cOperator: person ?? MemoryItem.empty()},
            );

            // print("area selected ${area?.json}");
            widget.entity.json[cOperator] = person?.id;
            widget.entity.json[cOperator] = person?.name() ?? '';
            // widget.updateReport(widget.entity);
          });

          // debugPrint("report onChanged: $selectedArea");
        },
        child: Row(children: [
          Expanded(
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
          const SizedBox(
            height: 10,
            width: 60,
          ),
          Expanded(
            child: DecoratedFormPickerField(
              creatable: false,
              ctx: const ['person'],
              name: cOperator,
              label: localization.translate(cOperator),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: (context) {},
              // keyboardType: TextInputType.text,
            ),
          ),
        ]),
      ),
    );
  }

  MemoryItem getEntity() {
    if (widget.entity.isNew && widget.entity.json[cDate] == null) {
      final json = Map.of(widget.entity.json);
      json[cDate] = DateTime.now(); // Utils.today();
      return MemoryItem(id: widget.entity.id, json: json);
    } else {
      final json = Map.of(widget.entity.json);
      json[cDate] = DateTime.parse(
          json[cDate]); //DateFormat("yyyy-MM-dd").format(json[cDate]);
      return MemoryItem(id: widget.entity.id, json: json);
    }
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
          "\$starts-with": {"date": date} // , "area": selectedArea},
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

  Set<String> getDataForColumns(List<MemoryItem> data) {
    Set<String> produced = {};

    for (MemoryItem item in data) {
      final json = item.json;

      Map? product = json['product'];

      if (product != null) {
        final partNumber = product['part_number'] ?? '';
        produced.add('${product['name'] ?? ''} $partNumber');
      }
    }

    return produced;
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

      String str = json['planned']?.toString() ?? '0';
      var plan = Decimal.tryParse(str) ?? Decimal.zero;

      // if (produced.isNotEmpty) {
      final name = json['product']?['name'] ?? '';
      final partNumber = json['product']?['part_number'] ?? '';
      final product = '$name $partNumber';

      final keyPiece = 'piece $product';
      cells[keyPiece] = PlutoCell(value: produced.lower);

      final keyBox = 'box $product';
      cells[keyBox] = PlutoCell(value: produced.upper);

      final keyPlan = 'plan $product';
      print("keyPlan $keyPlan");
      cells[keyPlan] = PlutoCell(value: plan);

      sumAll.update(
        keyPlan,
        (prev) => PlutoCell(value: prev.value + plan),
        ifAbsent: () => PlutoCell(value: plan),
      );

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

    //final producedSet = getDataForColumns(state.items);

    final producedSet = getDataForColumns(state.items);

    // produced items
    List<String> producedGroupFields = [];
    for (String produced in producedSet) {
      // workaround
      final titleInner = produced == 'Рулон полипропилен R'
          ? 'кг'
          : localization.translate('pieces');

      final kPlan = 'plan $produced';
      columns.add(PlutoColumn(
        title: 'план',
        field: kPlan,
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.end,
        width: 100,
        backgroundColor: theme.dividerColor.withAlpha(30),
      ));

      final kPiece = 'piece $produced';
      columns.add(PlutoColumn(
        title: 'факт',
        field: kPiece,
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.end,
        width: 100,
        backgroundColor: theme.dividerColor.withAlpha(30),
      ));

      columnGroups.add(PlutoColumnGroup(
        title: produced,
        fields: [kPlan, kPiece],
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
