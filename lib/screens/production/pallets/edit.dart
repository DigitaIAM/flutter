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
import 'package:nae/screens/production/pallets/document_edit.dart';
import 'package:nae/screens/production/pallets/goods.dart';
import 'package:nae/screens/production/pallets/overview.dart';
import 'package:nae/screens/wh/goods_dispatch.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_view.dart';

import 'screen.dart';

class FormationOfPalletsEdit extends EntityHolder {
  const FormationOfPalletsEdit({super.key, required super.entity});

  @override
  State<FormationOfPalletsEdit> createState() => _FormationOfPalletsEditState();
}

class _FormationOfPalletsEditState extends State<FormationOfPalletsEdit>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();

    final isOpen = widget.entity.json['packed_at'] == null;

    _controller = TabController(
      vsync: this,
      length: widget.entity.isNew
          ? 1
          : isOpen
              ? 3
              : 2,
      initialIndex: widget.entity.isNew ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    if (widget.entity.isNew) {
      return ScaffoldView(
        title:
            "${localization.translate("pallet")} ${DT.format(widget.entity.json[cDate])}",
        appBarBottom: TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: [
            Tab(text: localization.translate("new pallet")),
          ],
        ),
        body: Builder(builder: (context) {
          return Column(children: <Widget>[
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  PalletDocumentEdit(
                    entity: widget.entity,
                  ),
                ],
              ),
            ),
          ]);
        }),
      );
    } else {
      final isOpen = widget.entity.json['packed_at'] == null;
      return ScaffoldView(
        title:
            "${localization.translate("pallet")} ${DT.format(widget.entity.json[cDate])}",
        appBarBottom: TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: [
            Tab(text: localization.translate(cGoods)),
            Tab(text: localization.translate("overview")),
            if (isOpen) Tab(text: localization.translate("registration")),
          ],
        ),
        actions: <Widget>[
          if (isOpen)
            IconButton(
              icon: const Icon(Icons.edit_note_outlined),
              tooltip: localization.translate("edit"),
              onPressed: () {
                context.read<UiBloc>().add(ChangeView(PalletPacking.ctx,
                    action: 'edit', entity: widget.entity));
              },
            ),
        ],
        body: Builder(builder: (context) {
          return Column(children: <Widget>[
            Expanded(
              child: TabBarView(controller: _controller, children: <Widget>[
                PalletsGoods(
                  doc: widget.entity,
                  mode: Mode.mobile,
                ),
                PalletOverview(
                  doc: widget.entity,
                ),
                if (isOpen)
                  GoodsDispatch(
                    ctx: PalletPacking.ctxOfDispatch,
                    doc: widget.entity,
                    schema: PalletPacking.schema,
                    storage: widget.entity[cStorage],
                    storageEditable: false,
                    enablePrinting: false,
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
      json[cDate] = DateTime.now(); // Utils.today();
      return MemoryItem(id: widget.entity.id, json: json);
    } else {
      final json = Map.of(widget.entity.json);
      json[cDate] = DateTime.parse(
          json[cDate]); //DateFormat("yyyy-MM-dd").format(json[cDate]);
      return MemoryItem(id: widget.entity.id, json: json);
    }
  }
}
