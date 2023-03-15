import 'package:flutter/material.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scaffold_view.dart';

import 'screen.dart';

class WHBalanceView extends EntityHolder {
  final int tabIndex;

  const WHBalanceView({super.key, required super.entity, required this.tabIndex});

  @override
  State<WHBalanceView> createState() => _WHBalanceViewState();
}

class _WHBalanceViewState extends State<WHBalanceView> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();

    // final state = widget.viewModel.state;
    _controller = TabController(
      vsync: this, length: 2, initialIndex: 0, // widget.isFilter ? 0 : state.WHDispatchUIState.tabIndex
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

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tabIndex != widget.tabIndex) {
      _controller.index = widget.tabIndex;
    }
  }

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
//          Tab(text: localization.translate("goods")),
        ],
      ),
      body: Builder(builder: (context) {
        return Column(children: <Widget>[
          Expanded(
            child: TabBarView(
                controller: _controller,
                children: <Widget>[Container()] //WHDispatchOverview(doc: widget.entity), WHDispatchGoods(doc: widget.entity)]),
            ),
          ),
        ]);
      }),
    );
  }
}
