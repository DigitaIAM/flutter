import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/production/pallets/screen.dart';
import 'package:nae/screens/wh/goods_dispatch.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/swipe_action.dart';

class PalletsGoods extends StatefulWidget {
  final MemoryItem doc;
  final Mode mode;

  const PalletsGoods({super.key, required this.doc, this.mode = Mode.auto});

  @override
  State<StatefulWidget> createState() => _PalletsGoodsState();
}

class _PalletsGoodsState extends State<PalletsGoods> {
  @override
  Widget build(BuildContext context) {
    final filter = {
      cDocument: widget.doc.id,
    };
    final schema = <Field>[
      fGoods.copyWith(width: 3.0),
      fCategoryAtGoods,
      fQtyNew.copyWith(width: 1.0),
    ];

    return BlocProvider(
      create: (context) {
        final bloc = MemoryBloc(schema: schema, reverse: true);
        bloc.add(MemoryFetch(
          'memories',
          PalletPacking.ctxOfDispatch,
          filter: filter,
          reverse: true,
          loadAll: true,
        ));

        return bloc;
      },
      child: MemoryList(
        mode: widget.mode,
        ctx: PalletPacking.ctxOfDispatch,
        filter: filter,
        schema: schema,
        title: (MemoryItem item) {
          final text = fGoods.resolve(item.json)?.name() ?? '';

          TextStyle? style;

          if (item.json[cStatus] == 'deleted') {
            style = const TextStyle(
              decoration: TextDecoration.lineThrough,
            );
          }
          return Text(text, style: style);
        },
        subtitle: (MemoryItem item) {
          String dateBatch = item.json['batch']?['date'] ?? '';

          final qty = item.json['qty'].toString();

          var text = '$qty ';
          if (dateBatch.isNotEmpty) {
            text += ', $dateBatch';
          }

          TextStyle? style;

          if (item.json[cStatus] == 'deleted') {
            style = const TextStyle(
              decoration: TextDecoration.lineThrough,
            );
          }
          return Text(text, style: style);
        },
        onDoubleTap: (context, item) {
          editItem(context, PalletPacking.ctxOfDispatch, widget.doc, item);
        },
        //onTap: (context, MemoryItem item) => popUpPatch(context, item),
        // context.read<UiBloc>().add(ChangeView(WHReceive.ctx, entity: item)),
        actions: [
          ItemAction(
            label: 'delete',
            icon: Icons.delete_outline,
            onPressed: (context, item) => deleteItem(context, item),
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
          ),
          ItemAction(
            label: 'edit',
            icon: Icons.edit,
            onPressed: (context, item) => editItem(
                context, PalletPacking.ctxOfDispatch, widget.doc, item),
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }

  void deleteItem(BuildContext context, MemoryItem item) async {
    final status = item.json[cStatus] == 'deleted' ? 'restored' : 'deleted';
    final Map<String, dynamic> data = {cStatus: status};
    // TODO fix schema
    context.read<MemoryBloc>().add(MemoryPatch(
        'memories', PalletPacking.ctxOfDispatch, const [], item.id, data));
  }

  void editItem(BuildContext context, List<String> ctx, MemoryItem doc,
      MemoryItem item) async {
    //print("docu ${doc.json}");
    // print("item ${item.json}");

    Map<String, dynamic> data = {};

    data[cId] = item.id;
    data[cUuid] = item.uuid;
    data[cStorage] = doc.json[cStorage];
    data[cGoods] = item.json[cGoods];
    data[cCategory] = data[cGoods].json[cCategory];
    data[cBatch] =
        item.json[cBatch] == null ? null : MemoryItem.from(item.json[cBatch]);
    (item.json['qty'] as Qty).toData(data);

    // print("data $data");

    final uiBloc = context.read<UiBloc>();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => BlocProvider(
        create: (ctx) => UiBloc(uiBloc.state),
        child: Dialog(
          child: SizedBox(
            width: 500,
            height: 500,
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                Expanded(
                  child: SizedBox(
                    width: 500,
                    height: 400,
                    child: Column(
                      children: [
                        Expanded(
                          child: GoodsDispatch(
                            ctx: PalletPacking.ctxOfDispatch,
                            doc: widget.doc,
                            rec: MemoryItem.from(data),
                            schema: PalletPacking.schema,
                            enablePrinting: false,
                            afterSave: () {
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
