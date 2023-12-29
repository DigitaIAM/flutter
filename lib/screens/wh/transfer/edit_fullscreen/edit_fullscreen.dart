import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/models/ui/state.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/screens/wh/custom_textfield.dart';
import 'package:nae/screens/wh/goods_dispatch.dart';
import 'package:nae/screens/wh/transfer/edit_fullscreen/document_creation.dart';
import 'package:nae/screens/wh/transfer/edit_fullscreen/goods.dart';
import 'package:nae/screens/wh/transfer/edit_fullscreen/overview.dart';
import 'package:nae/screens/wh/transfer/screen.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_date_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/autocomplete.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/popup_menu_button.dart';
import 'package:nae/widgets/scaffold_edit.dart';
import 'package:nae/widgets/scaffold_view.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class WHTransferEditFS extends EntityHolder {
  bool showStorages;

  WHTransferEditFS({super.key, required super.entity, this.showStorages = false}) : super(fullscreen: true);

  @override
  State<WHTransferEditFS> createState() => _WHTransferEditFSState();
}

class _WHTransferEditFSState extends State<WHTransferEditFS> with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_WHTransferEditFS');
  final FocusScopeNode _focusNode = FocusScopeNode();

  late TabController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TabController(
      vsync: this,
      length: widget.entity.isNew ? 1 : 3,
      initialIndex: widget.entity.isNew ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();

    super.dispose();
  }

  void _onSave(BuildContext context) {
    final state = _formKey.currentState;
    if (state != null && state.saveAndValidate()) {
      debugPrint('new data');
      debugPrint(_formKey.currentState?.value.toString());

      final Map<String, dynamic> data = Map.from(state.value);
      // workaround
      data[cId] = widget.entity.id;

      // workaround
      data[cDate] = DateFormat("yyyy-MM-dd").format(data[cDate]);

      context
          .read<MemoryBloc>()
          .add(MemorySave("memories", WHTransfer.ctx, WHTransfer.schema, MemoryItem(id: widget.entity.id, json: data)));
    } else {
      debugPrint(_formKey.currentState?.value.toString());
      debugPrint('validation failed');
    }

    // if (_formKey.currentState?.validate() ?? false) {
    //   context.read<MemoryBloc>().add(MemorySave("memories", UomScreen.route, widget.entity));
    // }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    if (widget.entity.isNew) {
      return ScaffoldView(
        appBarBottom: TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: [
            Tab(text: localization.translate("new document")),
          ],
        ),
        body: Builder(builder: (context) {
          return Column(children: <Widget>[
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: <Widget>[WHTransferDocumentCreation(doc: widget.entity)],
              ),
            ),
          ]);
        }),
      );
    } else {
      routerBack(BuildContext context) {
        context.read<UiBloc>().add(ChangeView(WHTransfer.ctx));
        // TODO context.read<UiBloc>().add(PreviousRoute());
      }

      return BlocBuilder<UiBloc, UiState>(builder: (context, uiState) {
        if (uiState.isDesktop) {
          return EditScaffold(
            entity: widget.entity,
            title: localization.translate("warehouse transfer"),
            onClose: routerBack,
            onCancel: routerBack,
            onSave: _onSave,
            body: AppForm(
              schema: WHTransfer.schema,
              formKey: _formKey,
              focusNode: _focusNode,
              entity: getEntity(),
              child: Column(children: [
                FormCard(children: <Widget>[
                  DateField(
                    name: cDate,
                    label: localization.translate(cDate),
                    autofocus: false,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    onSave: _onSave,
                    keyboardType: TextInputType.datetime,
                  ),
                  DecoratedFormPickerField(
                    ctx: const ['warehouse', 'storage'],
                    name: cFrom,
                    label: localization.translate(cFrom),
                    autofocus: true,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    onSave: _onSave,
                  ),
                  DecoratedFormPickerField(
                    ctx: const ['warehouse', 'storage'],
                    name: cInto,
                    label: localization.translate(cInto),
                    autofocus: true,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    onSave: _onSave,
                  ),
                ]),
                Expanded(
                  child: ScrollableListView(children: <Widget>[
                    Lines(
                      ctx: const ['warehouse', 'transfer'],
                      schema: const [], // TODO
                      document: widget.entity,
                      showStorages: widget.showStorages,
                    ),
                    // workaround to give some space for dropdown
                    Container(height: 300)
                  ]),
                )
              ]),
            ),
          );
        } else {
          return ScaffoldView(
            title: localization.translate("warehouse transfer"),
            appBarBottom: TabBar(
              controller: _controller,
              isScrollable: true,
              tabs: [
                Tab(text: localization.translate(cGoods)),
                Tab(text: localization.translate("overview")),
                Tab(text: localization.translate("registration")),
              ],
            ),
            body: Builder(builder: (context) {
              return Column(children: <Widget>[
                Expanded(
                  child: TabBarView(controller: _controller, children: <Widget>[
                    WHTransferGoods(doc: widget.entity),
                    WHTransferOverview(doc: widget.entity),
                    GoodsDispatch(
                      ctx: const ['warehouse', 'transfer'],
                      doc: widget.entity,
                      schema: WHTransfer.schema,
                      storage: const MemoryItem(id: 'warehouse/storage/2023-02-19T12:00:25.151Z', json: {
                        "location": null,
                        "name": "склад",
                        "code": "023010100000",
                        "_id": "warehouse/storage/2023-02-19T12:00:25.151Z",
                        "_uuid": "404037f2-3db7-4dae-9884-6a79fd9cd94e"
                      }),
                    )
                  ]),
                ),
              ]);
            }),
          );
        }
      });
    }
  }

  MemoryItem getEntity() {
    if (widget.entity.isNew && widget.entity.json[cDate] == null) {
      final json = Map.of(widget.entity.json);
      json[cDate] = Utils.today();
      return MemoryItem(id: widget.entity.id, json: json);
    } else {
      final json = Map.of(widget.entity.json);
      json[cDate] = DateTime.parse(json[cDate]); //DateFormat("yyyy-MM-dd").format(json[cDate]);
      return MemoryItem(id: widget.entity.id, json: json);
    }
  }
}

class Lines extends StatefulWidget {
  final List<String> ctx;
  final List<Field> schema;
  final MemoryItem document;
  bool showStorages;

  Lines({super.key, required this.document, required this.ctx, required this.schema, this.showStorages = false});

  @override
  State<Lines> createState() => _LinesState();
}

class _LinesState extends State<Lines> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context);

    if (widget.document.isNew) {
      return Container();
    }

    var schema = <Field>[
      // const Field(cBatch, StringType()),
      fGoods.copyWith(width: 3.0),
      fUomAtQty.copyWith(width: 0.5, editable: false),
      fQty.copyWith(width: 1.0),
      // fStorage,
    ];

    if (widget.showStorages) {
      schema.add(Field(localization.translate("storage_from"), const ReferenceType(['warehouse', 'storage']),
          path: ['storage_from']).copyWith(width: 1.0));
      schema.add(Field(localization.translate("storage_into"), const ReferenceType(['warehouse', 'storage']),
          path: ['storage_into']).copyWith(width: 1.0));
    }

    schema.add(const Field('', PopupMenuButtonType()).copyWith(width: 0.2));

    final columns = schema.asMap();

    final tableHeaderColumns = <TableHeader>[];
    final Map<int, TableColumnWidth> columnWidths = {};

    bool isFirst = true;
    int index = 0;
    for (final field in schema) {
      tableHeaderColumns.add(TableHeader(
        label: localization.translate(field.name),
        isFirst: isFirst,
        isNumeric: field.type is NumberType,
      ));

      columnWidths[index] = FlexColumnWidth(field.width);
      index++;
    }
    // columnWidths[index] = const FixedColumnWidth(40);

    return BlocProvider(
      create: (context) {
        final bloc = MemoryBloc(schema: schema, reverse: true);
        bloc.add(MemoryFetch(
          'memories',
          widget.ctx,
          filter: {
            cDocument: widget.document.id,
          },
          reverse: true,
          loadAll: true,
        ));

        return bloc;
      },
      child: FormCard(
        child: BlocBuilder<MemoryBloc, RequestState>(
          builder: (context, state) {
            switch (state.status) {
              case RequestStatus.failure:
                return Center(child: Text(localization.translate('failed to fetch data')));
              case RequestStatus.success:
                final headingRowColor = theme.dataTableTheme.headingRowColor;
                final List<MemoryItem> items = List.of(state.items);

                // workaround: set uom from product default one
                for (MemoryItem item in items) {
                  final goods = item.json[cGoods];
                  if (goods != null && goods is MemoryItem) {
                    final uom = goods.json[cUom];
                    if (uom != null) {
                      final qty = item.json[cQty];
                      if (qty == null) {
                        item.json[cQty] = {uom: uom};
                      } else if (qty is Map) {
                        final uomAtLine = qty[cUom];
                        if (uomAtLine == null || (uomAtLine is MemoryItem && uomAtLine.isEmpty)) {
                          qty[cUom] = uom;
                        }
                      }
                    }
                  }
                }

                // TODO where to add new item?
                if (items.where((item) => item.isEmpty).isEmpty) {
                  items.add(MemoryItem.create());
                }

                return Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.top,
                  columnWidths: columnWidths,
                  children: [
                    TableRow(
                      children: tableHeaderColumns,
                      decoration: BoxDecoration(color: headingRowColor?.resolve(<MaterialState>{})),
                    ),
                    for (var index = 0; index < items.length; index++)
                      buildRow(context, columns, items, index, localization)
                  ],
                );
              case RequestStatus.initiate:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  TableRow buildRow(BuildContext context, Map<int, Field> columns, List<MemoryItem> items, int rowIndex,
      AppLocalizations localization) {
    final item = items[rowIndex];
    return TableRow(
      key: ValueKey('__line_${rowIndex}_${item.updatedAt}__'),
      children: [
        ...columns.entries.map((entry) {
          final colIndex = entry.key;
          final column = entry.value;
          final String? status = item.json[cStatus];

          if (column.type is UomType) {
            // final type = column.type as UomType;
            final Map<String, dynamic>? value = column.resolve(item.json);
            print("value $value");
            return Padding(
              padding: const EdgeInsets.only(right: cTableColumnGap),
              child: AutocompleteField<Map<String, dynamic>>(
                key: ValueKey('__line_${rowIndex}_${colIndex}_'),
                editable: status == 'deleted' ? false : column.editable,
                initialValue: value,
                // focusNode: _focusNode,
                create: (text) async {
                  throw Error();
                },
                delegate: (text) async {
                  throw Error();
                },
                displayStringForOption: (item) {
                  return qtyToText(item);
                  // return item?.name() ?? '';
                },
                itemBuilder: (context, entry) {
                  return Text(qtyToText(item)); // , style: Theme.of(context).textTheme.displayMedium);
                },
                onItemSelected: (entry) async {
                  throw Error();
                },
                deleted: status == 'deleted' ? true : false,
              ),
            );
          } else if (column.type is ReferenceType) {
            final type = column.type as ReferenceType;
            final MemoryItem? value = column.resolve(item.json);
            return Padding(
              padding: const EdgeInsets.only(right: cTableColumnGap),
              child: AutocompleteField<MemoryItem>(
                key: ValueKey('__line_${rowIndex}_${colIndex}_'),
                editable: status == 'deleted' ? false : column.editable,
                initialValue: value,
                // focusNode: _focusNode,
                create: (text) async {
                  final response = await Api.feathers().create(
                    serviceName: "memories",
                    data: {cName: text},
                    params: {"oid": Api.instance.oid, "ctx": type.ctx},
                  );
                  return MemoryItem.from(response);
                },
                delegate: (text) async {
                  final response = await Api.feathers()
                      .find(serviceName: "memories", query: {"oid": Api.instance.oid, "ctx": type.ctx, "search": text});
                  return (response['data'] ?? []).map<MemoryItem>((item) => MemoryItem.from(item)).toList();
                },
                displayStringForOption: (item) => item?.name() ?? '',
                itemBuilder: (context, entry) {
                  return Text(entry.name()); // , style: Theme.of(context).textTheme.displayMedium);
                },
                onItemSelected: (entry) async {
                  final Map<String, dynamic> data = {};
                  column.update(data, entry?.id);

                  // workaround: reset selected uom
                  fUomAtQty.update(data, null);

                  // print("onItemSelected $data");

                  patch(context, item, data);
                },
                deleted: status == 'deleted' ? true : false,
              ),
            );
          } else if (column.type is NumberType) {
            return Padding(
              padding: const EdgeInsets.only(right: cTableColumnGap),
              child: CustomTextField(
                key: ValueKey('__line_${rowIndex}_${colIndex}_'),
                initialValue: column.resolve(item.json),
                onChanged: (text) {
                  final Map<String, dynamic> data = {};

                  if (text.contains('.')) {
                    column.update(data, double.parse(text));
                  } else {
                    column.update(data, int.parse(text));
                  }

                  // print("CustomTextField $data");

                  patch(context, item, data);
                },
                editable: status == 'deleted' ? false : column.editable,
              ),
            );
          } else if (column.type is StringType) {
            return Padding(
              padding: const EdgeInsets.only(right: cTableColumnGap),
              child: CustomTextField(
                key: ValueKey('__line_${rowIndex}_${colIndex}_'),
                initialValue: column.resolve(item.json),
                onChanged: (text) {
                  final Map<String, dynamic> data = {};

                  column.update(data, text);

                  patch(context, item, data);
                },
                editable: status == 'deleted' ? false : column.editable,
              ),
            );
          } else if (column.type is PopupMenuButtonType && !item.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(right: cTableColumnGap, top: 9),
              child: DocumentPopupMenuButton(
                docId: widget.document.id,
                ctx: widget.ctx,
                schema: widget.schema,
                item: item,
                status: status,
                showStorages: () {
                  setState(() {
                    widget.showStorages = widget.showStorages == false ? true : false;
                  });
                },
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(right: cTableColumnGap),
              child: Container(),
            );
          }
        })
      ],
    );
  }

  void patch(BuildContext context, MemoryItem item, Map<String, dynamic> data) {
    // print("patch ${item.json}");

    MemoryItem? goods = item.json['goods'];

    if (goods?.json['uom'] != null && data['qty'] != null && data['qty']?['uom'] == null) {
      final number = data['qty']['number'] ?? data['qty'];

      data['qty']['uom'] = goods!.json['uom'];

      data['qty']['number'] = number;
    }

    // print("patch2 $data");
    if (item.isNew) {
      data[cDocument] = widget.document.id;
      context.read<MemoryBloc>().add(MemoryCreate('memories', widget.ctx, widget.schema, data));
    } else {
      context.read<MemoryBloc>().add(MemoryPatch('memories', widget.ctx, widget.schema, item.id, data));
    }
  }
}

class TableHeader extends StatelessWidget {
  final String label;
  final bool isFirst;
  final bool isNumeric;

  const TableHeader({super.key, required this.label, this.isFirst = false, this.isNumeric = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 0, // tableHeaderColor.isEmpty ? 0 : 8,
        bottom: 8, // tableHeaderColor.isEmpty ? 8 : 16,
        right: isNumeric ? cTableColumnGap : 0,
        left: isFirst ? 4 : 0, // tableHeaderColor.isNotEmpty && isFirst ? 4 : 0,
      ),
      child: Text(
        label,
        textAlign: isNumeric ? TextAlign.right : TextAlign.left,
        style: theme.dataTableTheme.headingTextStyle,
      ),
    );
  }
}

String qtyToText(dynamic listOrMap) {
  if (listOrMap == null) {
    return '';
  }
  String text = '';
  if (listOrMap != null) {
    if (listOrMap is List && listOrMap.isNotEmpty) {
      for (Map qty in listOrMap) {
        text = qtyToTextInner(text, qty);
      }
    } else if (listOrMap is Map) {
      text = qtyToTextInner(text, listOrMap);
    }
  }
  return text;
}

String qtyToTextInner(String text, Map qty) {
  if (text != '') {
    text = '$text, ';
  }
  final factor = qty['in'];
  if (factor != null) {
    text = '$text ${factor['name'] ?? ''} по ${qty['number'] ?? ''} ${qty['uom'] ?? ''}';
  } else {
    text = '$text ${qty['name'] ?? ''}';
  }

  // workaround for algorithm above
  text = text.trimLeft();

  // // print('_text $text');
  return text;
}
