import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/screens/wh/dispatch/screen.dart';
import 'package:nae/screens/wh/return/screen.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_date_field.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class GoodsReturn extends EntityHolder {
  final Function()? afterSave;
  final MemoryItem? rec;

  const GoodsReturn({
    super.key,
    required super.entity,
    this.rec,
    this.afterSave,
  });

  @override
  State<StatefulWidget> createState() => _GoodsReturnState();
}

class _GoodsReturnState extends State<GoodsReturn> {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_goodsReturnEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  late MemoryItem details;
  String status = "register";
  String registered = '';

  List<MemoryItem> items = [];
  MemoryItem? selectedDocument;
  MemoryItem? selectedLine;
  MemoryItem? goods;

  bool showGoods = false;
  bool showQtyUom = false;
  bool showBatch = false;

  @override
  void initState() {
    super.initState();

    details = MemoryItem(id: '', json: {
      cCounterparty: widget.entity[cCounterparty],
      // cDate: Utils.getDate(),
    });

    loadDocuments(null);
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // print("build ${details.json}");
    final widgets = <Widget>[
      AppForm(
        formKey: _formKey,
        entity: details,
        focusNode: _focusNode,
        onChanged: () {
          final state = _formKey.currentState;
          if (state == null) {
            return;
          }
          state.save();
          var value = state.value;
          debugPrint("onChanged: $value");
        },
        child: ScrollableListView(
          children: <Widget>[
            FormCard(
              isLast: true,
              children: <Widget>[
                DecoratedFormPickerField(
                  ctx: WHReturn.ctx,
                  name: cCounterparty,
                  label: localization.translate(cCounterparty),
                  creatable: false,
                  editable: false,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: "выберите контрагент"),
                  ]),
                  onSave: (context) {},
                ),
                const SizedBox(height: 10),
                ...dispatchDate(),
                ...selectedGoods(),
                const SizedBox(height: 10),
                ...qtyUom(context),
                const SizedBox(height: 10),
                ...goodsList(),
              ],
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: 'product_register',
              backgroundColor: theme.primaryColorDark,
              onPressed: status == 'register'
                  ? () => registerPreparation(context)
                  : null,
              tooltip: localization.translate('register'.toString()),
              child: registered == 'register'
                  ? const Icon(Icons.done)
                  : widget.rec == null
                      ? Icon(
                          Icons.add,
                          color: theme.primaryColorLight,
                        )
                      : Icon(
                          Icons.edit,
                          color: theme.primaryColorLight,
                        ),
            ),
          ),
        ],
      ),
      body: ScrollableListView(
        children: widgets,
      ),
    );
  }

  Future<dynamic> registerPreparation(BuildContext context) async {
    resetDone();
    // {id: new, document: ref, line: ID, qty: {num: , uom: {}}}
    final state = _formKey.currentState;
    if (state == null || selectedLine == null) {
      // TODO raise error instead
      return;
    }
    if (state.saveAndValidate()) {
      var data = state.value;

      // print("form $data");

      final ref = selectedLine!;

      // print("ref $ref");

      final num = data['qty_0'];
      final uom = data['uom_0'];

      final record = {
        'document': widget.entity.id,
        'line': ref.id,
        'qty': {'number': num, 'uom': Uom.fromJson(uom.json).toJson()}
      };

      // print("record $record");

      // отправляем на сервер данные

      final newDoc = await Api.feathers().create(
          serviceName: 'memories',
          data: record,
          params: {'oid': Api.instance.oid, 'ctx': WHReturn.ctx});

      if (mounted) {
        // final entity = MemoryItem.from(newDoc);
        // await entity.enrich(WHReturn.schema);

        // context.read<UiBloc>().add(ChangeView(WHReturn.ctx,
        //     action: 'view', entity: MemoryItem.from(newDoc)));

        // print("to save $newDoc");

        setState(() {
          // state.patchValue({cGoods: null, cBatch: null, 'qty_0': null, 'uom_0': null});

          details.json[cGoods] = null;
          details.json[cBatch] = null;
          details.json['qty_0'] = null;
          details.json['uom_0'] = null;

          showQtyUom = false;

          // selectedDocument = null;
          selectedLine = null;
        });

        // loadDocuments(null);
        loadRows();
      }
    }
  }

  List<Widget> dispatchDate() {
    return <Widget>[
      DateField(
        name: cDate,
        label: "отгрузка от",
        autofocus: false,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
        onSave: (ctx) {},
        onChange: (date) {
          loadDocuments(date);
        },
        keyboardType: TextInputType.datetime,
      ),
    ];
  }

  List<Widget> selectedGoods() {
    final localization = AppLocalizations.of(context);
    if (selectedLine != null) {
      return <Widget>[
        const SizedBox(height: 10),
        DecoratedFormPickerField(
          ctx: const ['warehouse', 'dispatch'],
          name: cGoods,
          label: localization.translate(cGoods),
          creatable: false,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: "выберите товар"),
          ]),
          onSave: (context) {},
        ),
        const SizedBox(height: 10),
        DecoratedFormPickerField(
          ctx: const ['warehouse', 'dispatch'],
          name: cBatch,
          label: localization.translate(cBatch),
          creatable: false,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: "выберите партию"),
          ]),
          onSave: (context) {},
        ),
      ];
    } else {
      return <Widget>[];
    }
  }

  List<Widget> goodsList() {
    if (items.isNotEmpty) {
      return <Widget>[
        SizedBox(
          height: 350,
          child: MemoryItemListBuilder(
            items: items,
            title: (MemoryItem item) {
              // print('item.json ${item.json}');
              // print('cBatchDetails ${item[cBatchDetails]}');
              if (selectedDocument == null) {
                return Text(item[cCounterparty]?.name() ?? '');
              } else {
                return Text(item[cGoods]?.name() ?? '');
              }
            },
            subtitle: (MemoryItem item) {
              if (selectedDocument == null) {
                return Text('отгрузка от ${item.json[cDate]}');
              } else {
                final details = item.json[cBatchDetails];
                if (details == null) {
                  return const Text('');
                } else {
                  return Text(
                      '${details['customer'] ?? ''}, ${details['label'] ?? ''}, ${item.json['batch']['date'] ?? ''}');
                }
              }
            },
            onTap: (item) => changeState(item),
          ),
        )
      ];
    }

    return <Widget>[];
  }

  List<Widget> qtyUom(BuildContext context) {
    final localization = AppLocalizations.of(context);
    var children = <Widget>[];

    final uom = Expanded(
      flex: 1,
      child: DecoratedFormPickerField(
        creatable: false,
        ctx: const [cUom],
        name: 'uom_0',
        label: localization.translate(cUom),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(errorText: "выберите значение"),
        ]),
        onSave: (context) {},
        editable: false,
      ),
    );

    final qty = Expanded(
      flex: 1,
      child: DecoratedFormField(
        name: 'qty_0',
        label: localization.translate(cQty),
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.numeric(),
        ]),
        onSave: (context) {},
        keyboardType: TextInputType.number,
      ),
    );

    children.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [uom, const SizedBox(width: 5), qty],
      ),
    );
    children.add(const SizedBox(height: 10));

    if (showQtyUom) {
      return children;
    } else {
      return [SizedBox(height: 0, child: Column(children: children))];
    }
  }

  void resetDone() {
    setState(() => registered = '');
  }

  void done(String type) {
    if (type == 'register') {
      if (widget.afterSave != null) {
        widget.afterSave?.call();
        return;
      }
    }
    setState(() {
      registered = type;

      // workaround as unknown where item resetting to initial
      // showCategory = false;
      // showGoods = false;
      // showBatch = false;
      // showQtyUom = false;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        registered = '';

        // workaround as unknown where item resetting to initial
        // final storageData = details.json[cStorage];
        // if (storageData is MemoryItem) {
        //   final storage = MemoryItem.clone(details.json[cStorage]);
        //   storage.json['_category'] = cStorage;
        //   changeState(storage);
        // }
      });
    });
  }

  void changeState(MemoryItem item) {
    // print('changeState ${item.json}');
    if (selectedDocument == null) {
      selectedDocument = item;

      setState(() {
        details.json[cDate] = DT.parse(item.json[cDate]);
        final state = _formKey.currentState;
        if (state != null) {
          state.patchValue({
            cDate: DT.parse(item.json[cDate]),
          });
          state.save();
        }
      });

      loadRows();
    } else {
      final goods = item[cGoods];

      setState(() {
        selectedLine = item;

        showGoods = true;
        details.json[cGoods] = goods;
        _formKey.currentState?.patchValue({cGoods: goods});

        final state = _formKey.currentState;
        if (state == null) {
          return;
        }

        final batch = item.json[cBatch];
        print('batch $batch');
        if (batch != null) {
          final copy = Map.from(batch);
          copy[cName] = DT.pretty(copy[cDate] ?? '');
          final item = MemoryItem.from(batch);
          state.patchValue({cBatch: item});
          details.json[cBatch] = item;
        }

        Map? qty = item.json[cQty];
        if (qty != null) {
          // print('qty $qty');
          final uom = qty["uom"];
          if (uom != null) {
            state.patchValue({
              "qty_0": qty["number"].toString(),
              "uom_0": MemoryItem.from(uom)
            });
            showQtyUom = true;
          }
        }
      });
      items = [];
    }
  }

  void loadDocuments(DateTime? date) {
    getDocuments(date).then((value) {
      setState(() {
        items = value;
      });
    });
  }

  Future<List<MemoryItem>> getDocuments(DateTime? date) async {
    final filter = {};

    final counterparty = widget.entity[cCounterparty];
    if (counterparty == null) {
      // print("return empty list");
      return [];
    }
    filter[cCounterparty] = counterparty.id;

    if (date != null) {
      filter[cDate] = date.toYMD();
    }

    final response = await Api.feathers().find(serviceName: "memories", query: {
      "oid": Api.instance.oid,
      "ctx": WHDispatch.ctx,
      "filter": filter,
    });
    // print("response $response");

    List<MemoryItem> list = [];

    final data = response['data'] as List;
    for (var json in data) {
      // print('json $json');
      final item = MemoryItem.from(json);
      // print('item $item');
      // place for enrichment

      list.add(item);
    }
    // print('list ${list.length}');
    return list;
  }

  void loadRows() {
    if (selectedDocument == null) {
      setState(() {
        items = [];
      });
    } else {
      getRows(selectedDocument!).then((value) {
        setState(() {
          items = value;
        });
      });
    }
  }
}

Future<List<MemoryItem>> getRows(MemoryItem doc) async {
//  print("getRows");
  final response = await Api.feathers().find(serviceName: "memories", query: {
    "oid": Api.instance.oid,
    "ctx": ['warehouse', 'dispatch'],
    "filter": {"document": doc.id}
  });
  // print("response $response");

  List<MemoryItem> goods = [];

  final data = response['data'] as List;
  for (var json in data) {
    // print('json $json');
    final item = MemoryItem.from(json);
    // print('item $item');

    // place for enrichment
    final it = await item.enrich([fBatchDocument]);

    goods.add(it);
  }
  // print('list ${list.length}');
  return goods;
}

class MemoryItemListBuilder extends StatelessWidget {
  const MemoryItemListBuilder({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    required this.items,
  });

  final Widget Function(MemoryItem) title;
  final Widget Function(MemoryItem) subtitle;

  final Function(MemoryItem)? onTap;

  final List<MemoryItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      // controller: _scrollController,
      itemBuilder: (context, index) {
        final item = items[index];
        return card(context, item);
      },
    );
  }

  Widget card(BuildContext context, MemoryItem item) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        // leading: const Icon(Icons.account_circle),
        title: title(item),
        subtitle: subtitle(item),
        trailing:
            onTap == null ? null : const Icon(Icons.arrow_downward_outlined),
        onTap: () => onTap?.call(item),
      ),
    );
  }
}
