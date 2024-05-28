import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/api.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/screens/wh/dispatch/screen.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_date_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class GoodsReturn extends EntityHolder {
  final MemoryItem doc;

  const GoodsReturn({super.key, required this.doc, required super.entity});

  @override
  State<StatefulWidget> createState() => _GoodsReturnState();
}

class _GoodsReturnState extends State<GoodsReturn> {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_productionOrderEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  late MemoryItem details;

  List<MemoryItem> items = [];
  MemoryItem? selectedDocument;

  bool showGoods = false;

  @override
  void initState() {
    super.initState();

    details = MemoryItem(id: '', json: {
      cDate: Utils.getDate(),
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("build ${details.json}");
    return AppForm(
      formKey: _formKey,
      entity: details,
      focusNode: _focusNode,
      child: ScrollableListView(
        children: <Widget>[
          FormCard(
            isLast: true,
            children: <Widget>[
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
              const SizedBox(height: 10),
              DecoratedFormPickerField(
                ctx: const ['warehouse', 'dispatch'],
                name: cDocument,
                label: "контрагент",
                autofocus: false,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (ctx) {},
              ),
              const SizedBox(height: 10),
              ...goodsList(),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> goodsList() {
    dynamic date;

    final state = _formKey.currentState;
    if (state == null) {
      date = details.json[cDate];
      if (date == null) {
        return <Widget>[];
      }
    }

    if (items.isNotEmpty) {
      return <Widget>[
        SizedBox(
            height: 350,
            child: MemoryItemListBuilder(
              items: items,
              title: (MemoryItem item) {
                if (selectedDocument == null) {
                  return Text(item.json[cCounterparty]?[cName] ?? '');
                } else {
                  return Text(item.json[cGoods]?[cName] ?? '');
                }
              },
              subtitle: (MemoryItem item) {
                // return Text(qtyToText(item.json['_balance']?[cQty]));
                return const Text('');
              },
              onTap: (item) => changeState(item),
            ))
      ];
    }

    return <Widget>[];
  }

  void changeState(MemoryItem item) async {
    if (selectedDocument == null) {
      selectedDocument = item;

      item.json[cName] = item.json[cCounterparty][cName];

      setState(() {
        details.json[cDocument] = item;
        _formKey.currentState?.patchValue({cDocument: item});
      });
      final rows = await getRows(item);
      setState(() => items = rows);
    }
  }

  void loadDocuments(DateTime? date) {
    print("loadDocuments");
    if (date == null) {
      setState(() => items = []);
      print("date == null");
      return;
    }

    getDocuments(date).then((value) {
      setState(() {
        selectedDocument = null;
        items = value;
      });
    });
  }
}

Future<List<MemoryItem>> getDocuments(DateTime date) async {
  final response = await Api.feathers().find(serviceName: "memories", query: {
    "oid": Api.instance.oid,
    "ctx": WHDispatch.ctx,
    "filter": {"date": date.toYMD()}
  });
  print("response $response");

  List<MemoryItem> list = [];

  final data = response['data'] as List;
  for (var json in data) {
    print('json $json');
    final item = MemoryItem.from(json);
    print('item $item');
    // place for enrichment

    list.add(item);
  }
  // print('list ${list.length}');
  return list;
}

Future<List<MemoryItem>> getRows(MemoryItem doc) async {
  print("getRows");
  final response = await Api.feathers().find(serviceName: "memories", query: {
    "oid": Api.instance.oid,
    "ctx": ['warehouse', 'dispatch'],
    "filter": {"document": doc.id}
  });
  print("response $response");

  List<MemoryItem> goods = [];

  final data = response['data'] as List;
  for (var json in data) {
    print('json $json');
    final item = MemoryItem.from(json);
    print('item $item');

    // place for enrichment

    goods.add(item);
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
