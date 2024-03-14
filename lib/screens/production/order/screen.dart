import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_list.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';

import 'edit.dart';
import 'view.dart';

class ProductionOrder extends Entity {
  static const List<String> ctx = ['production', 'order'];

  static final List<Field> schema = [
    fDate,
    const Field('planned', NumberType()),
    Field(
      'produced~',
      CalculatedType((MemoryItem order) async {
        final produced = Qty.fromJson(order.json['produced']);

        var text = '';

        final upper = produced.upper;
        final upperUOM = produced.upperUOM;
        if (upperUOM != null) {
          final uom = await upperUOM.resolve();
          text += '$upper ${uom.name()}';
        }

        final lower = produced.lower;
        final lowerUOM = produced.lowerUOM;
        if (lowerUOM != null) {
          if (text.isNotEmpty) {
            text += ', ';
          }
          final uom = await lowerUOM.resolve();
          text += '$lower ${uom.name()}';
        }

        return text;
      }),
    ),
    fProduct,
    fArea,
    fOperator,
    fPacker,
    const Field('thickness', NumberType(), path: ['thickness'])
        .copyWith(width: 0.5),
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "production order";

  @override
  IconData icon() => Icons.precision_manufacturing_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}'),
      // _${DateTime.now().toString()}__'),
      ctx: ctx,
      schema: schema,
      list: const ProductionOrderScreen(),
      view: action == "edit"
          ? ProductionOrderEdit(
              key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
              entity: entity,
            )
          : ProductionOrderView(
              key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
              entity: entity,
              tabIndex: 0,
            ),
    );
  }
}

class ProductionOrderScreen extends StatefulWidget {
  const ProductionOrderScreen({super.key});

  @override
  State<ProductionOrderScreen> createState() => _ProductionOrderScreenState();
}

class _ProductionOrderScreenState extends State<ProductionOrderScreen> {
  late CleanCalendarController calendarController;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    calendarController = CleanCalendarController(
      rangeMode: false,
      minDate: DateTime(2023, 1, 1),
      // minDate: DateTime.now().subtract(const Duration(days: 365)),
      maxDate: DateTime.now().add(const Duration(days: 1)),
      // onRangeSelected: setRange,
      onDayTapped: (date) {
        // print("onDayTapped $date");
        setState(() {
          selectedDate = date;
          context.read<MemoryBloc>().add(
                MemoryFetch(
                  'memories',
                  ProductionOrder.ctx,
                  schema: ProductionOrder.schema,
                  filter: {'date': date.toYMD()},
                  reset: true,
                ),
              );
        });
      },
      onPreviousMinDateTapped: (date) {},
      onAfterMaxDateTapped: (date) {},
      weekdayStart: DateTime.monday,
      initialDateSelected: selectedDate,
      initialFocusDate: selectedDate,
    );
  }

  Widget calendar(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: ScrollableCleanCalendar(
            locale: 'ru',
            calendarController: calendarController,
            layout: Layout.BEAUTY,
            calendarCrossAxisSpacing: 0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // print("_ProductionOrderScreen.build $selectedDate");
    final theme = Theme.of(context);
    return ScaffoldList(
      entityType: ProductionOrder.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.productionOrderListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_fab',
        backgroundColor: theme.primaryColorDark,
        onPressed: () {
          context.read<UiBloc>().add(ChangeView(ProductionOrder.ctx,
              action: 'edit', entity: MemoryItem.create()));
        },
        tooltip: AppLocalizations.of(context).translate("new production order"),
        child: Icon(
          Icons.add,
          color: theme.primaryColorLight,
        ),
      ),
      body: Row(
        children: [
          SizedBox(width: 300, child: calendar(context)),
          Flexible(
              flex: 2, child: ProductionOrdersListBuilder(date: selectedDate)),
        ],
      ),
    );
  }
}

class ProductionOrdersListBuilder extends StatelessWidget {
  const ProductionOrdersListBuilder({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    // print("ProductionOrdersListBuilder.build $date");
    return MemoryList(
      key: ValueKey('__po_${date.toYMD()}'),
      mode: Mode.mobile,
      ctx: ProductionOrder.ctx,
      filter: {'date': date.toYMD()},
      schema: ProductionOrder.schema,
      groupBy: (element) {
        final id = element.json[cDate] ?? '';
        return MemoryItem(id: id, json: {cId: id, cName: id});
      },
      title: (MemoryItem item) =>
          Text('${name(item.json[cArea])}\n${name(item.json[cProduct])}'),
      subtitle: (MemoryItem item) {
        final json = item.json;
        var text = 'план: ${json['planned']} шт'
            '\nвыработка: ${json['produced~']}'
            '\nоператор: ${json[cOperator].json?[cName] ?? ''}'
            '\nупаковщик: ${json[cPacker].json?[cName] ?? ''}';

        if (json['thickness'] != null) {
          text = '$text\nтолщина: ${json['thickness']}';
        }
        return Text(text);
      },
      onTap: (context, item) => context
          .read<UiBloc>()
          .add(ChangeView(ProductionOrder.ctx, entity: item)),
    );
  }
}

String name(dynamic item) {
  if (item is MemoryItem) {
    return item.name();
  } else if (item is String) {
    return item;
  } else {
    return '';
  }
}
