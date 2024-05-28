import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/screens/wh/dispatch/edit_fullscreen/goods.dart';
import 'package:nae/screens/wh/dispatch/edit_fullscreen/overview.dart';
import 'package:nae/screens/wh/goods_registration.dart';
import 'package:nae/screens/wh/return/document_creation.dart';
import 'package:nae/screens/wh/return/goods.dart';
import 'package:nae/screens/wh/return/goods_return.dart';
import 'package:nae/screens/wh/return/overview.dart';
import 'package:nae/screens/wh/return/screen.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/utils/date.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_view.dart';

class WHReturnEditFS extends EntityHolder {
  final bool showStorages;
  const WHReturnEditFS(
      {super.key, required super.entity, this.showStorages = false});

  @override
  State<WHReturnEditFS> createState() => _WHReturnEditFSState();
}

class _WHReturnEditFSState extends State<WHReturnEditFS>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_WHReturnEditFS');
  final FocusScopeNode _focusNode = FocusScopeNode();

  late TabController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TabController(
      vsync: this,
      length: widget.entity.isNew ? 1 : 3,
      initialIndex: 0, //widget.entity.isNew ? 0 : 1,
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
            Tab(text: localization.translate("new document")),
          ],
        ),
        body: Builder(builder: (context) {
          return Column(children: <Widget>[
            Expanded(
              child: TabBarView(controller: _controller, children: <Widget>[
                WHReturnDocumentCreation(
                  entity: widget.entity,
                )
              ]),
            ),
          ]);
        }),
      );
    } else {
      routerBack(BuildContext context) {
        context.read<UiBloc>().add(ChangeView(WHReturn.ctx));
        // TODO context.read<UiBloc>().add(PreviousRoute());
      }

      return ScaffoldView(
        title:
            "${localization.translate("return to the warehouse")} ${DT.format(widget.entity.json[cDate])}",
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
              context.read<UiBloc>().add(ChangeView(WHReturn.ctx,
                  action: 'edit', entity: widget.entity));
            },
          ),
        ],
        body: Builder(builder: (context) {
          return Column(children: <Widget>[
            Expanded(
              child: TabBarView(controller: _controller, children: <Widget>[
                WHReturnGoods(
                  doc: widget.entity,
                  mode: Mode.mobile,
                ),
                //WHReturnOverview(doc: widget.entity),
                GoodsReturn(
                  doc: widget.entity,
                  entity: widget.entity,
                ),
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
