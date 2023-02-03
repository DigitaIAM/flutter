
import 'package:flutter/material.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/models/memory/item.dart';
import 'package:nae_hr/widgets/entity_header.dart';
import 'package:nae_hr/widgets/list_divider.dart';
import 'package:nae_hr/widgets/scaffold_view.dart';
import 'package:nae_hr/widgets/scrollable_list_view.dart';

class ProductView extends StatefulWidget {
  final MemoryItem entity;

  const ProductView({super.key, required this.entity});

  @override
  State<ProductView> createState() => _ProductViewState();

}

class _ProductViewState extends State<ProductView> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return ScaffoldView(
      body: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            Expanded(
              child: ProductOverview(
                  entity: widget.entity
              ),
            ),
        ]
        );
      })
    );
  }
}

class ProductOverview extends StatelessWidget {

  final MemoryItem entity;

  const ProductOverview({super.key, required this.entity});

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