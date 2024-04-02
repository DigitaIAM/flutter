import 'package:flutter/material.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/common/uom/edit.dart';
import 'package:nae/screens/production/order/view.dart';
import 'package:nae/screens/wh/movements/report.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/scaffold_list.dart';

import 'report.dart';

class ProductionReportView extends Entity {
  static const List<String> ctx = ['report', 'production'];

  static List<Field> schema = [];

  @override
  List<String> route() => ctx;

  @override
  String name() => "production report";

  @override
  IconData icon() => Icons.conveyor_belt;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_'),
      // ${DateTime.now().toString()}__
      ctx: ctx,
      schema: schema,
      list: ProductionReportScreen(entity: entity),
      // TODO view document (order) on click
      view: ProductionOrderView(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
        tabIndex: 0,
      ),
    );
  }
}

class ProductionReportScreen extends EntityHolder {
  const ProductionReportScreen({super.key, required super.entity});

  @override
  State<ProductionReportScreen> createState() => _ProductionReportScreenState();
}

class _ProductionReportScreenState extends State<ProductionReportScreen> {
  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return ScaffoldList(
      entityType: null,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.WHReceiveListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      floatingActionButton: null,
      body: PReportScreen(entity: widget.entity),
      // WHMovementReportScreen(entity: widget.entity),
    );
  }
}

class PReportScreen extends EntityHolder {
  const PReportScreen({super.key, required super.entity});

  @override
  State<PReportScreen> createState() => _PReportScreenState();
}

class _PReportScreenState extends State<PReportScreen> {
  final List<MemoryItem> reports = [
    MemoryItem.from({'id': '1', cName: ''}),
  ];

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(kBottomNavigationBarHeight),
      //   child: Container(
      //     color: theme.appBarTheme.backgroundColor,
      //     child: SafeArea(
      //       child: Column(
      //         children: <Widget>[
      //           // TODO date and area selection here
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: Builder(builder: (context) {
          return Column(children: <Widget>[
            Expanded(
              child: ProReportScreen(entity: reports[0]),
            ),
          ]);
        }),
      ),
    );
  }
}
