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
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/scaffold_list.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ProductionReportView extends Entity {
  static const List<String> ctx = ['production', 'material', 'produced'];

  static final List<Field> schema = [
    const Field('document', ReferenceType(['document'])),
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "produced raw material";

  @override
  IconData icon() => Icons.production_quantity_limits;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}'),
      ctx: ctx,
      schema: schema,
      list: const ProductionReportScreen(),
      view: ProductionOrderView(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
        tabIndex: 0,
      ),
    );
  }
}

class ProductionReportScreen extends StatelessWidget {
  const ProductionReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: ProductionReportView.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.productionOrderListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      body: const ProductionReportListBuilder(),
    );
  }
}

class ProductionReportListBuilder extends StatelessWidget {
  const ProductionReportListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UiBloc, UiState>(
      builder: (_, uiState) => RefreshIndicator(
        onRefresh: () async {
          print("onRefresh");
          context.read<MemoryBloc>().add(MemoryFetch(
                'memories',
                // ProductionReportView.ctx,
                const ['production', 'order'],
                schema: ProductionReportView.schema,
                // limit: widget.limit,
                // search: widget.search,
                filter: const {},
                reset: true,
              ));

          await Future.delayed(
            const Duration(seconds: 1),
          );
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
      buildWhen: (o, n) {
        // isLoading = false;
        if (uiState.isMobile) {
          return true;
        }
        return o.status != n.status;
      },
      builder: (context, state) {
        // print("builder ${state.status}");
        switch (state.status) {
          case RequestStatus.failure:
            return const Center(child: Text('failed to fetch data'));
          case RequestStatus.success:
            if (state.items.isEmpty) {
              return const Center(child: Text('nothing yet'));
            }

            final columnsData = getDataForColumns(state.items);
            return ProductionReportPlutoGrid(data: state.items, columnsData: columnsData);
          // if ((widget.mode == Mode.auto && uiState.isMobile) || widget.mode == Mode.mobile) {
          //   return buildList(context, uiState, state);
          // } else {
          //   return buildPlutoGrid(context, uiState, state);
          // }
          case RequestStatus.initiate:
            context.read<MemoryBloc>().add(MemoryFetch(
                  'memories',
                  // ProductionReportView.ctx,
                  const ['production', 'order'],
                  schema: ProductionReportView.schema,
                  limit: 1000,
                  // search: widget.search,
                  filter: const {},
                  reset: true,
                ));

            return const Center(child: Text('initiate'));
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
}

class ProductionReportPlutoGrid extends StatefulWidget {
  const ProductionReportPlutoGrid({Key? key, required this.data, required this.columnsData}) : super(key: key);

  final List<MemoryItem> data;
  final List columnsData;

  @override
  State<StatefulWidget> createState() => _ProductionReportPlutoGrid();
}

class _ProductionReportPlutoGrid extends State<ProductionReportPlutoGrid> {
  final List<PlutoColumn> columns = [];

  List<PlutoRow> rows = [];

  final List<PlutoColumnGroup> columnGroups = [];

  // late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.add(PlutoColumn(title: 'order', field: 'order', type: PlutoColumnType.text()));

    // produced items
    List<String> producedGroupFields = [];
    for (String produced in widget.columnsData.elementAt(0)) {
      columns.add(PlutoColumn(title: produced, field: produced, type: PlutoColumnType.text()));
      producedGroupFields.add(produced);
    }
    if (producedGroupFields.isNotEmpty) {
      columnGroups.add(PlutoColumnGroup(title: 'produced', fields: producedGroupFields));
    }

    // material used items
    List<String> materialUsedGroupFields = [];
    for (String materialUsed in widget.columnsData.elementAt(1)) {
      columns.add(PlutoColumn(title: materialUsed, field: materialUsed, type: PlutoColumnType.text()));
      materialUsedGroupFields.add(materialUsed);
    }
    if (materialUsedGroupFields.isNotEmpty) {
      columnGroups.add(PlutoColumnGroup(title: 'used material', fields: materialUsedGroupFields));
    }

    // material produced items
    List<String> materialProducedGroupFields = [];
    for (String materialProduced in widget.columnsData.elementAt(2)) {
      columns.add(PlutoColumn(title: materialProduced, field: materialProduced, type: PlutoColumnType.text()));
      materialProducedGroupFields.add(materialProduced);
    }
    if (materialProducedGroupFields.isNotEmpty) {
      columnGroups.add(PlutoColumnGroup(title: 'produced material', fields: materialProducedGroupFields));
    }

    rows = intoRows();
  }

  List<PlutoRow> intoRows() {
    final x = List.of(widget.data.map((item) {
      Map<String, PlutoCell> cells = {};

      for (PlutoColumn column in columns) {
        print('column.key ${column.field}');
        cells[column.field] = PlutoCell(value: '');
      }

      cells['order'] = PlutoCell(value: item.id);

      final json = item.json;

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
    print('x= ${x.first.cells}');
    return x;
  }

  @override
  Widget build(BuildContext context) {
    return PlutoGrid(
      columns: columns,
      rows: rows,
      // rows: [],
      columnGroups: columnGroups,
    );
  }
}
