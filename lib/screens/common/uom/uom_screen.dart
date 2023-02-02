import 'package:flutter/material.dart';
import 'package:nae_hr/widgets/list_filter.dart';

import 'package:nae_hr/widgets/scaffold_list.dart';
import 'package:nae_hr/widgets/memory_list.dart';

class UomScreen extends StatelessWidget {
  const UomScreen({super.key});

  static const List<String> route = ['uom'];
  static const icon = Icons.square_foot_rounded;

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: route,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.productListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      body: const UomListBuilder(),
    );
  }
}

class UomListBuilder extends StatelessWidget {
  const UomListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return const MemoryList(ctx: UomScreen.route);
  }
}