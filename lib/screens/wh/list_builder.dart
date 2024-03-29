import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/utils/number.dart';
import 'package:nae/widgets/memory_list.dart';

const String currency = 'сум';

class Pair {
  final String label;
  final MemoryItem value;

  Pair(this.label, this.value);
}

class ListBuilder extends StatelessWidget {
  const ListBuilder({
    super.key,
    required this.filters,
    required this.down,
    required this.ctx,
    required this.schema,
  });

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
        final n = MemoryItem(
            id: id, json: {cUuid: id, cName: localization.translate(name)});
        cache[id] = n;
        return n;
      },
      groupComparator: (a, b) {
        convert(id) {
          if (id == cStorage) {
            return 1;
          } else if (id == cCategory) {
            return 2;
          } else if (id == cGoods) {
            return 3;
          } else if (id == cBatch) {
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
          return Text(fName.resolve(item.json[cGoods] ?? '') ?? '');
        } else if (category == cBatch) {
          final strDate = item.json[cBatch]?[cDate] ?? '';
          final date = DT.pretty(strDate);

          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date),
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
          // TODO what should we see here?
          return Text(
              '${fQty.resolve(item.json) ?? ''} ${fUomAtGoods.resolve(item.json)?.name() ?? ''}, '
              '${Number.format(item.json[cCost]?[cNumber] ?? '')} сум');
          // } else if (category == cBatch) {
          //   // print("item: ${item.json}");
          //   return Text('${item.json['_balance']?[cQty] ?? ''} ${fUomAtGoods.resolve(item.json)?.name() ?? ''}, '
          //       '${item.json['_balance']?[cCost] ?? ''} сум');
        } else {
          print("_item: ${item.json}");
          final cost = item.json['_cost'];
          if (cost != null) {
            return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(''),
                  Text('${Number.format(cost)} $currency'),
                ]);
          } else {
            final balance = item.json['_balance'];
            // print("balance: ${balance}");
            if (balance != null) {
              var text = '';
              List? list = balance[cQty];
              if (list != null && list.isNotEmpty) {
                for (Map qty in list) {
                  if (text != '') {
                    text = '$text, ';
                  }
                  text = '$text ${qty['number'] ?? ''}';
                  var uom = qty['uom'];
                  if (uom is String) {
                    text = '$text $uom';
                  } else {
                    while (uom is Map) {
                      if (uom['name'] != null) {
                        text = '$text ${uom['name']}';
                        break;
                      } else {
                        text =
                            '$text ${uom['in']?['name'] ?? ''} по ${uom['number'] ?? ''}';
                        uom = uom['uom'] ?? uom;
                      }
                    }
                  }
                }
              }

              return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text('${balance[cQty] ?? ''} ${fUom.resolve(item.json)?.name() ?? ''}'),
                    Text(text),
                    Text('${Number.format(balance[cCost] ?? '')} $currency'),
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
          nf.add(Pair(category, MemoryItem.from(item.json[cGoods])));
          down(context, nf);
        } else if (category == cBatch) {
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
