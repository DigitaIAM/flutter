import 'package:flutter/material.dart';

import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/models/memory/item.dart';
import 'package:nae_hr/widgets/entity_header.dart';
import 'package:nae_hr/widgets/entity_screens.dart';
import 'package:nae_hr/widgets/list_divider.dart';
import 'package:nae_hr/widgets/scaffold_view.dart';
import 'package:nae_hr/widgets/scrollable_list_view.dart';

class UomView extends EntityHolder {
  const UomView({super.key, required super.entity});

  @override
  State<UomView> createState() => _UomViewState();
}

class _UomViewState extends State<UomView> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return ScaffoldView(
      body: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            Expanded(
              child: UomOverview(
                  entity: widget.entity
              ),
            ),
        ]
        );
      })
    );
  }
}

class UomOverview extends StatelessWidget {

  final MemoryItem entity;

  const UomOverview({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {

    final widgets = <Widget>[
      EntityHeader(
        label: AppLocalizations.of(context).translate("uom"),
        value: entity.label(),
      ),
      ListDivider(),
    ];

    return ScrollableListView(
      children: widgets,
    );
  }
}