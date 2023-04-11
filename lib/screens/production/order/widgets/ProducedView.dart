import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/memory_list.dart';

class POProducedView extends StatelessWidget {
  final MemoryItem order;

  const POProducedView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final ctx = ['production', 'produce'];
    final schema = [
      const Field('qty', NumberType()),
      Field('code', CalculatedType((MemoryItem bag) async {
        return bag.id.split('T').last;
      }))
    ];
    return BlocProvider(
      create: (context) => MemoryBloc()..add(MemoryFetch('memories', ctx, schema: schema, filter: {'order': order.id})),
      child: MemoryList(
        ctx: ctx,
        schema: schema,
        title: (MemoryItem item) => Text(item.json['qty']),
        subtitle: (MemoryItem item) => Text(item.id.split('T').last),
        onTap: (MemoryItem item) => {},
      ),
    );
  }
}
