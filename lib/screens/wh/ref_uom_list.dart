import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae_hr/model/memory/item.dart';
import 'package:nae_hr/model/memory/memory_bloc.dart';
import 'package:nae_hr/model/memory/memory_event.dart';
import 'package:nae_hr/model/memory/memory_state.dart';
import 'package:nae_hr/screens/wh/bottom_loader.dart';
import 'package:nae_hr/screens/wh/ref_uom_item.dart';
import 'package:pluto_grid/pluto_grid.dart';

class UomList extends StatefulWidget {
  const UomList({super.key, required this.onSelected});

  final void Function(MemoryItem item) onSelected;

  @override
  State<UomList> createState() => _UomListState();
}

class _UomListState extends State<UomList> {

  PlutoGridStateManager? stateManager;

  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'label',
      field: 'label',
      type: PlutoColumnType.text(),
    ),
  ];

  final ctx = ["uom"];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryBloc, RequestState>(
      builder: (context, state) {
        switch (state.status) {
          case RequestStatus.failure:
            return const Center(child: Text('failed to fetch'));
          case RequestStatus.success:
            if (state.items.isEmpty) {
              return const Center(child: Text('nothing yet'));
            }
            final rows = List.of(state.items.map((item) => PlutoRow(cells: {
              'memory': PlutoCell(value: item),
              'label': PlutoCell(value: item.json["label"] ?? ""),
            })));
            return buildPlutoGrid(context, columns, rows);
            // return ListView.builder(
            //   itemBuilder: (BuildContext context, int index) {
            //     return index >= state.items.length
            //         ? const BottomLoader()
            //         : UomListItem(item: state.items[index]);
            //   },
            //   itemCount: state.hasReachedMax
            //       ? state.items.length
            //       : state.items.length + 1,
            //   controller: _scrollController,
            // );
          case RequestStatus.loading:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  PlutoGrid buildPlutoGrid(BuildContext context, List<PlutoColumn> columns, List<PlutoRow> rows) {
    final theme = Theme.of(context);

    final config = PlutoGridConfiguration.dark(
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
        style: PlutoGridStyleConfig.dark(
          gridBackgroundColor: theme.canvasColor,
          rowColor: theme.canvasColor,
        )
    );

    return PlutoGrid(
      key: UniqueKey(),
      columns: columns,
      rows: rows,
      // columnGroups: columnGroups,
      configuration: config,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        print(event);
        stateManager = event.stateManager;
        // stateManager.setShowColumnFilter(true);
        stateManager?.setSelectingMode(PlutoGridSelectingMode.none);
      },
      onChanged: (PlutoGridOnChangedEvent event) {
        print(event);
      },
      onSelected: (PlutoGridOnSelectedEvent event) {
        print(event);
        final item = event.row?.cells["memory"]?.value;
        if (item is MemoryItem) {
          widget.onSelected(item);
        }
      },
      mode: PlutoGridMode.select,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<MemoryBloc>().add(MemoryFetch("memories", ctx));
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
