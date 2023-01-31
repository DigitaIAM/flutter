import 'package:flutter/material.dart';

import 'package:nae_hr/widgets/scaffold_list.dart';
import 'package:nae_hr/widgets/memory_list.dart';

class UomsScreen extends StatelessWidget {
  const UomsScreen({super.key});

  static const List<String> route = ['uom'];
  static const icon = Icons.square_foot_rounded;

  @override
  Widget build(BuildContext context) {
    return const ScaffoldList(
      body: UomsListBuilder(),
    );
  }
}

class UomsListBuilder extends StatelessWidget {
  const UomsListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return const MemoryList(ctx: UomsScreen.route);
  }
}