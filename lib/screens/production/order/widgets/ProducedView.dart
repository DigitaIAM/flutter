import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/swipe_action.dart';
import 'ProducedEdit.dart';

class POProducedView extends StatefulWidget {
  final MemoryItem order;
  final Function()? afterSave;

  const POProducedView({
    super.key,
    required this.order,
    this.afterSave,
  });

  @override
  State<StatefulWidget> createState() => _POProducedViewState();
}

class _POProducedViewState extends State<POProducedView> {
  final GlobalKey<FormBuilderState> _editFormKey =
      GlobalKey<FormBuilderState>(debugLabel: '_goodsEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  MemoryItem? selected;
  String status = "register";
  bool registered = false;
  int numberOfQuantities = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ctx = ['production', 'produce'];
    final schema = [
      const Field(cQty, NumberType()),
      Field('code', CalculatedType((MemoryItem bag) async {
        return bag.id.split('T').last;
      }))
    ];
    final filter = {cDocument: widget.order.id};

    final date = DateTime.parse(widget.order.json[cDate]).toLocal();
    final formatter = NumberFormat("00");

    return BlocProvider(
      create: (context) => MemoryBloc(schema: schema)
        ..add(MemoryFetch('memories', ctx,
            schema: schema, filter: filter, loadAll: true)),
      child: BlocBuilder<MemoryBloc, RequestState>(builder: (context, state) {
        if (state.status == RequestStatus.initiate) {
          return const Center(child: Text('loading...'));
        } else if (state.status == RequestStatus.failure) {
          return const Center(child: Text('error!'));
        } else {
          final groups = <MemoryItem>{};
          Map<MemoryItem, List<MemoryItem>> items = {};
          for (final item in state.items) {
            var id = item.id;
            id = id.substring(id.length - 24, id.length);

            final current = DateTime.parse(id).toLocal();
            id =
                '${current.year}-${current.month}-${current.day}T${current.hour}';

            var name =
                '${formatter.format(current.hour)}-${formatter.format(current.hour + 1)} час';
            if (current.hour + 1 > 24) {
              name = '${formatter.format(current.hour)}-01 час';
            }

            if (current.year != date.year) {
              name = '${DateFormat.yMMMMd().format(current)} $name';
            } else if (current.month != date.month) {
              name = '${DateFormat.MMMMd().format(current)} $name';
            } else if (current.day != date.day) {
              name = '${DateFormat.MMMMd().format(current)} $name';
            }

            final group = MemoryItem(id: id, json: {cId: id, cName: name});
            groups.add(group);

            final list = items[group] ?? [];
            list.add(item);
            items[group] = list;
          }

          return SingleChildScrollView(
            child: Column(children: <Widget>[
              ...groups.map((g) {
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 5.0),
                  child: Column(children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      // leading: const Icon(Icons.account_circle),
                      tileColor: theme.secondaryHeaderColor,
                      title: Text(g.name()),
                      trailing: selected == g
                          ? const Icon(Icons.arrow_drop_down)
                          : const Icon(Icons.arrow_right),
                      onTap: () {
                        setState(() {
                          if (selected == g) {
                            selected = null;
                          } else {
                            selected = g;
                          }
                        });
                      },
                    ),
                    if (selected == g && items[selected] != null)
                      SizedBox(
                        height: 300,
                        child: ListView(
                          children: (items[selected] as List<MemoryItem>)
                              .map((item) => buildItem(item, theme))
                              .toList(),
                        ),
                      )
                  ]),
                );
              })
            ]),
          );
        }
      }),
    );
  }

  Widget buildItem(MemoryItem item, ThemeData theme) {
    //  print("buildItem ${item.json}");
    final title =
        '${item.json[cQty]?[cUom]?[cNumber].toString() ?? ''} ${item.json['customer'] ?? ''} ${item.json['label'] ?? ''}';
    final subtitle = item.id.split('T').last;
    final style = item.json[cStatus] == "deleted"
        ? const TextStyle(decoration: TextDecoration.lineThrough)
        : const TextStyle();

    final tile = ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      leading: const Icon(Icons.catching_pokemon_outlined),
      // title: Text(item.json[cQty].toString()),
      title: Text(title, style: style),
      subtitle: Text(subtitle, style: style),
      // trailing: const Icon(Icons.arrow_right),
      // openUsed ? const Icon(Icons.arrow_drop_down) : const Icon(Icons.arrow_right),
      onTap: () {
        // setState(() {
        //   openUsed = !openUsed;
        //   openProduced = false;
        // });
      },
    );

    final actions = [
      ItemAction(
        label: 'delete',
        icon: Icons.delete_outline,
        onPressed: (context, item) => deleteItem(context, item),
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
      ),
      ItemAction(
        label: 'print',
        icon: Icons.print_outlined,
        onPressed: (context, item) => chooseAndPrint(context, item),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
      ItemAction(
        label: 'edit',
        icon: Icons.edit,
        onPressed: (context, item) => editItem(context, item, widget.order),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
      ),
    ];

    return SwipeActionWidget(
      item: item,
      actions: actions,
      // key: key,
      child: tile,
    );
  }

  void deleteItem(BuildContext context, MemoryItem item) async {
    const ctx = ['production', 'produce'];
    final status = item.json[cStatus] == 'deleted' ? 'restored' : 'deleted';
    final Map<String, dynamic> data = {cStatus: status};
    // TODO fix schema
    context
        .read<MemoryBloc>()
        .add(MemoryPatch('memories', ctx, const [], item.id, data));
  }

  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void editItem(BuildContext context, MemoryItem item, MemoryItem order) async {
    // print('json :${item.json}');

    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context);

    final uiBloc = context.read<UiBloc>();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => BlocProvider(
        create: (ctx) => UiBloc(uiBloc.state),
        child: Dialog(
          child: SizedBox(
            width: 310,
            height: 320,
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
                SizedBox(
                  width: 300,
                  height: 250,
                  child: FormCard(
                    isLast: true,
                    children: [
                      AppForm(
                        entity: MemoryItem.from({
                          cQty: item.json['qty']['uom']['number']?.toString() ??
                              '',
                        }),
                        formKey: _editFormKey,
                        focusNode: _focusNode,
                        onChanged: () {
                          final state = _editFormKey.currentState!;
                          state.save();

                          state.validate(focusOnInvalid: false);
                          setState(() {
                            if (state.errors.isNotEmpty) {
                              status = 'error';
                            } else {
                              status = "register";
                            }
                          });
                        },
                        child: Column(
                          children: [
                            DecoratedFormField(
                              name: cQty,
                              label: localization.translate("qty in box"),
                              autofocus: true,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.integer(),
                              ]),
                              onSave: (context) {},
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(
                              width: 50,
                              height: 50,
                            ),
                            FloatingActionButton(
                              heroTag: 'product_register',
                              backgroundColor: theme.primaryColorDark,
                              onPressed: status == 'register'
                                  ? () => patching(context, item)
                                  : null,
                              tooltip:
                                  localization.translate('register'.toString()),
                              child: registered
                                  ? const Icon(Icons.done)
                                  : const Icon(Icons.save),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // final textController = TextEditingController();
    // return showMaterialModalBottomSheet(
    //   context: context,
    //   builder: (context) => ScrollableListView(children: <Widget>[
    //         FormCard(isLast: true, children: <Widget>[
    //           TextField(
    //             controller: textController,
    //           ),
    //           FloatingActionButton(
    //             backgroundColor: theme.primaryColorDark,
    //             onPressed: () {
    //               replacement(textController.text, item);
    //             },
    //             tooltip: AppLocalizations.of(context).translate("new line"),
    //             child: Icon(
    //               Icons.done,
    //               color: theme.primaryColorLight,
    //             ),
    //           ),
    //         ])
    //       ]));
  }

  void patching(BuildContext context, MemoryItem item) async {
    // print("patching ${item.json}");
    resetDone();

    var completed = true;
    try {
      final state = _editFormKey.currentState;
      if (state == null) {
        // print("state is null");
        // TODO raise error instead
        return;
      }
      if (state.saveAndValidate()) {
        final data = state.value;

        final qty = item.json[cQty];
        // print("qty before $qty");
        qty['uom']['number'] = data[cQty];
        // print("qty after $qty");

        final response = await Api.feathers()
            .patch(serviceName: "memories", objectId: item.id, data: {
          'qty': qty
        }, params: {
          "oid": Api.instance.oid,
          "ctx": ['production', 'produce'],
        });

        // print("response $response");
        Navigator.pop(context);
      } else {
        // print("validation fail");
      }
    } finally {
      done(completed);
    }
  }

  void resetDone() {
    setState(() {
      status = 'saving';
      registered = false;
    });
  }

  void done(bool completed) {
    if (completed) {
      if (widget.afterSave != null) {
        widget.afterSave?.call();
        return;
      }
    }
    setState(() {
      if (completed) {
        registered = completed;
        status = "saved";
      } else {
        status = "error";
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        status = "register";
        registered = false;
      });
    });
  }

  void setStatus(String newStatus) {
    setState(() => status = newStatus);
  }

  // void replacement(String reference, MemoryItem item) async {
  //   final response = await Api.feathers()
  //       .patch(serviceName: "memories", objectId: item.id, data: {
  //     'document': reference
  //   }, params: {
  //     "oid": Api.instance.oid,
  //     "ctx": ['production', 'produce'],
  //   });
  // }

  Future chooseAndPrint(BuildContext context, MemoryItem doc) async {
    final list = await getPrinters(doc);

    return showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: list,
      ),
    );
  }

  Future<Widget> getPrinters(MemoryItem doc) async {
    final response = await Api.feathers().find(serviceName: "memories", query: {
      "oid": Api.instance.oid,
      "ctx": const [cPrinter],
    });

    // print("printers ${response.runtimeType} ${response}");

    final printers = response['data'];

    final children = <Widget>[];

    children.add(const Text("Choose printer"));

    if (printers is List) {
      for (var printer in printers) {
        children.add(ListTile(
          title: Text(printer[cName] ?? ''),
          onTap: () async {
            final ip = printer['ip'];
            final port = int.parse(printer['port']);

            final result = await Labels.connect(
                ip,
                port,
                (printer) async => POProducedEdit.printingProduce(
                    printer, widget.order, doc, (newStatus) {}));

            if (result != PrintResult.success) {
              showToast(result.msg,
                  // context: context,
                  axis: Axis.horizontal,
                  alignment: Alignment.center,
                  position: StyledToastPosition.bottom);
            }
          },
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
