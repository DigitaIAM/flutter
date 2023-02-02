
import 'package:flutter/material.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/model/memory/item.dart';
import 'package:nae_hr/widgets/entity_header.dart';
import 'package:nae_hr/widgets/entity_screens.dart';
import 'package:nae_hr/widgets/list_divider.dart';
import 'package:nae_hr/widgets/scaffold_view.dart';
import 'package:nae_hr/widgets/scrollable_list_view.dart';

class ProductionOrderEdit extends EntityHolder {
  const ProductionOrderEdit({super.key, required super.entity});

  @override
  State<ProductionOrderEdit> createState() => _ProductionOrderEditState();

}

class _ProductionOrderEditState extends State<ProductionOrderEdit> with SingleTickerProviderStateMixin {

  late TabController _controller;

  @override
  void initState() {
    super.initState();

    // final state = widget.viewModel.state;
    _controller = TabController(
        vsync: this,
        length: 2,
        initialIndex: 0 // widget.isFilter ? 0 : state.productUIState.tabIndex
    );
    _controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    // if (widget.isFilter) {
    //   return;
    // }

    // final store = StoreProvider.of<AppState>(context);
    // store.dispatch(UpdateProductTab(tabIndex: _controller.index));
  }

  // @override
  // void didUpdateWidget(oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //
  //   if (oldWidget.tabIndex != widget.tabIndex) {
  //     _controller.index = widget.tabIndex;
  //   }
  // }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return ScaffoldView(
      appBarBottom: TabBar(
        controller: _controller,
        isScrollable: true,
        tabs: [
          Tab(text: localization.translate("overview")),
          Tab(text: localization.translate("task")),
        ],
      ),
      body: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  ProductionOrderOverview(
                      memoryItem: widget.entity
                  ),
                  ProductionOrderOverview(
                      memoryItem: widget.entity
                  ),
                ]
              )
            ),
        ]
        );
      })
    );
  }
}

class ProductionOrderOverview extends StatelessWidget {

  final MemoryItem memoryItem;

  const ProductionOrderOverview({super.key, required this.memoryItem});

  @override
  Widget build(BuildContext context) {

    final widgets = <Widget>[
      EntityHeader(
        label: AppLocalizations.of(context).translate("production_order"),
        value: "00001",
      ),
      ListDivider(),
    ];

    return ScrollableListView(
      children: widgets,
    );
  }
}