import 'package:flutter/material.dart';
import 'package:nae_hr/widgets/list_filter.dart';

import 'package:nae_hr/widgets/scaffold_list.dart';
import 'package:nae_hr/widgets/memory_list.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

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
      body: const ProductListBuilder(),
    );
  }
}

class ProductListBuilder extends StatelessWidget {
  const ProductListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return const MemoryList(ctx: ProductScreen.route);
  }
}