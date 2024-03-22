import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/screens/wh/goods_dispatch.dart';
import 'package:nae/screens/wh/transfer/edit_fullscreen/document_creation.dart';
import 'package:nae/screens/wh/transfer/edit_fullscreen/goods.dart';
import 'package:nae/screens/wh/transfer/edit_fullscreen/overview.dart';
import 'package:nae/screens/wh/transfer/screen.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_view.dart';

class WHTransferEditMobile extends EntityHolder {
  final bool showStorages;

  const WHTransferEditMobile(
      {super.key, required super.entity, this.showStorages = false});

  @override
  State<WHTransferEditMobile> createState() => _WHTransferEditMobileState();
}

class _WHTransferEditMobileState extends State<WHTransferEditMobile>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_WHTransferEditMobile');
  final FocusScopeNode _focusNode = FocusScopeNode();

  late TabController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TabController(
      vsync: this,
      length: widget.entity.isNew ? 1 : 3,
      initialIndex: 0, // widget.entity.isNew ? 0 : 1,
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
      data[cDate] = DT.format(data[cDate]);
      //DateFormat("yyyy-MM-dd").format(data[cDate]);

      context.read<MemoryBloc>().add(MemorySave("memories", WHTransfer.ctx,
          WHTransfer.schema, MemoryItem(id: widget.entity.id, json: data)));
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
                children: <Widget>[
                  WHTransferDocumentCreation(doc: widget.entity)
                ],
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

      return ScaffoldView(
        title:
            "${localization.translate("warehouse transfer")} ${DT.format(widget.entity.json[cDate])}",
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
              context.read<UiBloc>().add(ChangeView(WHTransfer.ctx,
                  action: 'edit', entity: widget.entity));
            },
          ),
        ],
        body: Builder(builder: (context) {
          return Column(children: <Widget>[
            Expanded(
              child: TabBarView(controller: _controller, children: <Widget>[
                WHTransferGoods(
                  doc: widget.entity,
                  mode: Mode.mobile,
                ),
                WHTransferOverview(doc: widget.entity),
                GoodsDispatch(
                  ctx: const ['warehouse', 'transfer'],
                  doc: widget.entity,
                  schema: WHTransfer.schema,
                  storage: const MemoryItem(
                      id: 'warehouse/storage/2023-02-19T12:00:25.151Z',
                      json: {
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
