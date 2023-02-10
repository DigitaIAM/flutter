import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/core/my_settings.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/state.dart';
import 'package:nae/widgets/app_border.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:provider/provider.dart';

abstract class EntityHolder extends StatefulWidget {
  const EntityHolder({super.key, required this.entity});

  final MemoryItem entity;

  bool anythingToShow() {
    return entity.id.isNotEmpty;
  }
}

class EntityScreens extends StatelessWidget {
  final List<String> ctx;
  final Widget list;
  final EntityHolder view;

  const EntityScreens({super.key, required this.ctx, required this.list, required this.view});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UiBloc, UiState>(
        builder: (context, uiState) => MemoryBlocHolder(
            init: (bloc) => ctx.isNotEmpty ? bloc.add(MemoryFetch("memories", ctx)) : null,
            child: Row(children: uiState.isFullScreen ? smallScreen(context, uiState) : bigScreen(context, uiState))));
  }

  List<Widget> smallScreen(BuildContext context, UiState uiState) {
    print("smallScreen: ${view.anythingToShow()}");
    const previewFlex = 2;
    int listFlex = 3;

    if (view.anythingToShow()) {
      return [
        Expanded(
          flex: uiState.isFullScreen ? (listFlex + previewFlex) : previewFlex,
          child: AppBorder(
            isLeft: true,
            child: view,
          ),
        ),
      ];
    } else {
      return [
        Expanded(
          flex: listFlex,
          child: ClipRRect(child: list),
        ),
      ];
    }
  }

  List<Widget> bigScreen(BuildContext context, UiState uiState) {
    print("bigScreen: ${view.anythingToShow()}");
    final settings = Provider.of<MySettings>(context);

    const previewFlex = 2;
    int listFlex = 3;

    Widget? topFilterChild;
    // topFilterChild = EntityTopFilter(
    //   show: uiState.filterEntityType != null,
    // );
    Widget? leftFilterChild;
    return [
      Expanded(
        flex: listFlex,
        child: ClipRRect(
          child: AppBorder(
            isLeft: leftFilterChild != null,
            child: topFilterChild == null || settings.isFilterVisible
                ? list
                : Column(
                    children: [
                      // if (prefState.isViewerFullScreen(state.uiState.filterEntityType))
                      //   SizedBox(
                      //     height: 360,
                      //     child: topFilterChild,
                      //   )
                      // else
                      topFilterChild,
                      Expanded(
                        child: AppBorder(
                          isTop: topFilterChild != null, // && uiState.filterEntityType != null,
                          child: list,
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ),
      if (view.anythingToShow())
        Expanded(
          flex: uiState.isFullScreen ? (listFlex + previewFlex) : previewFlex,
          child: AppBorder(
            isLeft: true,
            child: view,
          ),
        ),
    ];
  }
}
