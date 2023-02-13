import 'package:flutter/material.dart';
import 'package:nae/api.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_list.dart';

import 'edit.dart';
import 'view.dart';

class ProductionOrder extends Entity {
  static const List<String> ctx = ['production', 'order'];

  static final List<Field> schema = [
    const Field('date', DateType()),
    const Field('area', ReferenceType(['production', 'area'])),
    const Field('product', ReferenceType(['product'])),
    const Field('planned', NumberType()),
    Field('produced', CalculatedType((MemoryItem order) async {
      // /production/produce[order == order.id]/sum(qty)

      int result = 0;

      int skip = 0;
      int total = -1;
      while (total == -1 || skip < total) {
        total = 0;
        final response = await Api.feathers().find(serviceName: 'memories', query: {
          'oid': Api.instance.oid,
          'ctx': ['production', 'produce'],
          'filter': {'order': order.id},
          '\$skip': skip,
        });
        // print(response);
        total = response['total'];
        final data = response['data'];
        if (data is List) {
          skip += data.length;
          for (var item in data) {
            final num = item['qty'];
            if (num is int) {
              result += num;
            } else if (num is String) {
              result += int.parse(num);
            } else {
              // print("num type unknown");
              // print(num);
            }
          }
        } else {
          break;
        }
      }

      return result.toString();
    })),
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
      key: ValueKey('__${name()}_${DateTime.now().toString()}__'),
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

class ProductionOrderScreen extends StatelessWidget {
  const ProductionOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: ProductionOrder.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.productionOrderListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      body: const ProductionOrdersListBuilder(),
    );
  }
}

class ProductionOrdersListBuilder extends StatelessWidget {
  const ProductionOrdersListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      ctx: ProductionOrder.ctx,
      schema: ProductionOrder.schema,
    );
  }
}
