import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/autocomplete.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scaffold_edit.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

import 'screen.dart';

class WHReceiveEditFS extends EntityHolder {
  const WHReceiveEditFS({super.key, required super.entity}) : super(fullscreen: true);

  @override
  State<WHReceiveEditFS> createState() => _WHReceiveEditFSState();
}

class _WHReceiveEditFSState extends State<WHReceiveEditFS> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_WHReceiveEditFS');
  final FocusScopeNode _focusNode = FocusScopeNode();

  @override
  void dispose() {
    _focusNode.dispose();

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

      context
          .read<MemoryBloc>()
          .add(MemorySave("memories", WHReceive.ctx, MemoryItem(id: widget.entity.id, json: data)));
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

    routerBack(BuildContext context) {
      context.read<UiBloc>().add(ChangeView(WHReceive.ctx));
      // TODO context.read<UiBloc>().add(PreviousRoute());
    }

    return EditScaffold(
      entity: widget.entity,
      title: localization.translate("warehouse receive"),
      onClose: routerBack,
      onCancel: routerBack,
      onSave: _onSave,
      body: AppForm(
        schema: WHReceive.schema,
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
              name: 'storage',
              label: localization.translate("storage"),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: _onSave,
            ),
            DecoratedFormPickerField(
              ctx: const ['counterparty'],
              name: 'counterparty',
              label: localization.translate('counterparty'),
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
                ctx: const ['warehouse', 'receive'],
                document: widget.entity,
              ),
              // workaround to give some space for dropdown
              Container(height: 300)
            ]),
          )
        ]),
      ),
    );
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
                return Center(child: Text(localization.translate('failed to fetch data')));
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
                        if (uomAtLine == null || (uomAtLine is MemoryItem && uomAtLine.isEmpty)) {
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
                      decoration: BoxDecoration(color: headingRowColor?.resolve(<MaterialState>{})),
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

  TableRow buildRow(BuildContext context, Map<int, Field> columns, List<MemoryItem> items, int rowIndex,
      AppLocalizations localization) {
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
      context.read<MemoryBloc>().add(MemoryCreate('memories', widget.ctx, data));
    } else {
      context.read<MemoryBloc>().add(MemoryPatch('memories', widget.ctx, item.id, data));
    }
  }
}

class CustomTextField extends StatefulWidget {
  const CustomTextField({super.key, required this.initialValue, required this.onChanged});

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
