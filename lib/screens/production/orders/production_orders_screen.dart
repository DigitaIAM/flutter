import 'package:flutter/material.dart';

import 'package:nae_hr/widgets/scaffold_list.dart';
import 'package:nae_hr/widgets/memory_list.dart';

class ProductionOrdersScreen extends StatelessWidget {
  const ProductionOrdersScreen({super.key});

  static const List<String> route = ['production', 'order'];
  static const icon = Icons.precision_manufacturing_outlined;

  @override
  Widget build(BuildContext context) {
    return const ScaffoldList(
      body: ProductionOrdersListBuilder(),
    );
  }
}

class ProductionOrdersListBuilder extends StatelessWidget {
  const ProductionOrdersListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return const MemoryList(ctx: ProductionOrdersScreen.route);
  }
}