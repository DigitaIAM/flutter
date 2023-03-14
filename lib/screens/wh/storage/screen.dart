import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/entity.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_filter.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_list.dart';

import 'edit.dart';

class WHStorage extends Entity {
  static const List<String> ctx = ['warehouse', 'storage'];

  static const List<Field> schema = [
    Field('location', ReferenceType(['warehouse', 'storage'])),
    fName,
    Field('code', StringType()),
  ];

  @override
  List<String> route() => ctx;

  @override
  String name() => "storage";

  @override
  IconData icon() => Icons.shelves; // Icons.place_outlined;

  @override
  Widget screen(String action, MemoryItem entity) {
    return EntityScreens(
      key: ValueKey('__${name()}_${DateTime.now().toString()}__'),
      ctx: ctx,
      list: const WHStorageScreen(),
      // action == "edit" ? WHStorageEdit(entity: entity) : WHStorageView(entity: entity),
      view: WHStorageEdit(
        key: ValueKey('__${entity.id}_${entity.updatedAt}__'),
        entity: entity,
      ),
    );
  }
}

class WHStorageScreen extends StatelessWidget {
  const WHStorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldList(
      entityType: WHStorage.ctx,
      appBarTitle: ListFilter(
        // key: ValueKey('__filter_${state.ListState.filterClearedAt}__'),
        filter: null, //state.productListState.filter,
        onFilterChanged: (value) {
          // store.dispatch(FilterProducts(value));
        },
      ),
      body: const WHStorageListBuilder(),
    );
  }
}

class WHStorageListBuilder extends StatelessWidget {
  const WHStorageListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MemoryList(
      ctx: WHStorage.ctx,
      schema: WHStorage.schema,
      title: (MemoryItem item) => item.name(),
      subtitle: (MemoryItem item) => '',
      onTap: (MemoryItem item) => context.read<UiBloc>().add(ChangeView(WHStorage.ctx, entity: item)),
    );
  }
}
