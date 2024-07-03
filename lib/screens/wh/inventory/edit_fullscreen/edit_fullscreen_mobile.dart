import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/qty.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/screens/wh/inventory/edit_fullscreen/document_edit.dart';
import 'package:nae/screens/wh/inventory/edit_fullscreen/goods.dart';
import 'package:nae/screens/wh/inventory/edit_fullscreen/overview.dart';
import 'package:nae/screens/wh/inventory/screen.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_view.dart';

class WHInventoryEditMobile extends EntityHolder {
  final bool showStorages;
  const WHInventoryEditMobile(
      {super.key, required super.entity, this.showStorages = false});

  @override
  State<WHInventoryEditMobile> createState() => _WHInventoryEditMobileState();
}

class _WHInventoryEditMobileState extends State<WHInventoryEditMobile>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_WHInventoryEditMobile');
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

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    if (widget.entity.isNew) {
      return ScaffoldView(
        appBarBottom: TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: [
            Tab(text: localization.translate("new warehouse inventory")),
          ],
        ),
        body: Builder(builder: (context) {
          return Column(children: <Widget>[
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  WHInventoryDocumentEdit(entity: widget.entity)
                ],
              ),
            ),
          ]);
        }),
      );
    } else {
      routerBack(BuildContext context) {
        context.read<UiBloc>().add(ChangeView(WHInventory.ctx));
        // TODO context.read<UiBloc>().add(PreviousRoute());
      }

      return ScaffoldView(
        title:
            "${localization.translate("warehouse inventory")} ${DT.format(widget.entity.json[cDate])}",
        appBarBottom: TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: [
            Tab(text: localization.translate(cGoods)),
            Tab(text: localization.translate("overview")),
            Tab(text: localization.translate("registration")),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit_note_outlined),
            tooltip: localization.translate("edit"),
            onPressed: () {
              context.read<UiBloc>().add(ChangeView(WHInventory.ctx,
                  action: 'edit', entity: widget.entity));
            },
          ),
        ],
        body: Builder(builder: (context) {
          return Column(children: <Widget>[
            Expanded(
              child: TabBarView(controller: _controller, children: <Widget>[
                WHInventoryGoods(
                  doc: widget.entity,
                  mode: Mode.mobile,
                ),
                WHInventoryOverview(doc: widget.entity),
                ScanRegistration(doc: widget.entity),
              ]),
            ),
          ]);
        }),
      );
    }
  }

  MemoryItem getEntity() {
    if (widget.entity.isNew && widget.entity.json[cDate] == null) {
      final json = Map.of(widget.entity.json);
      json[cDate] = Utils.today();
      return MemoryItem(id: widget.entity.id, json: json);
    } else {
      final json = Map.of(widget.entity.json);
      json[cDate] = DateTime.parse(
          json[cDate]); //DateFormat("yyyy-MM-dd").format(json[cDate]);
      return MemoryItem(id: widget.entity.id, json: json);
    }
  }
}

class ScanRegistration extends StatefulWidget {
  final MemoryItem doc;

  const ScanRegistration({super.key, required this.doc});

  @override
  State<StatefulWidget> createState() => _ScanRegistrationState();
}

class _ScanRegistrationState extends State<ScanRegistration> {
  final textController = TextEditingController();

  final focusNode = FocusNode();

  String error = '';

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ctx = ['warehouse', 'inventory'];
    return BlocProvider(
      create: (context) {
        final bloc = MemoryBloc(schema: [], reverse: true);
        bloc.add(MemoryFetch(
          'memories',
          ctx,
          // filter: filter,
          reverse: true,
          loadAll: true,
        ));

        print("bloc $bloc");

        return bloc;
      },
      child: BlocConsumer<MemoryBloc, RequestState>(
        listener: (context, state) {
          // do stuff here based on BlocA's state
        },
        builder: (context, state) => ListView(children: <Widget>[
          KeyboardListener(
            focusNode: focusNode,
            autofocus: true,
            onKeyEvent: (event) {
              print("keyboard $event");
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  final reference = textController.text;
                  process(context, reference, state);
                } else {
                  textController.text += event.character ?? '';
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Column(children: [
                TextFormField(
                  readOnly: true,
                  // focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(
                      color: Color(0xFF6200EE),
                    ),
                    helperText: 'отсканируйте ТМЦ',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  controller: textController,
                ),
                if (error.isNotEmpty) Text('ОШИБКА: $error !'),
                Text(state.saved?['goods']?.name() ?? ''),
                Text(state.saved?.json['batch']?['date'] ?? ''),
                Text(Qty.fromJson(state.saved?.json['qty']).toString())
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  void process(
      BuildContext context, String reference, RequestState state) async {
    if (state.status != RequestStatus.success) {
      textController.text = '';
      setState(() {
        error = 'нет данных с сервера';
      });

      return;
    }

    // setState(() {
    //   object = MemoryItem.empty();
    // });

    for (final item in state.items) {
      if (item.json['reference'] == reference) {
        textController.text = '';
        setState(() {
          error = 'такой товар уже есть';
        });
        return;
      }
    }

    final res = await Api.feathers().get(
      serviceName: "memories",
      objectId: reference,
      params: {
        "oid": Api.instance.oid,
      },
    );

    print("res $res");

    final docId = res[cDocument];
    if (docId != null) {
      final document = await Api.feathers().get(
        serviceName: "memories",
        objectId: docId,
        params: {'oid': Api.instance.oid},
      );

      print("document $document");

      textController.text = '';

      final data = {
        cDocument: widget.doc.id,
        'reference': reference,
        cGoods: document['product']['_id'],
        cBatch: {'id': document['_uuid'], 'date': document[cDate]},
        cQty: res[cQty],
        'customer': res['customer'],
        'label': res['label'],
      };

      print("data $data");

      context.read<MemoryBloc>().add(
          MemoryCreate('memories', WHInventory.ctxOfRecord, const [], data));

      // final response = await Api.feathers().create(
      //   serviceName: "memories",
      //   data: data,
      //   params: {
      //     "oid": Api.instance.oid,
      //     'ctx': WHInventory.ctxOfRecord,
      //   },
      // );
      // print("response $response");

      // setState(() {
      //   object = MemoryItem.from(response);
      // });
    }
  }
}
