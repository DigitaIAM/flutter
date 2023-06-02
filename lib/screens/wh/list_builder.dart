import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/utils/number.dart';
import 'package:nae/widgets/memory_list.dart';

class Pair {
  final String label;
  final MemoryItem value;

  Pair(this.label, this.value);
}

class ListBuilder extends StatelessWidget {
  const ListBuilder({super.key, required this.filters, required this.down, required this.ctx, required this.schema});

  final List<Pair> filters;
  final Future<dynamic> Function(BuildContext context, List<Pair>) down;
  final List<String> ctx;
  final List<Field> schema;

  // final UiState? state;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => MemoryBloc(),
      // ..add(MemoryFetch('memories', ctx, schema: schema, filter: filter)),
      child: buildList(localization),
    );
  }

  Widget buildList(AppLocalizations localization) {
    final Map<String, dynamic> filter = {};
    for (final pair in filters) {
      filter[pair.label] = pair.value.uuid ?? '';
    }

    final cache = {};

    return MemoryList(
      mode: Mode.mobile,
      ctx: ctx,
      schema: schema,
      filter: filter,
      groupBy: (element) {
        final id = element.json['_category'] ?? '';
        final o = cache[id];
        if (o != null) {
          return o;
        }
        final name = localization.translate(id);
        final n = MemoryItem(id: id, json: {"_uuid": id, "name": localization.translate(name)});
        cache[id] = n;
        return n;
      },
      groupComparator: (a, b) {
        convert(id) {
          if (id == 'storage') {
            return 1;
          } else if (id == 'category') {
            return 2;
          } else if (id == 'goods') {
            return 3;
          } else if (id == 'batch') {
            return 4;
          } else {
            return 5;
          }
        }

        return convert(a.id).compareTo(convert(b.id));
      },
      sortByName: true,
      title: (MemoryItem item) {
        final category = item.json['_category'];
        if (category == 'stock') {
          return Text(fName.resolve(item.json['goods'] ?? '') ?? '');
        } else if (category == 'batch') {
          return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${item.json['batch']?['date'] ?? ''}'),
            Text('${fStorage.resolve(item.json)?.name() ?? ''}'),
          ]);
        } else {
          return Text(fName.resolve(item.json) ?? '');
        }
      },
      subtitle: (MemoryItem item) {
        final category = item.json['_category'];
        if (category == 'stock') {
          // print("item: ${item.json}");
          return Text('${fQty.resolve(item.json) ?? ''} ${fUomAtGoods.resolve(item.json)?.name() ?? ''}, '
              '${Number.format(item.json['cost']?['number'] ?? '')} сум');
          // } else if (category == 'batch') {
          //   // print("item: ${item.json}");
          //   return Text('${item.json['_balance']?['qty'] ?? ''} ${fUomAtGoods.resolve(item.json)?.name() ?? ''}, '
          //       '${item.json['_balance']?['cost'] ?? ''} сум');
        } else {
          print("item: ${item.json}");
          final cost = item.json['_cost'];
          if (cost != null) {
            return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(''),
              Text('${Number.format(cost)} сум'),
            ]);
          } else {
            final balance = item.json['_balance'];
            print("balance: ${balance}");
            if (balance != null) {
              return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${balance['qty'] ?? ''} ${fUom.resolve(item.json)?.name() ?? ''}'),
                Text('${Number.format(balance['cost'] ?? '')} сум'),
              ]);
            }
          }
          return const Text('');
        }
      },
      onTap: (context, item) {
        var category = item.json['_category'];
        if (category == 'stock') {
          final List<Pair> nf = List.from(filters);
          // print("item: ${item.json}");
          nf.add(Pair(category, MemoryItem.from(item.json['goods'])));
          down(context, nf);
        } else if (category == 'batch') {
          return context.read<UiBloc>().add(ChangeView(ctx, entity: item));
        } else {
          final List<Pair> nf = List.from(filters);
          nf.add(Pair(category, item));

          down(context, nf);
        }
      },
    );
  }
}
