import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
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
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/autocomplete.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_divider.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_edit.dart';
import 'package:nae/widgets/scaffold_view.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

import 'screen.dart';

class WHTransferEditFS extends EntityHolder {
  const WHTransferEditFS({super.key, required super.entity})
      : super(fullscreen: true);

  @override
  State<WHTransferEditFS> createState() => _WHTransferEditFSState();
}

class _WHTransferEditFSState extends State<WHTransferEditFS>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_WHTransferEditFS');
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
      data['_id'] = widget.entity.id;

      context.read<MemoryBloc>().add(MemorySave("memories", WHTransfer.ctx,
          MemoryItem(id: widget.entity.id, json: data)));
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
              child: TabBarView(controller: _controller, children: <Widget>[
                WHTransferDocumentCreation(doc: widget.entity)
              ]),
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
                  DecoratedFormField(
                    name: 'date',
                    label: localization.translate("date"),
                    autofocus: true,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    onSave: _onSave,
                    keyboardType: TextInputType.datetime,
                  ),
                  DecoratedFormPickerField(
                    ctx: const ['warehouse', 'storage'],
                    name: 'from',
                    label: localization.translate("from"),
                    autofocus: true,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    onSave: _onSave,
                  ),
                  DecoratedFormPickerField(
                    ctx: const ['warehouse', 'storage'],
                    name: 'into',
                    label: localization.translate('into'),
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
                      document: widget.entity,
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
            appBarBottom: TabBar(
              controller: _controller,
              isScrollable: true,
              tabs: [
                Tab(text: localization.translate("goods")),
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
                    WHTransferGoodsRegistration(doc: widget.entity)
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
    if (widget.entity.isNew && widget.entity.json["date"] == null) {
      final json = Map.of(widget.entity.json);
      json["date"] = Utils.today();
      return MemoryItem(id: widget.entity.id, json: json);
    }
    return widget.entity;
  }
}

class Lines extends StatefulWidget {
  final List<String> ctx;
  final MemoryItem document;

  const Lines({super.key, required this.document, required this.ctx});

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

    final schema = <Field>[
      // const Field('batch', StringType()),
      fGoods.copyWith(width: 3.0),
      fUomAtQty.copyWith(width: 0.5, editable: false),
      fQty.copyWith(width: 1.0),
      // fStorage,
    ];

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
            'document': widget.document.id,
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
                return Center(
                    child:
                        Text(localization.translate('failed to fetch data')));
              case RequestStatus.success:
                final headingRowColor = theme.dataTableTheme.headingRowColor;
                final List<MemoryItem> items = List.of(state.items);

                // workaround: set uom from product default one
                for (MemoryItem item in items) {
                  final goods = item.json['goods'];
                  if (goods != null && goods is MemoryItem) {
                    final uom = goods.json['uom'];
                    if (uom != null) {
                      final qty = item.json['qty'];
                      if (qty == null) {
                        item.json['qty'] = {uom: uom};
                      } else if (qty is Map) {
                        final uomAtLine = qty['uom'];
                        if (uomAtLine == null ||
                            (uomAtLine is MemoryItem && uomAtLine.isEmpty)) {
                          qty['uom'] = uom;
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
                      decoration: BoxDecoration(
                          color: headingRowColor?.resolve(<MaterialState>{})),
                    ),
                    for (var index = 0; index < items.length; index++)
                      buildRow(context, columns, items, index, localization)
                  ],
                );
              case RequestStatus.loading:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  TableRow buildRow(BuildContext context, Map<int, Field> columns,
      List<MemoryItem> items, int rowIndex, AppLocalizations localization) {
    final item = items[rowIndex];
    return TableRow(
      key: ValueKey('__line_${rowIndex}_${item.updatedAt}__'),
      children: [
        ...columns.entries.map((entry) {
          final colIndex = entry.key;
          final column = entry.value;
          if (column.type is ReferenceType) {
            final type = column.type as ReferenceType;
            final MemoryItem? value = column.resolve(item.json);
            return Padding(
              padding: const EdgeInsets.only(right: cTableColumnGap),
              child: AutocompleteField<MemoryItem>(
                key: ValueKey('__line_${rowIndex}_${colIndex}_'),
                editable: column.editable,
                initialValue: value,
                // focusNode: _focusNode,
                create: (text) async {
                  final response = await Api.feathers().create(
                    serviceName: "memories",
                    data: {'name': text},
                    params: {"oid": Api.instance.oid, "ctx": type.ctx},
                  );
                  return MemoryItem.from(response);
                },
                delegate: (text) async {
                  final response = await Api.feathers().find(
                      serviceName: "memories",
                      query: {
                        "oid": Api.instance.oid,
                        "ctx": type.ctx,
                        "search": text
                      });
                  return (response['data'] ?? [])
                      .map<MemoryItem>((item) => MemoryItem.from(item))
                      .toList();
                },
                displayStringForOption: (item) => item?.name() ?? '',
                itemBuilder: (context, entry) {
                  return Text(entry
                      .name()); // , style: Theme.of(context).textTheme.displayMedium);
                },
                onItemSelected: (entry) async {
                  final Map<String, dynamic> data = {};
                  column.update(data, entry?.id);

                  // workaround: reset selected uom
                  fUomAtQty.update(data, null);

                  patch(context, item, data);
                },
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

                    patch(context, item, data);
                  }),
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
    if (item.isNew) {
      data['document'] = widget.document.id;
      context
          .read<MemoryBloc>()
          .add(MemoryCreate('memories', widget.ctx, data));
    } else {
      context
          .read<MemoryBloc>()
          .add(MemoryPatch('memories', widget.ctx, item.id, data));
    }
  }
}

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {super.key, required this.initialValue, required this.onChanged});

  final dynamic initialValue;
  final Function(String) onChanged;

  @override
  State<StatefulWidget> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final _controller = TextEditingController();
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller.text = widget.initialValue?.toString() ?? '';

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        print("lost focus");
        widget.onChanged(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
    );
  }
}

class TableHeader extends StatelessWidget {
  final String label;
  final bool isFirst;
  final bool isNumeric;

  const TableHeader(
      {super.key,
      required this.label,
      this.isFirst = false,
      this.isNumeric = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 0, // tableHeaderColor.isEmpty ? 0 : 8,
        bottom: 8, // tableHeaderColor.isEmpty ? 8 : 16,
        right: isNumeric ? cTableColumnGap : 0,
        left:
            isFirst ? 4 : 0, // tableHeaderColor.isNotEmpty && isFirst ? 4 : 0,
      ),
      child: Text(
        label,
        textAlign: isNumeric ? TextAlign.right : TextAlign.left,
        style: theme.dataTableTheme.headingTextStyle,
      ),
    );
  }
}

class WHTransferOverview extends StatelessWidget {
  final MemoryItem doc;

  const WHTransferOverview({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    print("context in WHTransferOverview: $context");

    final localization = AppLocalizations.of(context);

    final ctx = const ['warehouse', 'transfer'];
    final filter = {
      'document': doc.id,
    };
    final schema = <Field>[
      fGoods.copyWith(width: 3.0),
      fUomAtQty.copyWith(width: 0.5, editable: false),
      fQty.copyWith(width: 1.0),
    ];

    return BlocProvider(
      create: (context) {
        final bloc = MemoryBloc(schema: schema, reverse: true);
        bloc.add(MemoryFetch(
          'memories',
          ctx,
          filter: filter,
          reverse: true,
          loadAll: true,
        ));

        return bloc;
      },
      child: Column(children: <Widget>[
        ListDivider(),
        ListTile(
          title: Text(doc.json['date']),
          subtitle: Text(localization.translate("date")),
        ),
        ListTile(
          title: Text(doc.json['from'].name()),
          subtitle: Text(localization.translate("from")),
        ),
        ListTile(
          title: Text(doc.json['into'].name()),
          subtitle: Text(localization.translate("into")),
        ),
        ListDivider(),
      ]),
    );
  }
}

class WHTransferGoods extends StatelessWidget {
  final MemoryItem doc;

  const WHTransferGoods({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final ctx = const ['warehouse', 'transfer'];
    final filter = {
      'document': doc.id,
    };
    final schema = <Field>[
      fGoods.copyWith(width: 3.0),
      fUomAtQty.copyWith(width: 0.5, editable: false),
      fQty.copyWith(width: 1.0),
    ];

    return BlocProvider(
      create: (context) {
        final bloc = MemoryBloc(schema: schema, reverse: true);
        bloc.add(MemoryFetch(
          'memories',
          ctx,
          filter: filter,
          reverse: true,
          loadAll: true,
        ));

        return bloc;
      },
      child: MemoryList(
        ctx: ctx,
        filter: filter,
        schema: schema,
        title: (MemoryItem item) => fGoods.resolve(item.json)?.name() ?? '',
        subtitle: (MemoryItem item) =>
            '${fQty.resolve(item.json) ?? ' '} ${fUomAtQty.resolve(item.json)?.name() ?? ' '}',
        onTap: (MemoryItem item) => context
            .read<UiBloc>()
            .add(ChangeView(WHTransfer.ctx, entity: item)),
      ),
    );
  }
}

class WHTransferDocumentCreation extends StatefulWidget {
  final MemoryItem doc;

  const WHTransferDocumentCreation({super.key, required this.doc});

  @override
  State<StatefulWidget> createState() => _WHTransferDocumentCreationState();
}

class _WHTransferDocumentCreationState
    extends State<WHTransferDocumentCreation> {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_WHTransferDocumentCreation');
  final FocusScopeNode _focusNode = FocusScopeNode();

  final MemoryItem details = MemoryItem(id: '', json: {'date': Utils.today()});

  String status = "register";

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final widgets = <Widget>[
      AppForm(
          entity: details,
          formKey: _formKey,
          focusNode: _focusNode,
          onChanged: () {
            _formKey.currentState!.save();
            debugPrint("onChanged: ${_formKey.currentState!.value}");
          },
          child: ScrollableListView(children: <Widget>[
            FormCard(isLast: true, children: <Widget>[
              DecoratedFormField(
                name: 'date',
                label: localization.translate("date"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
                keyboardType: TextInputType.datetime,
              ),
              DecoratedFormPickerField(
                ctx: const ['warehouse', 'storage'],
                name: 'from',
                label: localization.translate("from"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              DecoratedFormPickerField(
                ctx: const ['warehouse', 'storage'],
                name: 'into',
                label: localization.translate('into'),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              Container(height: 10),
              ElevatedButton(
                onPressed: status == 'register'
                    ? () => registerDocument(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(localization.translate(status)),
              ),
            ])
          ]))
    ];
    return ScrollableListView(
      children: widgets,
    );
  }

  Future<dynamic> registerDocument(BuildContext context) async {
    final data = _formKey.currentState?.value;

    // print("data type ${data.runtimeType}");

    if (data == null) {
      return;
    }

    print("data $data");

    final date = data['date'] ?? '';
    final from = data['from'] as MemoryItem;
    final into = data['into'] as MemoryItem;

    final record = await Api.feathers().create(serviceName: 'memories', data: {
      'date': date,
      'from': from.id,
      'into': into.id,
    }, params: {
      'oid': Api.instance.oid,
      'ctx': ['warehouse', 'transfer', 'document']
    });

    print("record: $record");

    context.read<UiBloc>().add(ChangeView(WHTransfer.ctx,
        action: 'edit', entity: MemoryItem.from(record)));
  }
}

class WHTransferGoodsRegistration extends StatefulWidget {
  final MemoryItem doc;

  const WHTransferGoodsRegistration({super.key, required this.doc});

  @override
  State<StatefulWidget> createState() => _WHTransferGoodsRegistrationState();
}

class _WHTransferGoodsRegistrationState
    extends State<WHTransferGoodsRegistration> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(
      debugLabel: '_WHTransferGoodsRegistrationEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  final MemoryItem details = MemoryItem(id: '', json: {'date': Utils.today()});

  String status = "register";

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final widgets = <Widget>[
      AppForm(
          entity: details,
          formKey: _formKey,
          focusNode: _focusNode,
          onChanged: () {
            _formKey.currentState!.save();
            debugPrint("onChanged: ${_formKey.currentState!.value}");
          },
          child: ScrollableListView(children: <Widget>[
            FormCard(isLast: true, children: <Widget>[
              DecoratedFormPickerField(
                creatable: false,
                ctx: const ['printer'],
                name: 'printer',
                label: localization.translate("printer"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  // FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              const SizedBox(height: 10),
              DecoratedFormPickerField(
                ctx: const ['goods'],
                name: 'goods',
                label: localization.translate("goods"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: "выберите товар"),
                ]),
                onSave: (context) {},
              ),
              const SizedBox(height: 10),
              DecoratedFormPickerField(
                creatable: false,
                ctx: const ['uom'],
                name: 'uom',
                label: localization.translate("uom"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                      errorText: "выберите единицу измерения"),
                ]),
                onSave: (context) {},
              ),
              const SizedBox(height: 10),
              DecoratedFormField(
                name: 'qty',
                label: localization.translate("qty"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: status == 'register' ? registerGoods : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(localization.translate(status)),
              ),
              Container(height: 10),
              ElevatedButton(
                onPressed: status == 'register' ? registerAndPrint : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(localization.translate('and print'.toString())),
              )
            ])
          ]))
    ];
    return ScrollableListView(
      children: widgets,
    );
  }

  void registerGoods() async {
    final state = _formKey.currentState;
    if (state != null && state.saveAndValidate()) {
      final data = state.value;

      print("data $data");

      final doc = await widget.doc.enrich(WHTransfer.schema);

      print("doc: ${doc.json}");

      final goods = data['goods'] as MemoryItem;

      final uom = data['uom'] as MemoryItem;

      final from = doc.json['from'].json;
      final into = doc.json['into'].json;

      final number = data['qty']!;

      final qty = {'number': number, 'uom': uom.id};

      final record =
          await Api.feathers().create(serviceName: 'memories', data: {
        'document': doc.id,
        'goods': goods.id,
        'storage_from': from,
        'storage_into': into,
        'qty': qty,
      }, params: {
        'oid': Api.instance.oid,
        'ctx': ['warehouse', 'transfer']
      });

      print("record: $record");
    } else {
      debugPrint(_formKey.currentState?.value.toString());
      debugPrint('validation failed');
    }
  }

  void registerAndPrint() async {
    setState(() => status = "connecting");
    try {
      print("pressed:");

      final state = _formKey.currentState;
      if (state != null && state.saveAndValidate()) {
        final data = _formKey.currentState?.value;
        if (data == null) {
          return;
        }

        print("data $data");

        final printer = data['printer'] ?? '';
        final ip = printer is MemoryItem ? (printer.json['ip'] ?? '') : '';
        final port =
            printer is MemoryItem ? int.parse(printer.json['port']) : 0;

        print("printer $ip $port");

        final doc = await widget.doc.enrich(WHTransfer.schema);

        print("doc in transfer documents: ${doc.json}");

        final goods = data['goods'] as MemoryItem;
        final goodsName = goods.name();

        final uom = data['uom'] as MemoryItem;

        final date = doc.json['date']!;

        final from = doc.json['from'].json;
        final into = doc.json['into'].json;

        final number = data['qty']!;

        final qty = {'number': number, 'uom': uom.id};

        final result = await Labels.connect(ip, port, (printer) async {
          setState(() => status = "registering");
          final record =
              await Api.feathers().create(serviceName: 'memories', data: {
            'document': doc.id,
            'goods': goods.id,
            'storage_from': from,
            'storage_into': into,
            'qty': qty,
          }, params: {
            'oid': Api.instance.oid,
            'ctx': ['warehouse', 'transfer']
          });

          print("record: $record");

          setState(() => status = "printing");

          final dd = DateFormat.yMMMMd().format(DateTime.parse(date));

          final qtyNumber = qty['number'] ?? '';
          final qtyUom = uom.json['name'] ?? '';

          final Map<String, String> labelData = {
            "материал": goodsName,
            "дата": dd,
            "количество": "$qtyNumber $qtyUom",
            "line1": "",
            "поставщик": from['name'],
          };

          // TODO: get batch for printing (like in stock)
          // Labels.lines_with_barcode(printer, goodsName, goodsUuid, goodsId,
          //     '223033122222'.toString(), labelData);

          return Future<PrintResult>.value(PrintResult.success);
        });

        if (result != PrintResult.success) {
          showToast(result.msg,
              // context: context,
              axis: Axis.horizontal,
              alignment: Alignment.center,
              position: StyledToastPosition.bottom);
        }
      } else {
        debugPrint(_formKey.currentState?.value.toString());
        debugPrint('validation failed');
      }
    } catch (e, stacktrace) {
      print(stacktrace);
      showToast(e.toString(),
          // context: context,
          axis: Axis.horizontal,
          alignment: Alignment.center,
          position: StyledToastPosition.bottom);
    } finally {
      setState(() {
        status = "register";
      });
    }
  }
}
